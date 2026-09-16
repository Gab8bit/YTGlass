import SwiftUI

struct AddDownloadView: View {
    @EnvironmentObject private var queue: DownloadQueueManager
    @EnvironmentObject private var settings: AppSettings
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
            Text("Nuovo download")
                .font(.title3.bold())

            TextField("Incolla un link (YouTube e non solo)…", text: $urlText)
                .textFieldStyle(.roundedBorder)

            Toggle("È una playlist o un canale intero", isOn: $isPlaylist)

            Picker("Formato", selection: $audioOnly) {
                Text("Video (con audio)").tag(false)
                Text("Solo audio (MP3)").tag(true)
            }
            .pickerStyle(.segmented)

            if !audioOnly {
                Picker("Qualità", selection: $quality) {
                    ForEach(QualityTier.allCases) { tier in
                        Text(tier.label).tag(tier)
                    }
                }
            }

            Toggle("Scarica sottotitoli (se disponibili)", isOn: $downloadSubtitles)

            Spacer(minLength: 0)

            HStack {
                Spacer()
                Button("Annulla") { dismiss() }
                    .buttonStyle(.glass)
                Button("Aggiungi alla coda") {
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
