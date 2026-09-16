import SwiftUI
import AppKit

struct QueueRowView: View {
    let item: DownloadItem
    let isFirst: Bool
    let isLast: Bool

    @EnvironmentObject private var queue: DownloadQueueManager
    @EnvironmentObject private var loc: LocalizationManager

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)

                HStack(spacing: 6) {
                    badge(item.audioOnly ? "MP3" : item.quality.label, systemImage: item.audioOnly ? "music.note" : "video")
                    if item.downloadSubtitles {
                        badge(loc.t(.subtitlesBadge), systemImage: "captions.bubble")
                    }
                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if item.status == .downloading || item.status == .paused {
                    ProgressView(value: item.progressPercent, total: 100)
                        .tint(.accentColor)
                    HStack {
                        if !item.speed.isEmpty { Text(item.speed) }
                        if !item.eta.isEmpty { Text("ETA \(item.eta)") }
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                } else if item.status == .queued {
                    ProgressView(value: 0, total: 100)
                        .tint(.secondary)
                        .opacity(0.4)
                }

                if let errorMessage = item.errorMessage, item.status == .failed {
                    Text(errorMessage)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 0)

            controls
        }
        .padding(10)
        .glassEffect(in: RoundedRectangle(cornerRadius: 16))
    }

    private var thumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.quaternary)
            if let urlString = item.thumbnailURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        placeholderIcon
                    }
                }
            } else {
                placeholderIcon
            }
        }
        .frame(width: 84, height: 54)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var placeholderIcon: some View {
        Image(systemName: item.audioOnly ? "music.note" : "film")
            .foregroundStyle(.secondary)
    }

    private var statusText: String {
        if item.status == .downloading {
            return "\(Int(item.progressPercent))%"
        }
        return item.status.label
    }

    private func badge(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.secondary.opacity(0.15), in: Capsule())
    }

    @ViewBuilder
    private var controls: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Button {
                    queue.moveUp(item.id)
                } label: {
                    Image(systemName: "chevron.up")
                }
                .disabled(isFirst)

                Button {
                    queue.moveDown(item.id)
                } label: {
                    Image(systemName: "chevron.down")
                }
                .disabled(isLast)
            }

            HStack(spacing: 4) {
                if item.status == .failed {
                    Button {
                        queue.retry(item.id)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }

                if item.status == .completed, let path = item.finalFilePath {
                    Button {
                        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
                    } label: {
                        Image(systemName: "folder")
                    }
                }

                Button(role: .destructive) {
                    queue.remove(item.id)
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .buttonStyle(.borderless)
        .font(.body)
    }
}
