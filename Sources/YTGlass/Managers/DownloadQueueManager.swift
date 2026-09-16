import Foundation

final class DownloadQueueManager: ObservableObject {
    @Published var items: [DownloadItem] = []
    @Published var lastAddError: String?

    private let settings: AppSettings
    private var processes: [UUID: Process] = [:]
    private var discoveredFilePaths: [UUID: String] = [:]

    private let persistenceURL: URL

    init(settings: AppSettings) {
        self.settings = settings

        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = appSupport.appendingPathComponent("YTGlass", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        self.persistenceURL = folder.appendingPathComponent("queue.json")

        load()
    }

    // MARK: - Adding

    func addSingle(urlString: String, quality: QualityTier, audioOnly: Bool, subtitles: Bool) {
        var placeholder = DownloadItem(
            sourceURL: urlString,
            title: urlString,
            quality: quality,
            audioOnly: audioOnly,
            downloadSubtitles: subtitles
        )
        placeholder.status = .fetchingInfo
        items.append(placeholder)
        let placeholderID = placeholder.id
        save()

        Task {
            do {
                let info = try await YTDLPClient.fetchSingleInfo(url: urlString)
                await MainActor.run {
                    guard let idx = self.items.firstIndex(where: { $0.id == placeholderID }) else { return }
                    self.items[idx].title = info.title
                    self.items[idx].thumbnailURL = info.thumbnailURL
                    self.items[idx].duration = info.duration
                    self.items[idx].sourceURL = info.webpageURL
                    self.items[idx].status = .queued
                    self.save()
                    self.scheduleNext()
                }
            } catch {
                await MainActor.run {
                    guard let idx = self.items.firstIndex(where: { $0.id == placeholderID }) else { return }
                    self.items[idx].status = .failed
                    self.items[idx].errorMessage = error.localizedDescription
                    self.save()
                }
            }
        }
    }

    func addPlaylist(urlString: String, quality: QualityTier, audioOnly: Bool, subtitles: Bool) {
        var placeholder = DownloadItem(
            sourceURL: urlString,
            title: "Recupero playlist…",
            quality: quality,
            audioOnly: audioOnly,
            downloadSubtitles: subtitles
        )
        placeholder.status = .fetchingInfo
        items.append(placeholder)
        let placeholderID = placeholder.id
        save()

        Task {
            do {
                let entries = try await YTDLPClient.fetchPlaylistFlat(url: urlString)
                await MainActor.run {
                    guard let idx = self.items.firstIndex(where: { $0.id == placeholderID }) else { return }
                    self.items.remove(at: idx)

                    for entry in entries {
                        var item = DownloadItem(
                            sourceURL: entry.url,
                            title: entry.title,
                            thumbnailURL: entry.thumbnailURL,
                            quality: quality,
                            audioOnly: audioOnly,
                            downloadSubtitles: subtitles
                        )
                        item.status = .queued
                        self.items.append(item)
                    }
                    self.save()
                    self.scheduleNext()
                }
            } catch {
                await MainActor.run {
                    guard let idx = self.items.firstIndex(where: { $0.id == placeholderID }) else { return }
                    self.items[idx].status = .failed
                    self.items[idx].errorMessage = error.localizedDescription
                    self.save()
                }
            }
        }
    }

    // MARK: - Reordering / removal

    func moveUp(_ id: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == id }), idx > 0 else { return }
        items.swapAt(idx, idx - 1)
        save()
    }

    func moveDown(_ id: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == id }), idx < items.count - 1 else { return }
        items.swapAt(idx, idx + 1)
        save()
    }

    func remove(_ id: UUID) {
        cancel(id)
        items.removeAll { $0.id == id }
        save()
    }

    func retry(_ id: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].status = .queued
        items[idx].errorMessage = nil
        items[idx].progressPercent = 0
        save()
        scheduleNext()
    }

    func clearCompleted() {
        items.removeAll { $0.status == .completed }
        save()
    }

    // MARK: - Download lifecycle

    func scheduleNext() {
        let activeCount = items.filter { $0.status == .downloading }.count
        guard activeCount < settings.maxConcurrentDownloads else { return }
        guard let next = items.first(where: { $0.status == .queued }) else { return }
        start(itemID: next.id)
        scheduleNext()
    }

    private func start(itemID: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == itemID }) else { return }
        guard let path = YTDLPLocator.ytdlpPath() else {
            items[idx].status = .failed
            items[idx].errorMessage = "yt-dlp non trovato. Installalo con Homebrew: brew install yt-dlp"
            return
        }

        items[idx].status = .downloading
        items[idx].progressPercent = 0
        items[idx].errorMessage = nil

        let args = YTDLPClient.downloadArguments(for: items[idx], settings: settings)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = args

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
            let lines = text.split(whereSeparator: { $0 == "\n" || $0 == "\r" })
            for line in lines {
                let lineString = String(line)
                DispatchQueue.main.async {
                    self?.handleOutputLine(lineString, itemID: itemID)
                }
            }
        }

        process.terminationHandler = { [weak self] proc in
            pipe.fileHandleForReading.readabilityHandler = nil
            DispatchQueue.main.async {
                self?.finishProcess(itemID: itemID, exitCode: proc.terminationStatus)
            }
        }

        do {
            try process.run()
            processes[itemID] = process
        } catch {
            items[idx].status = .failed
            items[idx].errorMessage = error.localizedDescription
        }
    }

    private func handleOutputLine(_ line: String, itemID: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == itemID }) else { return }

        if line.hasPrefix("PROGRESS") {
            let parts = line.split(separator: "\t").map(String.init)
            guard parts.count >= 4 else { return }
            let percentStr = parts[1].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "%", with: "")
            if let percent = Double(percentStr) {
                items[idx].progressPercent = min(max(percent, 0), 100)
            }
            items[idx].speed = parts[2].trimmingCharacters(in: .whitespaces)
            items[idx].eta = parts[3].trimmingCharacters(in: .whitespaces)
        } else if let range = line.range(of: "Destination: ") {
            let path = String(line[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            discoveredFilePaths[itemID] = path
        } else if line.contains("Merging formats into") {
            if let start = line.firstIndex(of: "\""), let end = line.lastIndex(of: "\""), start < end {
                let path = String(line[line.index(after: start)..<end])
                discoveredFilePaths[itemID] = path
            }
        }
    }

    private func finishProcess(itemID: UUID, exitCode: Int32) {
        processes[itemID] = nil
        guard let idx = items.firstIndex(where: { $0.id == itemID }) else { return }

        if items[idx].status == .cancelled {
            // status already set by the user action
        } else if exitCode == 0 {
            items[idx].status = .completed
            items[idx].progressPercent = 100
            items[idx].finalFilePath = discoveredFilePaths[itemID]
            if settings.showNotifications {
                NotificationManager.shared.notifyCompleted(title: items[idx].title)
            }
        } else {
            items[idx].status = .failed
            items[idx].errorMessage = "yt-dlp è terminato con codice \(exitCode)."
            if settings.showNotifications {
                NotificationManager.shared.notifyFailed(title: items[idx].title)
            }
        }

        discoveredFilePaths[itemID] = nil
        save()
        scheduleNext()
    }

    func cancel(_ id: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        if let process = processes[id], process.isRunning {
            items[idx].status = .cancelled
            process.terminate()
        } else if items[idx].status == .queued || items[idx].status == .fetchingInfo {
            items[idx].status = .cancelled
        }
        save()
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: persistenceURL, options: .atomic)
        } catch {
            // Non-fatal: queue state simply won't be restored next launch.
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: persistenceURL),
              var loaded = try? JSONDecoder().decode([DownloadItem].self, from: data) else { return }

        for i in loaded.indices {
            switch loaded[i].status {
            case .downloading, .fetchingInfo:
                loaded[i].status = .queued
                loaded[i].progressPercent = 0
            default:
                break
            }
        }
        items = loaded
    }
}
