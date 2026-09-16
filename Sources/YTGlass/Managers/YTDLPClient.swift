import Foundation

struct VideoInfo {
    var title: String
    var thumbnailURL: String?
    var duration: Double?
    var webpageURL: String
}

enum YTDLPError: Error, LocalizedError {
    case binaryNotFound
    case invalidOutput
    case processFailed(String)

    var errorDescription: String? {
        switch self {
        case .binaryNotFound:
            return LocalizationManager.shared.t(.errorYtdlpNotFound)
        case .invalidOutput:
            return LocalizationManager.shared.t(.errorInvalidResponse)
        case .processFailed(let message):
            return message
        }
    }
}

enum YTDLPClient {

    static func version() throws -> String {
        guard let path = YTDLPLocator.ytdlpPath() else { throw YTDLPError.binaryNotFound }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = ["--version"]
        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    static func fetchSingleInfo(url: String) async throws -> VideoInfo {
        guard let path = YTDLPLocator.ytdlpPath() else { throw YTDLPError.binaryNotFound }

        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = ["-j", "--no-playlist", "--no-warnings", url]
            let outPipe = Pipe()
            let errPipe = Pipe()
            process.standardOutput = outPipe
            process.standardError = errPipe

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()

                guard process.terminationStatus == 0, !outData.isEmpty else {
                    let message = String(data: errData, encoding: .utf8) ?? LocalizationManager.shared.t(.errorCannotReadVideoInfo)
                    continuation.resume(throwing: YTDLPError.processFailed(message))
                    return
                }

                guard let json = try? JSONSerialization.jsonObject(with: outData) as? [String: Any] else {
                    continuation.resume(throwing: YTDLPError.invalidOutput)
                    return
                }

                let title = json["title"] as? String ?? url
                let thumbnail = json["thumbnail"] as? String
                let duration = json["duration"] as? Double
                let webpageURL = json["webpage_url"] as? String ?? url

                continuation.resume(returning: VideoInfo(
                    title: title,
                    thumbnailURL: thumbnail,
                    duration: duration,
                    webpageURL: webpageURL
                ))
            }
        }
    }

    static func fetchPlaylistFlat(url: String) async throws -> [PlaylistEntry] {
        guard let path = YTDLPLocator.ytdlpPath() else { throw YTDLPError.binaryNotFound }

        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = ["--flat-playlist", "-J", "--no-warnings", url]
            let outPipe = Pipe()
            let errPipe = Pipe()
            process.standardOutput = outPipe
            process.standardError = errPipe

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()

                guard process.terminationStatus == 0, !outData.isEmpty else {
                    let message = String(data: errData, encoding: .utf8) ?? LocalizationManager.shared.t(.errorCannotReadPlaylist)
                    continuation.resume(throwing: YTDLPError.processFailed(message))
                    return
                }

                guard let json = try? JSONSerialization.jsonObject(with: outData) as? [String: Any] else {
                    continuation.resume(throwing: YTDLPError.invalidOutput)
                    return
                }

                guard let entries = json["entries"] as? [[String: Any]] else {
                    // Not actually a playlist: treat as a single entry.
                    let title = json["title"] as? String ?? url
                    let thumbnail = json["thumbnail"] as? String
                    continuation.resume(returning: [PlaylistEntry(url: url, title: title, thumbnailURL: thumbnail)])
                    return
                }

                let results: [PlaylistEntry] = entries.compactMap { entry in
                    let title = entry["title"] as? String ?? LocalizationManager.shared.t(.untitledVideo)
                    var entryURL = entry["webpage_url"] as? String ?? entry["url"] as? String
                    if let u = entryURL, !u.lowercased().hasPrefix("http") {
                        entryURL = nil
                    }
                    guard let finalURL = entryURL else { return nil }

                    var thumbnail: String?
                    if let thumbnails = entry["thumbnails"] as? [[String: Any]], let last = thumbnails.last {
                        thumbnail = last["url"] as? String
                    } else {
                        thumbnail = entry["thumbnail"] as? String
                    }

                    return PlaylistEntry(url: finalURL, title: title, thumbnailURL: thumbnail)
                }
                continuation.resume(returning: results)
            }
        }
    }

    /// Builds the yt-dlp arguments for downloading a single item.
    static func downloadArguments(for item: DownloadItem, settings: AppSettings) -> [String] {
        var args: [String] = ["--newline", "--no-color", "--no-warnings"]

        if let ffmpeg = YTDLPLocator.ffmpegPath() {
            let ffmpegDir = (ffmpeg as NSString).deletingLastPathComponent
            args += ["--ffmpeg-location", ffmpegDir]
        }

        let outputTemplate = settings.destinationFolder
            .appendingPathComponent("%(title)s [%(id)s].%(ext)s").path
        args += ["-o", outputTemplate]

        args += ["--progress-template", "download:PROGRESS\t%(progress._percent_str)s\t%(progress._speed_str)s\t%(progress._eta_str)s"]

        if item.audioOnly {
            args += ["-x", "--audio-format", "mp3", "--audio-quality", "0"]
        } else {
            // Keep the requested resolution, but prefer H.264/AAC over VP9/AV1/Opus when
            // both exist at the same resolution — those are the only codecs QuickTime
            // Player can actually decode inside an .mp4 container. Above ~1080p YouTube
            // often only offers VP9/AV1, so this can't help at 1440p/2160p.
            args += ["-S", "res,vcodec:h264,acodec:m4a"]
            args += ["-f", item.quality.formatSelector, "--merge-output-format", "mp4"]
        }

        if item.downloadSubtitles {
            args += ["--write-subs", "--write-auto-sub", "--sub-langs", "it,en", "--convert-subs", "srt"]
        }

        args.append(item.sourceURL)
        return args
    }
}
