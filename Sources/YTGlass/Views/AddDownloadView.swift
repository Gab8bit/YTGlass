import SwiftUI

struct AddDownloadView: View {
    @EnvironmentObject private var queue: DownloadQueueManager
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var loc: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    @State private var urlText: String
    @State private var isPlaylist = false
    @State private var audioOnly = false
    @State private var quality: QualityTier = .best
    @State private var downloadSubtitles: Bool

    init(prefillURL: String) {
        _urlText = State(initialValue: prefillURL)
        _downloadSubtitles = State(initialValue: false)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(loc.t(.newDownloadTitle))
                .font(.title3.bold())

            TextField(loc.t(.urlPlaceholder), text: $urlText)
                .textFieldStyle(.roundedBorder)

            Toggle(loc.t(.playlistToggle), isOn: $isPlaylist)

            Picker(loc.t(.formatLabel), selection: $audioOnly) {
                Text(loc.t(.formatVideoOption)).tag(false)
                Text(loc.t(.formatAudioOption)).tag(true)
            }
            .pickerStyle(.segmented)

            if !audioOnly {
                Picker(loc.t(.qualityLabel), selection: $quality) {
                    ForEach(QualityTier.allCases) { tier in
                        Text(tier.label).tag(tier)
                    }
                }
            }

            Toggle(loc.t(.subtitlesToggle), isOn: $downloadSubtitles)

            Spacer(minLength: 0)

            HStack {
                Spacer()
                Button(loc.t(.cancelButton)) { dismiss() }
                    .buttonStyle(.glass)
                Button(loc.t(.addToQueueButton)) {
                    addAndDismiss()
                }
                .buttonStyle(.glassProminent)
                .disabled(!isValidURL)
            }
        }
        .padding(24)
        .frame(width: 440, height: 340)
        .onAppear {
            downloadSubtitles = settings.defaultSubtitles
        }
    }

    private var isValidURL: Bool {
        guard let url = URL(string: urlText.trimmingCharacters(in: .whitespacesAndNewlines)) else { return false }
        return url.scheme?.hasPrefix("http") == true
    }

    private func addAndDismiss() {
        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        if isPlaylist {
            queue.addPlaylist(urlString: trimmed, quality: quality, audioOnly: audioOnly, subtitles: downloadSubtitles)
        } else {
            queue.addSingle(urlString: trimmed, quality: quality, audioOnly: audioOnly, subtitles: downloadSubtitles)
        }
        dismiss()
    }
}
