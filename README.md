# Project MASON (Batocera sidekick)

Project MASON is Matt's idea — a voice sidekick for Batocera, named after
his son Mason. Grok wrote the v1 code; v2 is a rebuild of his concept.

> **v2 is a full rewrite.** v1 never worked: it ran `pacman` on Batocera
> (Buildroot — no pacman exists), hid every error in `/dev/null`, used a
> pygame window for hotkeys (a game always has focus, so they never fired),
> pointed at a retired Groq model, and never actually installed its
> game-start hook. v2 fixes all of that and is built only from things
> Batocera really has.

## Install (one command, on the Batocera box via SSH or F1 terminal)

```sh
curl -fsSL -o /tmp/mason-install.sh https://raw.githubusercontent.com/NOOBMASTER2099/batocera-grok/mason-v2/mason-install.sh && sh /tmp/mason-install.sh
```

The installer asks once for a Groq API key (free at console.groq.com),
hidden input, stored `chmod 600` in
`/userdata/roms/ports/.data/mason/mason.env` and never printed.
Re-run it anytime to update. `sh mason-install.sh --uninstall` removes it.

Then: **START → GAME SETTINGS → REFRESH GAMELISTS**, open **Ports → MASON**.

## What it is

- **Ports app** (`MASON.sh` → `mason.py`): text menu in xterm — chat with
  MASON, help with the current game, look at the screen (vision),
  settings, daemon control.
- **Game detection that actually works**: `mason-hook.sh` lives in
  `/userdata/system/scripts/` where Batocera really calls `gameStart` /
  `gameStop` scripts, so MASON knows what you're playing.
- **Voice**: Groq Orpheus TTS (`canopylabs/orpheus-v1-english`, voice
  `hannah` by default) via the first available player
  (aplay/paplay/ffplay/mpv).
- **Models (current Groq)**: chat `openai/gpt-oss-20b`, vision
  `qwen/qwen3.8-27b`. No retired model IDs.

## What is experimental (honest label)

- **Voice hotkeys in games** (`mason-daemon.py`, LCTRL+1 help / LCTRL+2
  translate): reads keyboards at the evdev level so it works while a game
  has focus, and answers out loud. It is installed as a Batocera user
  service (`/userdata/system/services/mason`) and can also be started from
  the menu. Screenshots during a DRM/KMS game depend on
  `batocera-screenshot` working there — if no screenshot comes back, the
  daemon answers text-only and says so. This part is **untested on real
  hardware**; the chat app, game detection, and installer are the solid
  core. Logs: `/userdata/roms/ports/.data/mason/mason.log`,
  `daemon.log`.

## Design rules (so v1's failure doesn't repeat)

- Stdlib-only Python. No pip, no pacman, no pygame, no tkinter, no PIL.
- Everything lives under `/userdata` (the only writable tree).
- Errors are printed with the real message, never sent to `/dev/null`
  behind a fake DONE bar.
- Nothing is installed outside the documented Batocera mechanisms:
  Ports `.sh`, `system/scripts` game hooks, `system/services`.

## Files

| File | What |
|---|---|
| `mason-install.sh` | One-shot installer / updater / uninstaller |
| `MASON.sh` | Ports menu launcher |
| `mason.py` | The app (chat, vision, TTS, settings) |
| `mason-daemon.py` | Evdev hotkey daemon (experimental) |
| `mason-hook.sh` | Game start/stop hook |
| `mason-service` | Batocera user service for the daemon |
