import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var clipboard: ClipboardWatcher
    @EnvironmentObject private var updateChecker: UpdateChecker

    @State private var isImportingFolder = false

    var body: some View {
        Form {
            Section("Download") {
                HStack {
                    Text("Cartella di destinazione")
                    Spacer()
                    Text(settings.destinationFolder.path)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Button("Scegli…") {
                        isImportingFolder = true
                    }
                }

                Stepper(value: $settings.maxConcurrentDownloads, in: 1...5) {
                    Text("Download simultanei: \(settings.maxConcurrentDownloads)")
                }

                Toggle("Scarica sottotitoli per impostazione predefinita", isOn: $settings.defaultSubtitles)
            }

            Section("Comportamento") {
                Toggle("Controlla aggiornamenti di yt-dlp all'avvio", isOn: $settings.autoCheckUpdates)
                Toggle("Rileva automaticamente URL negli appunti", isOn: $settings.monitorClipboard)
                    .onChange(of: settings.monitorClipboard) { _, newValue in
                        if newValue { clipboard.start() } else { clipboard.stop() }
                    }
                Toggle("Notifiche di sistema a fine download", isOn: $settings.showNotifications)
            }

            Section("yt-dlp") {
                HStack {
                    Text("Versione installata")
                    Spacer()
                    Text(updateChecker.installedVersion ?? "sconosciuta")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Ultima versione disponibile")
                    Spacer()
                    Text(updateChecker.latestVersion ?? "—")
                        .foregroundStyle(.secondary)
                }
                Button {
                    Task { await updateChecker.check() }
                } label: {
                    if updateChecker.isChecking {
                        ProgressView().controlSize(.small)
                    } else {
                        Text("Verifica ora")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .fileImporter(isPresented: $isImportingFolder, allowedContentTypes: [.folder]) { result in
            if case .success(let url) = result {
                settings.destinationFolder = url
            }
        }
    }
}
