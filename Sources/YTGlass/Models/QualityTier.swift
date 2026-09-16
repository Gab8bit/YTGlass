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
        switch self {
        case .best: return "Migliore disponibile"
        case .uhd2160: return "2160p (4K)"
        case .qhd1440: return "1440p (2K)"
        case .fhd1080: return "1080p"
        case .hd720: return "720p"
        case .sd480: return "480p"
        case .worst: return "Più leggera disponibile"
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
