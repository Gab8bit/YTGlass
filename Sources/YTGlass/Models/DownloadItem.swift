import Foundation

enum DownloadStatus: String, Codable {
    case queued
    case fetchingInfo
    case downloading
    case paused
    case completed
    case failed
    case cancelled

    var label: String {
        let loc = LocalizationManager.shared
        switch self {
        case .queued: return loc.t(.statusQueued)
        case .fetchingInfo: return loc.t(.statusFetchingInfo)
        case .downloading: return loc.t(.statusDownloading)
        case .paused: return loc.t(.statusPaused)
        case .completed: return loc.t(.statusCompleted)
        case .failed: return loc.t(.statusFailed)
        case .cancelled: return loc.t(.statusCancelled)
        }
    }
}

struct DownloadItem: Identifiable, Codable, Equatable {
    let id: UUID
    var sourceURL: String
    var title: String
    var thumbnailURL: String?
    var duration: Double?

    var quality: QualityTier
    var audioOnly: Bool
    var downloadSubtitles: Bool

    var status: DownloadStatus
    var progressPercent: Double
    var speed: String
    var eta: String
    var errorMessage: String?
    var finalFilePath: String?

    var dateAdded: Date

    init(
        sourceURL: String,
        title: String,
        thumbnailURL: String? = nil,
        duration: Double? = nil,
        quality: QualityTier,
        audioOnly: Bool,
        downloadSubtitles: Bool
    ) {
        self.id = UUID()
        self.sourceURL = sourceURL
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.duration = duration
        self.quality = quality
        self.audioOnly = audioOnly
        self.downloadSubtitles = downloadSubtitles
        self.status = .queued
        self.progressPercent = 0
        self.speed = ""
        self.eta = ""
        self.errorMessage = nil
        self.finalFilePath = nil
        self.dateAdded = Date()
    }
}

struct PlaylistEntry {
    var url: String
    var title: String
    var thumbnailURL: String?
}
