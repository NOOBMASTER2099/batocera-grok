# MASON Changelog

The setup site (`docs/index.html`) mirrors this file.

## v2.0 — 2026-11-04 — full rewrite

- Rebuilt for Batocera as it actually is: stdlib-only Python, no pacman, no
  pip, no pygame, no tkinter, no PIL.
- One-shot installer with loud failures and a `py_compile` self-check — no
  more fake DONE bars over dead steps.
- Game detection actually installed where Batocera calls it
  (`/userdata/system/scripts/`, gameStart/gameStop).
- Hotkeys read the keyboard at the evdev level, so they work while a game
  has focus.
- Daemon runs as a proper Batocera user service (v38+).
- Current Groq models: chat `openai/gpt-oss-20b`, vision `qwen/qwen3.8-27b`,
  TTS `canopylabs/orpheus-v1-english` (voice `hannah`).
- Errors print the real message instead of "Error contacting Groq."
- Voice hotkey daemon + in-game screenshots: **experimental, untested on
  real hardware.** Chat, game detection, and the installer are the solid
  core.
- Setup site added (`docs/index.html`): install guide, how it works,
  troubleshooting, update notes.

## v1.6 — retired, did not work

- Ran `pacman` on Batocera (Buildroot — pacman doesn't exist), so nothing it
  tried to install ever installed.
- Hid every install error in `/dev/null` while printing DONE.
- Hotkeys used a pygame window that never has focus during a game.
- Pointed at the retired `llama-3.2-11b-vision-preview` model.
- Game-start hook was written to a folder Batocera never calls.
