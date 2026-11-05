#!/bin/bash
# MASON v2 -- Batocera game start/stop hook.
# Installed by mason-install.sh to /userdata/system/scripts/mason-game.sh
# Batocera calls every executable script in that dir with:
#   $1 = gameStart | gameStop, $2 = system, $3 = emulator, $4 = core,
#   $5 = full rom path
# (The v1 installer wrote a hook file but never put it here, so game
# detection never worked. This one actually lives in the right place.)
DIR="/userdata/roms/ports/.data/mason"
case "$1" in
    gameStart)
        mkdir -p "$DIR"
        python3 - "$2" "$5" <<'PY' > /dev/null 2>&1
import json, os, sys
game = os.path.splitext(os.path.basename(sys.argv[2]))[0]
data = {"game": game, "system": sys.argv[1], "rom": sys.argv[2],
        "timestamp": __import__("time").strftime("%Y-%m-%d %H:%M:%S")}
with open("/userdata/roms/ports/.data/mason/current-game.json", "w") as f:
    json.dump(data, f)
PY
        ;;
    gameStop)
        rm -f "$DIR/current-game.json"
        ;;
esac
exit 0
