import Foundation

final class UpdateChecker: ObservableObject {
    @Published var installedVersion: String?
    @Published var latestVersion: String?
    @Published var isChecking = false
    @Published var checkError: String?

    var updateAvailable: Bool {
        guard let installed = installedVersion, let latest = latestVersion else { return false }
        return installed != latest
    }

    @MainActor
    func check() async {
        isChecking = true
        checkError = nil
        defer { isChecking = false }

        installedVersion = try? YTDLPClient.version()

        guard let url = URL(string: "https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest") else { return }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let tag = json["tag_name"] as? String else {
                checkError = LocalizationManager.shared.t(.errorInvalidGitHubResponse)
                return
            }
            latestVersion = tag
        } catch {
            checkError = LocalizationManager.shared.t(.errorUpdateCheckFailedTemplate, error.localizedDescription)
        }
    }
}
