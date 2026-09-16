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
        switch self {
        case .queued: return "In coda"
        case .fetchingInfo: return "Recupero informazioni…"
        case .downloading: return "Download in corso"
        case .paused: return "In pausa"
        case .completed: return "Completato"
        case .failed: return "Fallito"
        case .cancelled: return "Annullato"
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
