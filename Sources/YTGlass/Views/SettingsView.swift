import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var clipboard: ClipboardWatcher
    @EnvironmentObject private var updateChecker: UpdateChecker
    @EnvironmentObject private var loc: LocalizationManager

    @State private var isImportingFolder = false

    var body: some View {
        Form {
            Section(loc.t(.languageSection)) {
                Picker(loc.t(.languageLabel), selection: $loc.preference) {
                    Text(loc.t(.languageSystem)).tag(LanguagePreference.system)
                    Text(loc.t(.languageItalian)).tag(LanguagePreference.italian)
                    Text(loc.t(.languageEnglish)).tag(LanguagePreference.english)
                }
            }

            Section(loc.t(.settingsDownloadSection)) {
                HStack {
                    Text(loc.t(.destinationFolder))
                    Spacer()
                    Text(settings.destinationFolder.path)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Button(loc.t(.chooseFolder)) {
                        isImportingFolder = true
                    }
                }

                Stepper(value: $settings.maxConcurrentDownloads, in: 1...5) {
                    Text(loc.t(.simultaneousDownloadsTemplate, settings.maxConcurrentDownloads))
                }

                Toggle(loc.t(.defaultSubtitlesToggle), isOn: $settings.defaultSubtitles)
            }

            Section(loc.t(.behaviorSection)) {
                Toggle(loc.t(.autoCheckUpdatesToggle), isOn: $settings.autoCheckUpdates)
                Toggle(loc.t(.clipboardMonitorToggle), isOn: $settings.monitorClipboard)
                    .onChange(of: settings.monitorClipboard) { _, newValue in
                        if newValue { clipboard.start() } else { clipboard.stop() }
                    }
                Toggle(loc.t(.notificationsToggle), isOn: $settings.showNotifications)
            }

            Section(loc.t(.ytdlpSection)) {
                HStack {
                    Text(loc.t(.installedVersion))
                    Spacer()
                    Text(updateChecker.installedVersion ?? loc.t(.unknownVersion))
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text(loc.t(.latestVersion))
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
                        Text(loc.t(.checkNow))
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
