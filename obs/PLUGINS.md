# OBS Plugins — Pinned Versions

OBS plugins are the most fragile layer of the streaming stack. Document tested versions here so you can recover if an update breaks things.

**Last verified:** 2026-04-26 on OBS 32.1.2 (macOS Sonoma 14.8.5, Apple Silicon)

---

## obs-backgroundremoval (for Webcam Reaction Cam)

**Purpose:** AI background removal for webcam feed — no green screen needed. Uses CoreML on Apple Silicon for low CPU cost.

**Tested version:** v1.1.13 (2026-04 release)

**Install:**

1. Download the macOS `.pkg` from: https://github.com/locaal-ai/obs-backgroundremoval/releases/tag/v1.1.13
2. Specifically: `obs-backgroundremoval-1.1.13-macos-universal.pkg`
3. Quit OBS first
4. Run the .pkg installer
5. Re-launch OBS
6. Verify: in OBS → Filters dropdown should now include "Background Removal"

**Model file:** the plugin downloads its CoreML model on first use (~30MB). Stored at `~/Library/Application Support/obs-studio/plugin_config/obs-backgroundremoval/`

**Settings (recommended):**

| 🟣 Setting | 🟣 Value | 🟣 Why |
|---|---|---|
| Segmentation Model | `MediaPipe Selfie (CoreML)` | Best quality on Apple Silicon, ~1% CPU |
| Inference Device | `CoreML (CPU + GPU)` | Uses Apple's Neural Engine if available |
| Mask Threshold | `0.50` | Default; tune higher to be more aggressive |
| Feathering | `0.10` | Soft edges around hair/face |
| Background | Transparent | So OBS can composite over the screen capture |

**Recovery if breaks after macOS/OBS update:**

```bash
# 1. Check OBS Filters menu — is Background Removal still listed?
# 2. If missing: re-install the .pkg from the version above
# 3. If present but errors: delete plugin model cache, let it re-download:
rm -rf "$HOME/Library/Application Support/obs-studio/plugin_config/obs-backgroundremoval/"
# 4. Restart OBS, re-apply filter, model re-downloads
```

---

## Future plugins to consider

| 🟣 Plugin | 🟣 Purpose | 🟣 Worth it? |
|---|---|---|
| **Move (obs-move-transition)** | Animate source positions between scenes | A-tier — adds gaming-style polish |
| **StreamFX** | 3D transforms, motion blur | B-tier — heavy plugin, diminishing returns for dev streams |
| **obs-shaderfilter** | Custom GLSL shaders | C-tier — specific use cases only |
| **Source Record** | Record per-source separately | A-tier if you want raw footage for editing |

Add to this file as you install + test each.
