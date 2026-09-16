import SwiftUI

@main
struct YTGlassApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var queue: DownloadQueueManager
    @StateObject private var clipboard = ClipboardWatcher()
    @StateObject private var updateChecker = UpdateChecker()

    init() {
        let settings = AppSettings()
        _settings = StateObject(wrappedValue: settings)
        _queue = StateObject(wrappedValue: DownloadQueueManager(settings: settings))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(queue)
                .environmentObject(clipboard)
                .environmentObject(updateChecker)
                .frame(minWidth: 560, minHeight: 420)
                .task {
                    NotificationManager.shared.requestAuthorization()
                    if settings.monitorClipboard {
                        clipboard.start()
                    }
                    if settings.autoCheckUpdates {
                        await updateChecker.check()
                    }
                }
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.unifiedCompact)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }

        Settings {
            SettingsView()
                .environmentObject(settings)
                .environmentObject(queue)
                .environmentObject(clipboard)
                .environmentObject(updateChecker)
                .frame(width: 460)
        }
    }
}
