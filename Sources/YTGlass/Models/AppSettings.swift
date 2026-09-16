import Foundation
import Combine

final class AppSettings: ObservableObject {
    private let defaults = UserDefaults.standard

    private enum Key {
        static let destinationFolder = "destinationFolder"
        static let maxConcurrentDownloads = "maxConcurrentDownloads"
        static let autoCheckUpdates = "autoCheckUpdates"
        static let showNotifications = "showNotifications"
        static let monitorClipboard = "monitorClipboard"
        static let defaultSubtitles = "defaultSubtitles"
    }

    @Published var destinationFolder: URL {
        didSet { defaults.set(destinationFolder.path, forKey: Key.destinationFolder) }
    }

    @Published var maxConcurrentDownloads: Int {
        didSet { defaults.set(maxConcurrentDownloads, forKey: Key.maxConcurrentDownloads) }
    }

    @Published var autoCheckUpdates: Bool {
        didSet { defaults.set(autoCheckUpdates, forKey: Key.autoCheckUpdates) }
    }

    @Published var showNotifications: Bool {
        didSet { defaults.set(showNotifications, forKey: Key.showNotifications) }
    }

    @Published var monitorClipboard: Bool {
        didSet { defaults.set(monitorClipboard, forKey: Key.monitorClipboard) }
    }

    @Published var defaultSubtitles: Bool {
        didSet { defaults.set(defaultSubtitles, forKey: Key.defaultSubtitles) }
    }

    init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let defaultDownloads = home.appendingPathComponent("Downloads")

        if let savedPath = defaults.string(forKey: Key.destinationFolder) {
            self.destinationFolder = URL(fileURLWithPath: savedPath)
        } else {
            self.destinationFolder = defaultDownloads
        }

        self.maxConcurrentDownloads = defaults.object(forKey: Key.maxConcurrentDownloads) as? Int ?? 2
        self.autoCheckUpdates = defaults.object(forKey: Key.autoCheckUpdates) as? Bool ?? true
        self.showNotifications = defaults.object(forKey: Key.showNotifications) as? Bool ?? true
        self.monitorClipboard = defaults.object(forKey: Key.monitorClipboard) as? Bool ?? true
        self.defaultSubtitles = defaults.object(forKey: Key.defaultSubtitles) as? Bool ?? false
    }
}
