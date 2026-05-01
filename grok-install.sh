#!/bin/bash
# === GITHUB BROWSER - Chromium Spin-Off for Batocera ===
# Made for NOOBMASTER99 🚀 Launches straight into GitHub

# Hide mouse cursor while browsing
unclutter-remote -s

# Launch Chromium in clean app mode (no tabs, fullscreen, PWA style)
flatpak run org.chromium.Chromium \
    --app="https://github.com" \
    --window-size=1920,1080 \
    --start-maximized \
    --no-first-run \
    --disable-infobars \
    --disable-translate \
    --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36 GitHub-Batocera"

# Show mouse cursor again when you exit
unclutter-remote -h
