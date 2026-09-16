import Foundation

enum YTDLPLocator {
    private static var cachedYTDLPPath: String?
    private static var cachedFFmpegPath: String?

    static func ytdlpPath() -> String? {
        if let cached = cachedYTDLPPath { return cached }
        let path = locate(binary: "yt-dlp")
        cachedYTDLPPath = path
        return path
    }

    static func ffmpegPath() -> String? {
        if let cached = cachedFFmpegPath { return cached }
        let path = locate(binary: "ffmpeg")
        cachedFFmpegPath = path
        return path
    }

    private static func locate(binary: String) -> String? {
        let commonPaths = [
            "/opt/homebrew/bin/\(binary)",
            "/usr/local/bin/\(binary)",
            "/usr/bin/\(binary)"
        ]
        for path in commonPaths where FileManager.default.isExecutableFile(atPath: path) {
            return path
        }

        // Fall back to resolving via the user's login shell, which picks up
        // Homebrew and any other PATH customization (asdf, custom profiles, etc.)
        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: shell)
        process.arguments = ["-l", "-c", "which \(binary)"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !output.isEmpty,
               FileManager.default.isExecutableFile(atPath: output) {
                return output
            }
        } catch {
            return nil
        }
        return nil
    }
}
