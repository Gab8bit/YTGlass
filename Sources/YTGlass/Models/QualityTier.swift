import Foundation

enum QualityTier: String, CaseIterable, Codable, Identifiable {
    case best
    case uhd2160
    case qhd1440
    case fhd1080
    case hd720
    case sd480
    case worst

    var id: String { rawValue }

    var label: String {
        let loc = LocalizationManager.shared
        switch self {
        case .best: return loc.t(.qualityBest)
        case .uhd2160: return loc.t(.quality2160)
        case .qhd1440: return loc.t(.quality1440)
        case .fhd1080: return loc.t(.quality1080)
        case .hd720: return loc.t(.quality720)
        case .sd480: return loc.t(.quality480)
        case .worst: return loc.t(.qualityWorst)
        }
    }

    /// yt-dlp -f format selector for video+audio.
    var formatSelector: String {
        switch self {
        case .best:
            return "bestvideo*+bestaudio/best"
        case .uhd2160:
            return "bestvideo*[height<=2160]+bestaudio/best[height<=2160]"
        case .qhd1440:
            return "bestvideo*[height<=1440]+bestaudio/best[height<=1440]"
        case .fhd1080:
            return "bestvideo*[height<=1080]+bestaudio/best[height<=1080]"
        case .hd720:
            return "bestvideo*[height<=720]+bestaudio/best[height<=720]"
        case .sd480:
            return "bestvideo*[height<=480]+bestaudio/best[height<=480]"
        case .worst:
            return "worstvideo*+worstaudio/worst"
        }
    }
}
