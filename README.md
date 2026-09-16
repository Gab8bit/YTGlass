# YTGlass

Native macOS app (SwiftUI) with a Liquid Glass theme for macOS 26 Tahoe, acting as a frontend for [yt-dlp](https://github.com/yt-dlp/yt-dlp) installed via Homebrew.

## Features

- Download queue with priority reordering (up/down), removal, retry
- Video quality selection or audio-only (MP3) download
- Thumbnail preview, progress bar, real-time speed and ETA
- Support for entire playlists/channels and subtitles
- Automatic clipboard URL detection
- System notifications when a download finishes
- Automatic yt-dlp update check on launch
- Settings: destination folder, number of simultaneous downloads
- English and Italian localization (follows the system language by default, overridable in Settings)

## Requirements

- macOS 26 (Tahoe) or later
- [Homebrew](https://brew.sh) with `yt-dlp` and `ffmpeg` installed:
  ```bash
  brew install yt-dlp ffmpeg
  ```
- Xcode 26+ (to build)

## Build

The project is a Swift Package (no `.xcodeproj`): you can open `Package.swift` directly in Xcode, or from the terminal:

```bash
./build_app.sh
```

which produces `YTGlass.app`, ad-hoc signed and ready to move into `/Applications`.
