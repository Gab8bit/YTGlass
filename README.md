# YTGlass

App macOS nativa (SwiftUI) con tema Liquid Glass per macOS 26 Tahoe, che fa da frontend a [yt-dlp](https://github.com/yt-dlp/yt-dlp) installato via Homebrew.

## Funzionalità

- Coda di download con riordino priorità (su/giù), rimozione, retry
- Selezione qualità video o download solo audio (MP3)
- Miniatura, progress bar, velocità ed ETA in tempo reale
- Supporto playlist/canali interi e sottotitoli
- Rilevamento automatico di URL negli appunti
- Notifiche di sistema a fine download
- Controllo automatico degli aggiornamenti di yt-dlp all'avvio
- Impostazioni: cartella di destinazione, numero di download simultanei

## Requisiti

- macOS 26 (Tahoe) o successivo
- [Homebrew](https://brew.sh) con `yt-dlp` e `ffmpeg` installati:
  ```bash
  brew install yt-dlp ffmpeg
  ```
- Xcode 26+ (per compilare)

## Build

Il progetto è uno Swift Package (nessun `.xcodeproj`): puoi aprire `Package.swift` direttamente in Xcode, oppure da terminale:

```bash
./build_app.sh
```

produce `YTGlass.app`, firmata ad-hoc e pronta da spostare in `/Applications`.
