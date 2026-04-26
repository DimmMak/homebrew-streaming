# Changelog

## [0.4.0] — 2026-04-26 (afternoon)

Mech Cockpit overlay — portrait 1080×1920, cohesive cockpit framing, live ↔ decorative monitor mode, screen-share size presets controllable via Hammerspoon hotkeys.

### Added

**Cohesive portrait cockpit overlay:**
- `obs/browser-sources/cockpit-mech-portrait.html` — full 1080×1920 (YouTube Shorts / Reels dimensions). Single-canvas cockpit framing top-to-bottom (no hard split): side rails with rivets, top status strip (HDG/ALT/SPD/PWR), main monitor frame (decorative or transparent for live), 4 secondary side displays (RADAR/SYS/FUEL/TGT), dashboard divider, pilot zone with 15° tilt slot, 3 control sticks (CYCLIC/THROTTLE/WEAPON), BHC-001 callsign.

**Decorative tactical display** (when monitor in decorative mode):
- Animated radar with sweep + blips
- Live ticker showing NVDA/SPY/VIX/BTC mock data
- Amber + magenta + gunmetal palette throughout

**Live monitor mode** (Caps+V):
- Central monitor area becomes transparent → OBS Window Capture beneath shows through
- Chrome browser content (YouTube reactions / charts / news) appears as the mech's "tactical display"

**Screen-share size presets** (Caps+J/K/L/;):
- `small` — fits inside cockpit monitor frame neatly (immersive)
- `medium` — slight expansion (still framed)
- `large` — covers most of cockpit (immersion break trade-off)
- `fullscreen` — cockpit hidden, pure Chrome (max readability)
- Driven by `data/cockpit-state.json` polled every 1 sec

**Hammerspoon mech bindings:**
- Caps+J/K/L/; — size presets
- Caps+D — DECORATIVE mode (radar + ticker)
- Caps+V — LIVE mode (Chrome window-capture)
- Each writes to cockpit-state.json + shows alert

**Captions server endpoints extended:**
- `/cockpit-mech` — serves the portrait cockpit HTML
- `/cockpit-state.json` — serves the size+mode state file (Hammerspoon writes, HTML reads)

**Hotkey legend updated** (`data/hotkeys.json`):
- Added 6 mech bindings under "mech" category, version bumped to 0.4
- Live legend overlay automatically picks them up within 5 sec

### Manual OBS work required

- `MANUAL_OBS_STEPS.md` — checklist for the OBS GUI work that can't be automated:
  1. Resize OBS canvas to 1080×1920 portrait
  2. Create "Mech Cockpit" scene
  3. Add 3 sources in order: Cockpit Overlay (top) · Webcam (middle) · Chrome Share (bottom)
  4. Audio routing for browser tab audio (BlackHole)
  5. Re-export scene-collection.json

### Notes

- Earlier prototype `obs/browser-sources/cockpit-mech.html` (landscape 1920×1080 with scrolling backdrops) is preserved but superseded by the portrait variant. Backdrops feature deferred — current focus is live screen-share integration.
- True OBS source resize (not just overlay mask) deferred to v0.5 — would need obs-websocket plugin install.

## [0.2.0] — 2026-04-26 (early AM)

OBS polish layer — audio filters + brand overlay + webcam reaction cam scaffolding.

### Added

**Audio filter chain spec** (apply via OBS GUI):
- `obs/filters/mic-filter-chain.md` — broadcast-standard chain: Speex Noise Suppression → Compressor (4:1, -18dB) → Limiter (-1dB)
- Why Speex over RNNoise: faster on Apple Silicon, comparable quality, <0.5% CPU

**Brand-driven lower-third overlay:**
- `data/brand.json` — single source of truth (handle, repos, thesis, rotating taglines)
- `obs/browser-sources/lower-third.html` — fetches brand.json, auto-rotates taglines every 8 sec, reloads JSON every 60 sec for live edits

**Background removal plugin docs:**
- `obs/PLUGINS.md` — pinned versions, install URLs, recovery procedure for obs-backgroundremoval (manual .pkg from royshil/obs-backgroundremoval v1.3.7; v1.1.13 from earlier handoff was a hallucination — corrected 2026-04-26)

**Webcam reaction cam scaffolding:**
- Hammerspoon **Caps+R** hotkey added (in `~/.hammerspoon/init.lua`) — emits F13 globally, OBS catches as "Switch to scene Reaction Cam" hotkey

**Verification:**
- `scripts/verify-effects.sh` — health check for the polish layer (12 checks: audio spec, JSON validity, plugin install, hotkey binding, scene collection export)

### Architecture decisions

- **Audio settings as Markdown spec, not JSON export** — OBS doesn't expose per-source filter chains as portable JSON; the human-readable spec is more durable than reverse-engineering scene collection JSON
- **Lower third reads from brand.json** — single source of truth means editing brand info once propagates to every overlay; no hardcoded strings
- **Plugin install pinned to specific version** — auto-update could break OBS, so we record tested version + recovery steps
- **Scene collection export deferred to manual step** — OBS scene collection JSON is large and machine-specific; documented in verify-effects.sh as a checklist item

### Known limitations

- Audio filter application requires OBS GUI clicks (no CLI for filter chain apply)
- obs-backgroundremoval is .pkg install (not brew) — first-time setup requires manual download
- Webcam scene swap requires OBS-side hotkey binding (Settings → Hotkeys → "Switch to scene Reaction Cam" → F13)

---


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
