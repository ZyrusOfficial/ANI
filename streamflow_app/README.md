# StreamFlow

<div align="center">
  <img src="assets/web/pages/screen.png" alt="StreamFlow Logo" width="150" height="auto" />
  <h3>Premium OLED Anime Streaming Experience</h3>
</div>

StreamFlow is a beautiful, cross-platform anime streaming application built with Flutter. It focuses on delivering a visually stunning, OLED-friendly interface with a robust, direct-scraping streaming pipeline.

## ✨ Features

- **OLED-Optimized UI**: Deep blacks and vibrant accents designed specifically for premium displays.
- **Native Video Playback**: High-performance video rendering via `media_kit`, supporting direct MP4 and M3U8 (HLS) streams.
- **Cross-Platform**: Built for Linux, Windows, and Android.
- **No Self-Hosted Backend Required**: Streams are resolved directly on the client device.
- **Smart Progress Tracking**: Automatically saves watch history and playback progression locally.

---

## ⚙️ How It Works (Architecture)

Unlike many anime apps that rely on third-party aggregator APIs (which frequently go down), StreamFlow implements its own scraping and decryption pipeline directly in Dart.

### 1. Metadata (The UI)
We use the **Jikan API (Unofficial MyAnimeList API)** to fetch all metadata. This provides highly stable and accurate data for anime details, cover images, descriptions, characters, and recommendations.

### 2. The Streaming Pipeline (`AllAnimeApiService`)
When you play an episode, StreamFlow executes a multi-step pipeline (inspired by `ani-cli`) directly on your device:
1. **GraphQL Search**: Queries `api.allanime.day` to find the internal Show ID, intelligently filtering by episode count and exact name matches to ensure we don't accidentally pick a 1-episode OVA or special.
2. **Fetch Sources**: Retrieves encrypted source URLs for the specific episode.
3. **Decryption**: Uses a custom hex cipher map to decrypt the source URLs.
4. **Link Extraction**: Parses provider endpoints (like `clock.json`) or direct CDN links to extract the final `.m3u8` or `.mp4` video streams.
5. **Video Playback**: Streams are sorted by priority (Direct M3U8 > Direct MP4 > Embeds) and fed into the `media_kit` native player.

### 3. Fallback (`GogoScraperService`)
To ensure high availability, if the primary AllAnime pipeline fails, StreamFlow seamlessly falls back to an HTML scraper that parses Gogoanime (`anitaku.to`) and extracts encrypted AES-128 M3U8 streams.

---

## 🚀 Future Enhancements (Roadmap)

StreamFlow is functional, but there is always room to grow. Planned features include:

- **Anilist/MAL Integration**: Sync your watch history and lists directly with your Anilist or MyAnimeList account.
- **Offline Downloads**: Background downloading of episodes for offline viewing.
- **Mobile UX Polish**: Add gesture controls (swipe for brightness/volume) in the mobile video player.
- **Provider Plugin System**: Create an extensible architecture to easily add and update new streaming providers without altering core app logic.
- **Hardware Acceleration Fixes**: Currently, Linux defaults to software rendering (`hwdec=no`) to bypass a Wayland texture sharing bug in `media_kit`. Re-enabling stable GPU acceleration on Wayland is a priority.

---

## 🤝 Help Wanted / Contributing

Because this app scrapes streaming sites directly, the DOM structures, GraphQL endpoints, and encryption keys we rely on will inevitably change. **We need your help to keep the streams flowing!**

We are actively looking for contributors to help with:
- **Maintaining Scrapers**: Updating `AllAnimeApiService` or `GogoScraperService` when sites change their APIs or encryption methods.
- **Adding New Providers**: Building new scraper integrations to increase redundancy.
- **Linux/Wayland Gurus**: Helping resolve the `media_kit` GPU texture sharing issue on Wayland.
- **UI/UX Designers**: Improving the application flow and adding new animations.

### How to run locally
1. Install [Flutter](https://docs.flutter.dev/get-started/install).
2. Clone this repository.
3. Run `flutter pub get` in the `streamflow_app` directory.
4. Run `flutter run -d linux` (or windows/android).

Feel free to open Issues for bugs or feature requests, and submit Pull Requests!
