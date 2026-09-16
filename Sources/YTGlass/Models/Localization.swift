import Foundation

enum AppLanguage: String, Codable {
    case italian = "it"
    case english = "en"
}

enum LanguagePreference: String, CaseIterable, Codable, Identifiable {
    case system
    case italian
    case english

    var id: String { rawValue }
}

enum LocKey: String {
    case addButton
    case updateAvailableTemplate
    case updateNow
    case clipboardDetected
    case ignore
    case emptyQueueTitle
    case emptyQueueSubtitle

    case statusQueued
    case statusFetchingInfo
    case statusDownloading
    case statusPaused
    case statusCompleted
    case statusFailed
    case statusCancelled
    case subtitlesBadge
    case codecWarningBadge
    case codecWarningTooltipTemplate

    case newDownloadTitle
    case urlPlaceholder
    case playlistToggle
    case formatLabel
    case formatVideoOption
    case formatAudioOption
    case qualityLabel
    case subtitlesToggle
    case cancelButton
    case addToQueueButton

    case qualityBest
    case quality2160
    case quality1440
    case quality1080
    case quality720
    case quality480
    case qualityWorst

    case settingsDownloadSection
    case destinationFolder
    case chooseFolder
    case simultaneousDownloadsTemplate
    case defaultSubtitlesToggle
    case behaviorSection
    case autoCheckUpdatesToggle
    case clipboardMonitorToggle
    case notificationsToggle
    case ytdlpSection
    case installedVersion
    case unknownVersion
    case latestVersion
    case checkNow
    case languageSection
    case languageLabel
    case languageSystem
    case languageItalian
    case languageEnglish

    case errorYtdlpNotFound
    case errorInvalidResponse
    case errorCannotReadVideoInfo
    case errorCannotReadPlaylist
    case errorProcessExitCodeTemplate
    case errorInvalidGitHubResponse
    case errorUpdateCheckFailedTemplate
    case untitledVideo
    case fetchingPlaylistTitle
    case notificationCompletedTitle
    case notificationFailedTitle
}

private let italianStrings: [LocKey: String] = [
    .addButton: "Aggiungi",
    .updateAvailableTemplate: "Aggiornamento yt-dlp disponibile: %@ → %@",
    .updateNow: "Aggiorna ora",
    .clipboardDetected: "URL rilevato negli appunti",
    .ignore: "Ignora",
    .emptyQueueTitle: "Nessun download in coda",
    .emptyQueueSubtitle: "Incolla un link o premi “Aggiungi” per iniziare.",

    .statusQueued: "In coda",
    .statusFetchingInfo: "Recupero informazioni…",
    .statusDownloading: "Download in corso",
    .statusPaused: "In pausa",
    .statusCompleted: "Completato",
    .statusFailed: "Fallito",
    .statusCancelled: "Annullato",
    .subtitlesBadge: "Sottotitoli",
    .codecWarningBadge: "Possibile incompatibilità",
    .codecWarningTooltipTemplate: "Alcuni lettori (come QuickTime Player) potrebbero non riuscire a riprodurre il video di questo file, codificato in %@. Prova a scaricarlo a 1080p o inferiore, oppure usa un lettore come VLC.",

    .newDownloadTitle: "Nuovo download",
    .urlPlaceholder: "Incolla un link (YouTube e non solo)…",
    .playlistToggle: "È una playlist o un canale intero",
    .formatLabel: "Formato",
    .formatVideoOption: "Video (con audio)",
    .formatAudioOption: "Solo audio (MP3)",
    .qualityLabel: "Qualità",
    .subtitlesToggle: "Scarica sottotitoli (se disponibili)",
    .cancelButton: "Annulla",
    .addToQueueButton: "Aggiungi alla coda",

    .qualityBest: "Migliore disponibile",
    .quality2160: "2160p (4K)",
    .quality1440: "1440p (2K)",
    .quality1080: "1080p",
    .quality720: "720p",
    .quality480: "480p",
    .qualityWorst: "Più leggera disponibile",

    .settingsDownloadSection: "Download",
    .destinationFolder: "Cartella di destinazione",
    .chooseFolder: "Scegli…",
    .simultaneousDownloadsTemplate: "Download simultanei: %d",
    .defaultSubtitlesToggle: "Scarica sottotitoli per impostazione predefinita",
    .behaviorSection: "Comportamento",
    .autoCheckUpdatesToggle: "Controlla aggiornamenti di yt-dlp all'avvio",
    .clipboardMonitorToggle: "Rileva automaticamente URL negli appunti",
    .notificationsToggle: "Notifiche di sistema a fine download",
    .ytdlpSection: "yt-dlp",
    .installedVersion: "Versione installata",
    .unknownVersion: "sconosciuta",
    .latestVersion: "Ultima versione disponibile",
    .checkNow: "Verifica ora",
    .languageSection: "Lingua",
    .languageLabel: "Lingua dell'app",
    .languageSystem: "Automatica (sistema)",
    .languageItalian: "Italiano",
    .languageEnglish: "Inglese",

    .errorYtdlpNotFound: "yt-dlp non è stato trovato. Installalo con Homebrew: brew install yt-dlp",
    .errorInvalidResponse: "Risposta di yt-dlp non valida.",
    .errorCannotReadVideoInfo: "Impossibile leggere le informazioni del video.",
    .errorCannotReadPlaylist: "Impossibile leggere la playlist.",
    .errorProcessExitCodeTemplate: "yt-dlp è terminato con codice %d.",
    .errorInvalidGitHubResponse: "Risposta GitHub non valida.",
    .errorUpdateCheckFailedTemplate: "Impossibile verificare gli aggiornamenti: %@",
    .untitledVideo: "Video senza titolo",
    .fetchingPlaylistTitle: "Recupero playlist…",
    .notificationCompletedTitle: "Download completato",
    .notificationFailedTitle: "Download fallito"
]

private let englishStrings: [LocKey: String] = [
    .addButton: "Add",
    .updateAvailableTemplate: "yt-dlp update available: %@ → %@",
    .updateNow: "Update now",
    .clipboardDetected: "URL detected in clipboard",
    .ignore: "Ignore",
    .emptyQueueTitle: "No downloads queued",
    .emptyQueueSubtitle: "Paste a link or tap “Add” to get started.",

    .statusQueued: "Queued",
    .statusFetchingInfo: "Fetching info…",
    .statusDownloading: "Downloading",
    .statusPaused: "Paused",
    .statusCompleted: "Completed",
    .statusFailed: "Failed",
    .statusCancelled: "Cancelled",
    .subtitlesBadge: "Subtitles",
    .codecWarningBadge: "Possible incompatibility",
    .codecWarningTooltipTemplate: "Some players (like QuickTime Player) may not be able to play the video in this file, encoded in %@. Try downloading it at 1080p or lower, or use a player like VLC.",

    .newDownloadTitle: "New download",
    .urlPlaceholder: "Paste a link (YouTube and more)…",
    .playlistToggle: "This is a playlist or entire channel",
    .formatLabel: "Format",
    .formatVideoOption: "Video (with audio)",
    .formatAudioOption: "Audio only (MP3)",
    .qualityLabel: "Quality",
    .subtitlesToggle: "Download subtitles (if available)",
    .cancelButton: "Cancel",
    .addToQueueButton: "Add to queue",

    .qualityBest: "Best available",
    .quality2160: "2160p (4K)",
    .quality1440: "1440p (2K)",
    .quality1080: "1080p",
    .quality720: "720p",
    .quality480: "480p",
    .qualityWorst: "Smallest available",

    .settingsDownloadSection: "Download",
    .destinationFolder: "Destination folder",
    .chooseFolder: "Choose…",
    .simultaneousDownloadsTemplate: "Simultaneous downloads: %d",
    .defaultSubtitlesToggle: "Download subtitles by default",
    .behaviorSection: "Behavior",
    .autoCheckUpdatesToggle: "Check for yt-dlp updates on launch",
    .clipboardMonitorToggle: "Automatically detect URLs in clipboard",
    .notificationsToggle: "System notifications when downloads finish",
    .ytdlpSection: "yt-dlp",
    .installedVersion: "Installed version",
    .unknownVersion: "unknown",
    .latestVersion: "Latest version available",
    .checkNow: "Check now",
    .languageSection: "Language",
    .languageLabel: "App language",
    .languageSystem: "Automatic (system)",
    .languageItalian: "Italian",
    .languageEnglish: "English",

    .errorYtdlpNotFound: "yt-dlp was not found. Install it with Homebrew: brew install yt-dlp",
    .errorInvalidResponse: "Invalid response from yt-dlp.",
    .errorCannotReadVideoInfo: "Could not read video information.",
    .errorCannotReadPlaylist: "Could not read the playlist.",
    .errorProcessExitCodeTemplate: "yt-dlp exited with code %d.",
    .errorInvalidGitHubResponse: "Invalid response from GitHub.",
    .errorUpdateCheckFailedTemplate: "Could not check for updates: %@",
    .untitledVideo: "Untitled video",
    .fetchingPlaylistTitle: "Fetching playlist…",
    .notificationCompletedTitle: "Download completed",
    .notificationFailedTitle: "Download failed"
]

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    private let defaults = UserDefaults.standard
    private let key = "languagePreference"

    @Published var preference: LanguagePreference {
        didSet { defaults.set(preference.rawValue, forKey: key) }
    }

    var effectiveLanguage: AppLanguage {
        switch preference {
        case .italian: return .italian
        case .english: return .english
        case .system:
            let preferred = Locale.preferredLanguages.first ?? "en"
            return preferred.lowercased().hasPrefix("it") ? .italian : .english
        }
    }

    private init() {
        if let saved = defaults.string(forKey: key), let pref = LanguagePreference(rawValue: saved) {
            self.preference = pref
        } else {
            self.preference = .system
        }
    }

    private var table: [LocKey: String] {
        effectiveLanguage == .italian ? italianStrings : englishStrings
    }

    func t(_ key: LocKey) -> String {
        table[key] ?? key.rawValue
    }

    func t(_ key: LocKey, _ args: CVarArg...) -> String {
        let format = table[key] ?? key.rawValue
        return String(format: format, arguments: args)
    }
}
