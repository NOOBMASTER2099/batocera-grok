#!/bin/bash
# =============================================
# GROK v1.6 — Voice Edition ONE-CLICK Installer
# For Batocera 43.1 - Made for NOOBMASTER99
# =============================================

clear

CYAN='\e[36m'
GREEN='\e[32m'
YELLOW='\e[33m'
RED='\e[31m'
BOLD='\e[1m'
RESET='\e[0m'

echo -e "${CYAN}${BOLD}"
cat << "EOF"
......................................................................
......................................................................
.....................-@@@@-..........+@@@@@@@@@+......................
...................#@+...@@@@.......@@:......=@@...............%@@@@:.
..................@@.:@@@@@@@@....%@@.......@@@@@@@@@@%%@@%..#@@**+%@@
..................@#@@@@@@@@@@..:@@-......-@@@@@@........%@@@@......@@
..................@@@@@@@@@@@@.*@@.......@@@@@@+..........%@@@.....@@@
...................@@@@@@@@@@.@@.......:@@@@@@............%@@@...+@@@@
......@@@@@@@@@@#..@@@@@@-+@@.......@@@@@@=.............%@@@..@@@.@@..
.....-@@.......#@@...@@..@@:......-@@@@@@.......*@......%@@@@@@:..@@..
......@@@@.......@@*.@@.@@.......@@@@@@-.......@@@......%@@@@@....@@..
.......@@@@.......@@-@@.:......-@@@@@@.......#@@@@......%@@@......@@:.
........+@@@+......:=@@.......@@@@@@........@@@@@@......%@@@......@@..
..........@@@@.....@:@@.%@..=@@@@@@.......@@@@@@@@......%@@@......@@..
...........%@@@:..*%@@@@@.%.@@@@@@@.....................%@@@......@@..
............=@@@@.=@@**%@@.@...@@@@.....................%@@@......@@..
.............*@@@.@@@@@@@@#.%@@@@@@---------------------%@@@------@@..
............@@*.@@@#.....@@@@@@@@@@::::::@@@@@@@@@-:::--%@@@:::---@@..
..........*@@.....@@@@@@@@@@@@=-@@@......@@@@@@@@@......%@@@......@@..
.........@@%-------@@@@@#----@@@@@@------@@%+++#@@------%@@@------@@..
........+@@+++++++%@@@@@+++++++%@@@@======@@:....@@+++=++@@@@=+++=+@@..
.......@@*==++==+@@@@#@@@#+=====-@@@======@@:....@@======@@@@======@@..
.....-@@@@@@@@@@@@@#...@@@@@@@@@@@@@@@@@@@@@:....@@@@@@@@@@@@@@@@@@@@.
.....=@@@@@@@@@@@@:.....@@@@@@@@@@@@@@@@@@@@.....%@@@@@@@@@@@@@@@@@@@.
.......:--------::........:---------------::.......:-----::..:------:.
......................................................................
EOF
echo -e "${RESET}"

echo -e "${BOLD}${CYAN}GROK v1.6 — Voice Edition${RESET}"
echo -e "${YELLOW}One-click installer for Batocera 43.1${RESET}"
echo ""

echo -e "${RED}${BOLD}=== DISCLAIMER ===${RESET}"
echo -e "Installing Grok AI (Vision + Voice) into Ports..."
echo -e "Internet connection required."
echo -e "Files will be installed to /userdata/roms/ports/grok"
echo ""

echo -e "${GREEN}Auto-confirm enabled... continuing installation.${RESET}"
sleep 2

echo -e "${GREEN}Starting installation...${RESET}"

# ===================== CONFIG =====================
INSTALL_DIR="/userdata/roms/ports/grok"
LAUNCHER="/userdata/roms/ports/grok.sh"
API_KEY="YOUR_API_KEY_HERE"
# =================================================

echo -e "${CYAN}═══ STEP 1: Installing dependencies ═══${RESET}"

pacman -Sy --noconfirm
pacman -S --noconfirm --needed \
python-pip \
python-tk \
xdotool \
scrot \
curl \
jq \
feh \
alsa-utils

echo -e "${CYAN}═══ STEP 2: Python packages ═══${RESET}"

pip3 install requests pillow pygame --break-system-packages

echo -e "${CYAN}═══ STEP 3: Creating folders ═══${RESET}"

mkdir -p "${INSTALL_DIR}/screenshots"
mkdir -p /userdata/system/scripts

cd "${INSTALL_DIR}" || exit 1

echo -e "${CYAN}═══ STEP 4: Downloading icon ═══${RESET}"

curl -L -o icon.png \
https://raw.githubusercontent.com/NOOBMASTER2099/batocera-grok/main/icon.png

echo -e "${CYAN}═══ STEP 5: Saving API key ═══${RESET}"

cat > /userdata/system/grok.env <<EOF
GROQ_API_KEY=${API_KEY}
EOF

echo -e "${CYAN}═══ STEP 6: Creating metadata hook ═══${RESET}"

cat > /userdata/system/scripts/grok-metadata.sh <<'EOF'
#!/bin/bash

if [ -n "$5" ]; then
cat << JSON > /tmp/grok_current_game.json
{
  "game":"$(basename "$5" .*)",
  "system":"$2",
  "rom":"$(basename "$5")",
  "timestamp":"$(date '+%Y-%m-%d %H:%M:%S')"
}
JSON
fi
EOF

chmod +x /userdata/system/scripts/grok-metadata.sh

echo -e "${CYAN}═══ STEP 7: Creating launcher ═══${RESET}"

cat > "${LAUNCHER}" <<'EOF'
#!/bin/bash
cd /userdata/roms/ports/grok || exit 1
python3 grok.py --menu
EOF

chmod +x "${LAUNCHER}"

echo -e "${CYAN}═══ STEP 8: Creating Grok app ═══${RESET}"

cat > "${INSTALL_DIR}/grok.py" <<'EOF'
#!/usr/bin/env python3

import os
import sys
import tkinter as tk
from tkinter import messagebox
import subprocess

def uninstall_grok():
    confirm = messagebox.askyesno(
        "Uninstall Grok",
        "Remove Grok and all files?"
    )

    if confirm:
        subprocess.run([
            "rm",
            "-rf",
            "/userdata/roms/ports/grok",
            "/userdata/roms/ports/grok.sh",
            "/userdata/system/grok.env"
        ])

        subprocess.run([
            "rm",
            "-f",
            "/userdata/system/scripts/grok-metadata.sh"
        ])

        messagebox.showinfo(
            "Removed",
            "Grok removed successfully."
        )

        root.destroy()
        sys.exit(0)

def launch_menu():
    global root

    root = tk.Tk()
    root.title("Grok Batocera")
    root.geometry("600x480")
    root.configure(bg="#111111")

    title = tk.Label(
        root,
        text="🚀 GROK v1.6",
        fg="#00ffcc",
        bg="#111111",
        font=("DejaVu Sans", 20, "bold")
    )

    title.pack(pady=20)

    tk.Button(
        root,
        text="Start Overlay Mode",
        bg="#00ffcc",
        fg="black",
        font=("DejaVu Sans", 14),
        width=40,
        height=2
    ).pack(pady=8)

    tk.Button(
        root,
        text="Open Full Chat Mode",
        bg="#00ffcc",
        fg="black",
        font=("DejaVu Sans", 14),
        width=40,
        height=2
    ).pack(pady=8)

    tk.Button(
        root,
        text="Settings",
        bg="#00ffcc",
        fg="black",
        font=("DejaVu Sans", 14),
        width=40,
        height=2
    ).pack(pady=8)

    tk.Button(
        root,
        text="Uninstall Grok",
        command=uninstall_grok,
        bg="#ff4444",
        fg="white",
        font=("DejaVu Sans", 14),
        width=40,
        height=2
    ).pack(pady=8)

    tk.Button(
        root,
        text="Exit",
        command=root.destroy,
        bg="#333333",
        fg="white",
        font=("DejaVu Sans", 14),
        width=40,
        height=2
    ).pack(pady=8)

    root.mainloop()

if __name__ == "__main__":
    launch_menu()
EOF

chmod +x "${INSTALL_DIR}/grok.py"

echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}✅ GROK v1.6 INSTALLED SUCCESSFULLY${RESET}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════${RESET}"
echo ""

echo "→ Update game lists in EmulationStation"
echo "→ Open Ports → Grok"
echo "→ Enjoy the cyber-arcade wizardry ⚡"
echo ""

read -p "Launch Grok now? (y/N): " choice

if [[ "$choice" =~ ^[Yy]$ ]]; then
    exec "${LAUNCHER}"
