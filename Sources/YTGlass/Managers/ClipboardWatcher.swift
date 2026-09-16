import AppKit
import Combine

final class ClipboardWatcher: ObservableObject {
    @Published var detectedURL: String?

    private var timer: Timer?
    private var lastChangeCount: Int = NSPasteboard.general.changeCount
    private var lastHandledURL: String?

    func start() {
        stop()
        lastChangeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.pollPasteboard()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func dismiss() {
        detectedURL = nil
    }

    private func pollPasteboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        guard let text = pasteboard.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines),
              let url = Self.extractURL(from: text) else { return }

        guard url != lastHandledURL else { return }
        lastHandledURL = url
        detectedURL = url
    }

    static func extractURL(from text: String) -> String? {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = detector.firstMatch(in: text, range: range),
              let matchRange = Range(match.range, in: text) else { return nil }
        let candidate = String(text[matchRange])
        guard candidate.lowercased().hasPrefix("http") else { return nil }
        return candidate
    }
}
