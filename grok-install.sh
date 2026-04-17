#!/bin/bash
# =============================================
# GROK BATOCERA ASSISTANT v1.6 — BEST FINAL VERSION
# New splash you just sent + full vision + unique screenshots
# =============================================

clear

CYAN='\e[36m'
GREEN='\e[32m'
YELLOW='\e[33m'
BOLD='\e[1m'
RESET='\e[0m'

echo -e "${CYAN}${BOLD}"
cat << "EOF"
......................................................................
......................................................................
......................................................................
......................................................................
......................................................................
.................-@@@@-..........+@@@@@@@@@+..........................
...............#@+...@@@@.......@@:......=@@...............%@@@@:.....
..............@@.:@@@@@@@@....%@@.......@@@@@@@@@@%%@@%..#@@**+%@@....
..............@#@@@@@@@@@@..:@@-......-@@@@@@........%@@@@......@@....
..............@@@@@@@@@@@@.*@@.......@@@@@@+..........%@@@.....@@@....
...............@@@@@@@@@@.@@.......:@@@@@@............%@@@...+@@@@....
....@@@@@@@@@@#..@@@@@@-+@@.......@@@@@@=.............%@@@..@@@.@@....
...-@@.......#@@...@@..@@:......-@@@@@@.......*@......%@@@@@@:..@@....
....@@@@.......@@*.@@.@@.......@@@@@@-.......@@@......%@@@@@....@@....
.....@@@@.......@@-@@.:......-@@@@@@.......#@@@@......%@@@......@@:...
......+@@@+......:=@@.......@@@@@@........@@@@@@......%@@@......@@....
........@@@@.....@:@@.%@..=@@@@@@.......@@@@@@@@......%@@@......@@....
.........%@@@:..*%@@@@@.%.@@@@@@@.....................%@@@......@@....
..........=@@@@.=@@**%@@.@...@@@@.....................%@@@......@@....
...........*@@@.@@@@@@@@#.%@@@@@@---------------------%@@@------@@....
..........@@*.@@@#.....@@@@@@@@@@::::::@@@@@@@@@-:::--%@@@:::---@@....
........*@@.....@@@@@@@@@@@@=-@@@......@@@@@@@@@......%@@@......@@....
.......@@%-------@@@@@#----@@@@@@------@@%+++#@@------%@@@------@@....
.....+@@+++++++%@@@@@+++++++%@@@@======@@:....@@+++=++@@@@=+++=+@@....
....@@*==++==+@@@@#@@@#+=====-@@@======@@:....@@======@@@@======@@....
..-@@@@@@@@@@@@@#...@@@@@@@@@@@@@@@@@@@@@:....@@@@@@@@@@@@@@@@@@@@....
..=@@@@@@@@@@@@:.....@@@@@@@@@@@@@@@@@@@@.....%@@@@@@@@@@@@@@@@@@@....
...:--------::........:---------------::.......:-----::..:------:.....
......................................................................
......................................................................
......................................................................
......................................................................
......................................................................
......................................................................
EOF
echo -e "${RESET}"

echo -e "${BOLD}${CYAN}                  GROK BATOCERA ASSISTANT v1.6${RESET}"
echo -e "${YELLOW}               The ultimate in-game AI sidekick${RESET}"
echo ""

progress() {
    echo -ne "${CYAN}["
    for i in {1..30}; do echo -ne "#"; sleep 0.08; done
    echo -e "] ${GREEN}DONE${RESET}"
}

echo -e "${CYAN}═══ STEP 1: Updating packages ═══${RESET}"
pacman -Sy --noconfirm > /dev/null 2>&1
progress

echo -e "${CYAN}═══ STEP 2: Installing tools ═══${RESET}"
pacman -S --noconfirm --needed python-pip python-tk xdotool scrot curl jq feh > /dev/null 2>&1
progress

echo -e "${CYAN}═══ STEP 3: Installing Python packages ═══${RESET}"
pip3 install requests pillow pygame --break-system-packages > /dev/null 2>&1
progress

echo -e "${CYAN}═══ STEP 4: Creating folders + icon ═══${RESET}"
mkdir -p /userdata/roms/ports/grok
mkdir -p /userdata/system/scripts
cd /userdata/roms/ports/grok
curl -o icon.png https://raw.githubusercontent.com/NOOBMASTER2099/batocera-grok/main/icon.png > /dev/null 2>&1
progress

echo -e "${CYAN}═══ STEP 5: Installing metadata hook ═══${RESET}"
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

echo -e "${CYAN}═══ STEP 6: Deploying Grok daemon (v1.6 with vision) ═══${RESET}"
cat << 'PYSCRIPT' > grok.py
#!/usr/bin/env python3
import os, time, requests, json, subprocess, pygame, base64
from PIL import Image, ImageDraw, ImageFont
import textwrap

API_KEY = os.getenv("GROK_API_KEY")
API_URL = "https://api.x.ai/v1/chat/completions"
HISTORY_FILE = "/userdata/roms/ports/grok/history.json"
CURRENT_GAME_FILE = "/tmp/grok_current_game.json"
SCREENSHOT_PATH = "/userdata/roms/ports/grok/screenshot.png"
BUBBLE_PATH = "/userdata/roms/ports/grok/bubble.png"

os.makedirs("/userdata/roms/ports/grok/screenshots", exist_ok=True)

pygame.init()
pygame.display.set_mode((1,1), pygame.NOFRAME)
clock = pygame.time.Clock()

def get_metadata():
    if os.path.exists(CURRENT_GAME_FILE):
        with open(CURRENT_GAME_FILE) as f: return json.load(f)
    return {"game":"Unknown", "system":"Unknown", "rom":"Unknown", "timestamp":time.strftime("%Y-%m-%d %H:%M:%S")}

def take_screenshot():
    subprocess.run(["scrot", "-o", SCREENSHOT_PATH], stdout=subprocess.DEVNULL)
    return SCREENSHOT_PATH

def encode_image_to_base64(path):
    img = Image.open(path)
    img = img.resize((640, 360))
    img.save("/tmp/resized.png")
    with open("/tmp/resized.png", "rb") as f:
        return base64.b64encode(f.read()).decode('utf-8')

def ask_grok(prompt, is_translation=False):
    if not API_KEY:
        return "No API key set. Run the installer again."
    meta = get_metadata()
    screenshot_path = take_screenshot()
    if is_translation:
        system_msg = "You are Grok in Translation Mode. Translate the entire screen to English. Be accurate and concise."
    else:
        system_msg = f"You are Grok, the ultimate Batocera sidekick. Current game: {meta['game']} ({meta['system']}). Give short, actionable advice."
    image_base64 = encode_image_to_base64(screenshot_path)
    messages = [
        {"role": "system", "content": system_msg},
        {"role": "user", "content": [
            {"type": "text", "text": prompt},
            {"type": "image_url", "image_url": {"url": f"data:image/png;base64,{image_base64}"}}
        ]}
    ]
    try:
        r = requests.post(API_URL, headers={"Authorization": f"Bearer {API_KEY}"}, json={"model": "grok-2-vision", "messages": messages}, timeout=25)
        data = r.json()
        answer = data.get("choices", [{}])[0].get("message", {}).get("content", "No response from Grok.")
    except Exception:
        answer = "Error contacting Grok. Check your API key or internet."
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    unique_path = f"/userdata/roms/ports/grok/screenshots/{timestamp}.png"
    subprocess.run(["cp", SCREENSHOT_PATH, unique_path], stdout=subprocess.DEVNULL)
    entry = {**meta, "question": prompt, "answer": answer, "screenshot": unique_path}
    history = json.load(open(HISTORY_FILE)) if os.path.exists(HISTORY_FILE) else []
    history.append(entry)
    with open(HISTORY_FILE, "w") as f: json.dump(history, f, indent=2)
    return answer

def show_bubble(text, title="GROK"):
    subprocess.run(["pkill", "-f", "feh"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    img = Image.new('RGBA', (620, 180), (10, 10, 10, 230))
    draw = ImageDraw.Draw(img)
    try:
        font_title = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 18)
        font_text = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 22)
    except:
        font_title = ImageFont.load_default()
        font_text = ImageFont.load_default()
    draw.text((20, 15), title, fill="#00ffcc", font=font_title)
    wrapped = textwrap.fill(text, width=45)
    draw.text((20, 55), wrapped, fill="#ffffff", font=font_text)
    img.save(BUBBLE_PATH)
    subprocess.run(["feh", "--title", "GROK", "-x", "-g", "620x180+100+600", "--zoom", "fill", "--no-title", BUBBLE_PATH], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(12)
    subprocess.run(["pkill", "-f", "feh"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

print("Grok v1.6 running in background")
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

# Auto background start (only once)
grep -qxF '/userdata/roms/ports/grok/grok.py &' /userdata/system/custom.sh || \
echo '/userdata/roms/ports/grok/grok.py &' >> /userdata/system/custom.sh

# Download icon
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
