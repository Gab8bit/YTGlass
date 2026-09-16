import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var queue: DownloadQueueManager
    @EnvironmentObject private var clipboard: ClipboardWatcher
    @EnvironmentObject private var updateChecker: UpdateChecker
    @EnvironmentObject private var loc: LocalizationManager

    @State private var showingAddSheet = false
    @State private var prefillURL = ""
    @State private var showingSettings = false

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                header

                if let error = updateChecker.checkError == nil ? nil : updateChecker.checkError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }

                if updateChecker.updateAvailable {
                    updateBanner
                }

                if queue.items.isEmpty {
                    emptyState
                } else {
                    queueList
                }
            }
            .padding(.top, clipboard.detectedURL != nil ? 52 : 0)
            .animation(.easeInOut(duration: 0.2), value: clipboard.detectedURL)

            if let detected = clipboard.detectedURL {
                clipboardBanner(url: detected)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddDownloadView(prefillURL: prefillURL)
                .environmentObject(queue)
                .environmentObject(settings)
                .environmentObject(loc)
        }
        .frame(minWidth: 560, minHeight: 420)
    }

    private var header: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.tint)

                Text("YTGlass")
                    .font(.title3.bold())

                Spacer()

                Button {
                    prefillURL = ""
                    showingAddSheet = true
                } label: {
                    Label(loc.t(.addButton), systemImage: "plus")
                }
                .buttonStyle(.glassProminent)

                SettingsLink {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.glass)
            }
            .padding()
        }
    }

    private var updateBanner: some View {
        HStack {
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .foregroundStyle(.orange)
            Text(loc.t(.updateAvailableTemplate, updateChecker.installedVersion ?? "?", updateChecker.latestVersion ?? "?"))
                .font(.callout)
            Spacer()
            Button(loc.t(.updateNow)) {
                runBrewUpgrade()
            }
            .buttonStyle(.glass)
        }
        .padding(10)
        .padding(.horizontal, 8)
        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
        .padding(.top, 6)
    }

    private func clipboardBanner(url: String) -> some View {
        HStack {
            Image(systemName: "link")
            Text(loc.t(.clipboardDetected))
                .font(.callout)
            Spacer()
            Button(loc.t(.addButton)) {
                prefillURL = url
                clipboard.dismiss()
                showingAddSheet = true
            }
            .buttonStyle(.glassProminent)
            Button(loc.t(.ignore)) {
                clipboard.dismiss()
            }
            .buttonStyle(.glass)
        }
        .padding(10)
        .padding(.horizontal, 8)
        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray.and.arrow.down")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(loc.t(.emptyQueueTitle))
                .font(.headline)
            Text(loc.t(.emptyQueueSubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var queueList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(Array(queue.items.enumerated()), id: \.element.id) { index, item in
                    QueueRowView(item: item, isFirst: index == 0, isLast: index == queue.items.count - 1)
                        .environmentObject(queue)
                }
            }
            .padding()
        }
        .scrollContentBackground(.hidden)
    }

    private func runBrewUpgrade() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["brew", "upgrade", "yt-dlp"]
        process.terminationHandler = { _ in
            Task { @MainActor in
                await updateChecker.check()
            }
        }
        try? process.run()
    }
}
