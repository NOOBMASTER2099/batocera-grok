#!/bin/bash
# ============================================================
# MASON v2 -- one-shot installer for Batocera. No pacman, no pip,
# no packages: Batocera has no package manager and a read-only
# rootfs, so this only downloads plain files into /userdata
# (the one writable tree) and wires up Batocera's real hooks.
#
# Run ON the Batocera box (SSH or F1 terminal), one command:
#   curl -fsSL -o /tmp/mason-install.sh \
#     https://raw.githubusercontent.com/NOOBMASTER2099/batocera-grok/mason-v2/mason-install.sh \
#     && sh /tmp/mason-install.sh
# Re-run anytime to update.  sh mason-install.sh --uninstall to remove.
# The only thing it asks you is your Groq API key (once, hidden input).
# ============================================================
set -u
REPO="NOOBMASTER2099/batocera-grok"
BRANCH="${MASON_BRANCH:-mason-v2}"
RAW="https://raw.githubusercontent.com/$REPO/$BRANCH"
DIR="/userdata/roms/ports/.data/mason"
PORTS="/userdata/roms/ports"
HOOK="/userdata/system/scripts/mason-game.sh"
SERVICE="/userdata/system/services/mason"

say()  { printf '%s\n' "$*"; }
fail() { printf 'FAILED: %s\n' "$*" >&2; exit 1; }

download() { # $1 = remote filename, $2 = local path
    local url="$RAW/$1" dest="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$dest" "$url" || return 1
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$dest" "$url" || return 1
    else
        fail "need curl or wget (neither found)"
    fi
    [ -s "$dest" ] || return 1
}

if [ "${1:-}" = "--uninstall" ]; then
    say "Removing MASON v2..."
    command -v batocera-services >/dev/null 2>&1 && batocera-services disable mason 2>/dev/null
    pkill -f mason-daemon.py 2>/dev/null
    rm -f "$PORTS/MASON.sh" "$HOOK" "$SERVICE"
    rm -rf "$DIR"
    say "Removed. Refresh the gamelist and MASON will be gone from Ports."
    exit 0
fi

# --- sanity: this must run ON Batocera ---
[ -d /userdata ] || fail "no /userdata found -- run this ON the Batocera box, not your PC."
command -v python3 >/dev/null 2>&1 || fail "python3 not found on this box."
say "MASON v2 installer (branch: $BRANCH)"
mkdir -p "$DIR/screenshots" /userdata/system/scripts /userdata/system/services || fail "cannot create $DIR"

# --- download the app (loud failures, no fake DONE) ---
for f in mason.py mason-daemon.py mason-hook.sh mason-service MASON.sh; do
    say "  downloading $f ..."
    download "$f" "/tmp/mason-$f" || fail "could not download $f from $RAW"
done
# icon is optional (reuse the repo's existing icon)
download "icon.png" "/tmp/mason-icon.png" 2>/dev/null || say "  (no icon.png in branch, keeping Ports text entry)"

cp /tmp/mason-mason.py "$DIR/mason.py"
cp /tmp/mason-mason-daemon.py "$DIR/mason-daemon.py"
cp /tmp/mason-mason-hook.sh "$HOOK"
cp /tmp/mason-mason-service "$SERVICE"
cp /tmp/mason-MASON.sh "$PORTS/MASON.sh"
[ -f /tmp/mason-icon.png ] && cp /tmp/mason-icon.png "$DIR/icon.png"
chmod +x "$HOOK" "$SERVICE" "$PORTS/MASON.sh" "$DIR/mason.py" "$DIR/mason-daemon.py"
rm -f /tmp/mason-mason.py /tmp/mason-mason-daemon.py /tmp/mason-mason-hook.sh \
      /tmp/mason-mason-service /tmp/mason-MASON.sh /tmp/mason-icon.png

# --- self-check: the app must at least compile ---
python3 -m py_compile "$DIR/mason.py" "$DIR/mason-daemon.py" \
    || fail "downloaded Python files do not compile -- install aborted, old files untouched except the copies above."

# --- API key: asked once, hidden, stored chmod 600, never printed ---
if [ ! -s "$DIR/mason.env" ]; then
    say ""
    say "Groq API key needed (get one free at console.groq.com)."
    printf 'Paste Groq API key (hidden, Enter to skip and set it later in Ports -> MASON -> Settings): '
    stty -echo 2>/dev/null; read -r GROQ_KEY; stty echo 2>/dev/null; say ""
    if [ -n "${GROQ_KEY:-}" ]; then
        printf 'GROQ_API_KEY=%s\n' "$GROQ_KEY" > "$DIR/mason.env"
        chmod 600 "$DIR/mason.env"
        say "API key saved."
    else
        say "Skipped -- set it later from Ports -> MASON -> Settings."
    fi
else
    say "API key already saved, leaving it alone."
fi

# --- voice hotkey daemon: modern services method, start it now ---
if command -v batocera-services >/dev/null 2>&1; then
    batocera-services enable mason 2>/dev/null || true
    batocera-services start mason 2>/dev/null || true
fi
if pgrep -f mason-daemon.py >/dev/null 2>&1; then
    say "Voice hotkey daemon: running."
else
    say "Voice hotkey daemon: not running (start it from Ports -> MASON -> option 5; check $DIR/daemon.log if it fails)."
fi

say ""
say "DONE. Now on the Batocera box:"
say "  1) START -> GAME SETTINGS -> REFRESH GAMELISTS"
say "  2) Open Ports -> MASON"
say "  3) In a game, LCTRL+1 = help, LCTRL+2 = translate (spoken)"
say "Logs: $DIR/mason.log and $DIR/daemon.log"
say "Re-run this installer anytime to update."
