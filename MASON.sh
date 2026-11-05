#!/bin/bash
# MASON v2 -- Ports menu launcher.
# Installed by mason-install.sh to /userdata/roms/ports/MASON.sh
# Ports run under X on Batocera, and xterm ships with Batocera
# (F1 > Applications), so the text menu runs inside xterm.
DIR="$(dirname "$(readlink -f "$0")")/.data/mason"
cd "$DIR" || exit 1
export DISPLAY=:0.0
command -v unclutter-remote >/dev/null 2>&1 && unclutter-remote -s
if command -v xterm >/dev/null 2>&1; then
    xterm -fa Monospace -fs 13 -e python3 "$DIR/mason.py" --menu
else
    python3 "$DIR/mason.py" --menu >> "$DIR/launcher.log" 2>&1
fi
command -v unclutter-remote >/dev/null 2>&1 && unclutter-remote -h
