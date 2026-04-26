# Changelog

All notable changes to this streaming pipeline.

---

## [0.1.0] — 2026-04-25

Initial pre-launch scaffold.

### Added

**Brand + content prep:**
- `BRAND.md` — one-sentence brand thesis ("OSS-heavy, future-proof, Factorio-brain Claude orchestrator who builds in public") + voice anchors + differentiation thesis (4 wedges)
- `FORMATS.md` — 5 named episode formats (Build-a-Skill · Royal Rumble Live · Future-Proof Friday · Pair with Claude · Autopsy Live) + proposed weekly calendar

**Pre-stream + sanitization:**
- `scripts/pre-stream.sh` — DND on, quit chat apps (Slack/Discord/Messages/Mail/Telegram/Signal/WhatsApp), clear clipboard, hide desktop icons, hide bookmarks bar, auto-hide Dock, mute alert volume, env-var leak scan, start captions server
- `scripts/post-stream.sh` — reverse all of the above
- Hammerspoon hotkeys: **Caps+S** = stream-safe mode, **Caps+N** = normal mode

**Live captions (the differentiator):**
- `obs/browser-sources/live-captions.html` — overlay that reads from local server, fades captions in/out at bottom of stream
- `scripts/captions-server.sh` — Python `http.server` that tails `~/voice/logs/transcripts.jsonl` and serves `/latest` as JSON to OBS browser source

**Clip pipeline:**
- `scripts/mark-moment.sh` — bound to **Caps+M**, appends timestamp to `~/stream/logs/moments.jsonl`
- `scripts/clip-extract.sh` — post-stream ffmpeg cut at each marked moment → 30-sec clips ready for YouTube Shorts

**Health + ops:**
- `scripts/verify-stream.sh` — 19-check health audit (tools, voice pipeline, scripts, OBS assets, network)
- `scripts/bandwidth-test.sh` — speedtest-cli wrapper with bitrate guidance

**Content compounding:**
- `scripts/compound.sh` — post-stream → drafts tweet thread, blog post seed, YouTube description (with chapter markers from moments.jsonl), GitHub README cross-link suggestions

**Dependencies installed:**
- OBS (cask)
- ffmpeg
- speedtest-cli
- BlackHole-2ch — **install pending sudo password** (run manually: `brew install --cask blackhole-2ch`)

### Architecture decisions

- **Live captions via local Python HTTP server** — OBS browser sources can't read local files (CORS). Tiny `http.server` bridge.
- **Clip targets via Hammerspoon hotkey + JSONL** — append-only log, ffmpeg cuts post-stream. Doesn't impact stream performance.
- **Sanitization is reversible** — every `defaults write` has a corresponding revert in post-stream.sh.
- **Brand + formats defined BEFORE first stream** — episode format library prevents content drift.

### Known limitations

- BlackHole-2ch install requires sudo password (system audio driver) — done manually
- macOS may reset TCC perms on update — re-grant OBS for Screen Recording / Mic / Camera
- First stream needs Audio MIDI Setup multi-output device created manually (one-time)
- Stream key vaulting via macOS Keychain — deferred to v0.2.0 (R1 #4 from plan)
