#!/bin/bash
# =============================================
# GROK BATOCERA ASSISTANT v1.5 — FINAL ONE COMMAND
# Pacman fixed + metadata fixed + auto background + 10-second reboot
# =============================================

clear

CYAN='\e[36m'
GREEN='\e[32m'
YELLOW='\e[33m'
BOLD='\e[1m'
RESET='\e[0m'

echo -e "${CYAN}${BOLD}"
cat << "EOF"
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!l !!!!!!!!!! I!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!   am !!!!!!!! Jh   !!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!I  hhrah          hajha  i!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!, ,a   z h          a c   h; .!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!l .ak tX z;la        ht:z  f d;: !!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!  hh F    c.F hTafFhhh r.c zzlI ha  !!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!  ha         z z;      ;X X Fzzzzz  ha  !!!!!!!!!!!!!!
!!!!!!!!!!!!   h  Xz Y      .    uu       vX zzzzz  hh  !!!!!!!!!!!!
!!!!!!!!!!  l:L XTXz         c        n      zzzzzzz Qht  !!!!!!!!!!
!!!!!!!!  khd zFXr                              zzXzcz ahd  !!!!!!!!
!!!l,   hh  X z                                    zXz X .aa   .!!!!
l  .hhh  Xi z            TXXYi        iXXzF           zz lc  hhh   l
!!    ;              z;      nzzzzzzzccI     ;c           j  :    !!
!!!!                   zXahahchhhhhhh.  ,hhhhl                  !!!!
!!!!!!!               hhhhhCQhhkhhI  Fa hhhhha l             !!!!!!!
!!!!!!!!!!!i       z.fk            hhhhhhL   Mh w       :!!!!!!!!!!!
!!!!!!!  p   !!!!!               cIzhaz       Ld ;!!!!!   w. !!!!!!!
!!!!!!. hhha: !!!!!              pp           h  !!!!! taLhh ;!!!!!!
!!!!!!! Uhha. !!!!!         f z  hp.         oh  !!!!! Thha! !!!!!!!
!!!t  F Lahhh    !  qhz z  vz tvo  ah .z   o hhh  ! !  hhhhd u  !!!!
!!! hhhhhlthJa v f  hh haYXQh.hh    hhhhahhr.hhh     hhbkhhhhhaa !!!
!!! LhQhvn  zw c Ta vrkU.  haaq      ahhh    dXh h z hqz. cuaQab !!!
!!!!  z        nr ah       I .kQ hh zh  z       haz:r.       z  !!!!
!!!!!!!!!!!!!! ; r. Xan !,  hLahhhhhhhY,  ,T.clc  c ci!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!  v    . Y  ohkhohh!hhhh  X      ; !!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!  a    odhhaha     a  !!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!     hh,Lkahlva aahIvhh.t   !!!!!!!!!!!!!!!!!!!!
!!!!!!!l     !!    xhhhb  ckhaoI hh wchhha  aahhi    !!     !!!!!!!!
!!!!!! aahh.   ! u aahJc    czathhhhhhh     Xvkah v u   .hhhh !!!!!!
!!!!!, hhaahhhhhh zv    !!!! tmzhhhhhk  !!!!    n  hhhhhhhahM !!!!!!
!!!!!! Y ,Ukhhhh,X  Uz !!!!!!  zz  za  l!!!!! vv  ziahhaa,  Y !!!!!!
!!!!!!!!l  Yahh   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!! qdhhX  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  chakc !!!!!!!!!
!!!!!!!!!I  zI. ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!.  tX  l!!!!!!!!!
!!!!!!!!!!!!   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   t!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
EOF
echo -e "${RESET}"

echo -e "${BOLD}${CYAN}                  GROK BATOCERA ASSISTANT v1.5${RESET}"
echo -e "${YELLOW}               The ultimate in-game AI sidekick${RESET}"
echo ""

progress() {
    echo -ne "${CYAN}["
    for i in {1..30}; do echo -ne "#"; sleep 0.08; done
    echo -e "] ${GREEN}DONE${RESET}"
}

echo -e "${CYAN}═══ STEP 1: Updating system packages ═══${RESET}"
pacman -Sy --noconfirm > /dev/null 2>&1
progress

echo -e "${CYAN}═══ STEP 2: Installing tools ═══${RESET}"
pacman -S --noconfirm python-pip python-tk xdotool scrot curl jq > /dev/null 2>&1
progress

echo -e "${CYAN}═══ STEP 3: Installing Python packages ═══${RESET}"
pip3 install requests pillow pygame --break-system-packages > /dev/null 2>&1
progress

echo -e "${CYAN}═══ STEP 4: Creating folders ═══${RESET}"
mkdir -p /userdata/roms/ports/grok
mkdir -p /userdata/system/scripts
cd /userdata/roms/ports/grok
progress

echo -e "${CYAN}═══ STEP 5: Installing metadata hook (fixed) ═══${RESET}"
cat << 'GAMEHOOK' > /userdata/system/scripts/grok-metadata.sh
#!/bin/bash
if [[ "$1" == "gameStart" ]]; then
    cat << EOF > /tmp/grok_current_game.json
{"game":"$(basename "$5" .*)","system":"$2","rom":"$(basename "$5")","timestamp":"$(date '+%Y-%m-%d %H:%M:%S')"}
EOF
fi
GAMEHOOK
chmod +x /userdata/system/scripts/grok-metadata.sh
progress

echo -e "${CYAN}═══ STEP 6: Deploying Grok + auto background start ═══${RESET}"
cat << 'PYSCRIPT' > grok.py
#!/usr/bin/env python3
import os, time, requests, json, subprocess, pygame
import tkinter as tk
API_KEY = os.getenv("GROK_API_KEY")
API_URL = "https://api.x.ai/v1/chat/completions"
HISTORY_FILE = "/userdata/roms/ports/grok/history.json"
CURRENT_GAME_FILE = "/tmp/grok_current_game.json"
pygame.init()
pygame.display.set_mode((1,1), pygame.NOFRAME)
clock = pygame.time.Clock()
def get_metadata():
    if os.path.exists(CURRENT_GAME_FILE):
        with open(CURRENT_GAME_FILE) as f: return json.load(f)
    return {"game":"Unknown", "system":"Unknown", "rom":"Unknown", "timestamp":time.strftime("%Y-%m-%d %H:%M:%S")}
def take_screenshot():
    path = "/userdata/roms/ports/grok/screenshot.png"
    subprocess.run(["scrot", "-o", path], stdout=subprocess.DEVNULL)
    return path
def ask_grok(prompt, is_translation=False):
    meta = get_metadata()
    screenshot_path = take_screenshot()
    system_msg = f"You are Grok, the ultimate Batocera sidekick. Current game: {meta['game']} ({meta['system']})."
    if is_translation:
        system_msg += " Translate the entire screen to English. Be accurate and concise."
    messages = [{"role": "system", "content": system_msg}, {"role": "user", "content": prompt}]
    try:
        r = requests.post(API_URL, headers={"Authorization": f"Bearer {API_KEY}"}, json={"model": "grok-2", "messages": messages}, timeout=20)
        answer = r.json()["choices"][0]["message"]["content"]
    except:
        answer = "Error — check API key or internet."
    entry = {**meta, "question": prompt, "answer": answer, "screenshot": screenshot_path}
    history = json.load(open(HISTORY_FILE)) if os.path.exists(HISTORY_FILE) else []
    history.append(entry)
    with open(HISTORY_FILE, "w") as f: json.dump(history, f, indent=2)
    return answer
def show_bubble(text, title="GROK"):
    root = tk.Tk()
    root.overrideredirect(True)
    root.attributes("-topmost", True)
    root.attributes("-alpha", 0.88)
    root.configure(bg="#0a0a0a")
    frame = tk.Frame(root, bg="#0a0a0a")
    frame.pack(padx=12, pady=12)
    tk.Label(frame, text=title, fg="#00ffcc", bg="#0a0a0a", font=("Consolas", 10, "bold")).pack(anchor="w")
    tk.Label(frame, text=text, fg="#ffffff", bg="#0a0a0a", font=("Consolas", 13), justify="left", wraplength=580).pack(anchor="w")
    root.geometry("+120+80")
    root.after(12000, root.destroy)
    root.mainloop()
print("Grok v1.5 running in background")
while True:
    for event in pygame.event.get():
        if event.type == pygame.KEYDOWN:
            keys = pygame.key.get_pressed()
            if keys[pygame.K_SELECT] and keys[pygame.K_l]:
                show_bubble("Thinking...", "GROK")
                answer = ask_grok("Help me with this game right now")
                show_bubble(answer, "GROK")
            elif keys[pygame.K_SELECT] and keys[pygame.K_r]:
                show_bubble("Translating...", "TRANSLATION")
                answer = ask_grok("Translate this screen", is_translation=True)
                show_bubble(answer, "TRANSLATION")
    clock.tick(30)
PYSCRIPT
chmod +x grok.py
progress

# Auto background start
echo '/userdata/roms/ports/grok/grok.py &' >> /userdata/system/custom.sh

# Download your icon
curl -o /userdata/roms/ports/grok/icon.png https://raw.githubusercontent.com/NOOBMASTER2099/batocera-grok/main/icon.png > /dev/null 2>&1

echo -e "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  GROK HAS FULLY AWAKENED                    ║"
echo "║                                                              ║"
echo "║  In any game:                                                ║"
echo "║     Select + L1  → Full Grok chat bubble                     ║"
echo "║     Select + R1  → Smart Translation bubble                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"
echo -e "${CYAN}Installation complete. Rebooting in 10 seconds...${RESET}"
sleep 10
reboot
