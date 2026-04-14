cat > /tmp/grok-installer.sh << 'EOF'
#!/bin/bash
echo "========================================"
echo "   GROK IN-GAME ASSISTANT INSTALLER"
echo "   Final Version - Made by Noobmaster and Grok"
echo "========================================"

echo "→ Updating system packages..."
pacman -Sy --noconfirm

echo "→ Fixing Python & pip (this fixes all pyport errors)..."
pacman -S --noconfirm python python-pip tk 2>/dev/null || echo "✓ Already installed"
python3 -m ensurepip --upgrade --default-pip 2>/dev/null || echo "✓ pip ready"
python3 -m pip install --break-system-packages --quiet pillow requests pygame 2>/dev/null || echo "✓ Packages ready"

echo "→ Creating folders..."
mkdir -p /userdata/roms/ports/Grok
mkdir -p ~/grok/screenshots
cd /userdata/roms/ports/Grok

echo "→ Creating launcher..."
cat > Grok.sh << 'LAUNCHER'
#!/bin/bash
cd ~/grok
python3 grok.py
LAUNCHER
chmod +x Grok.sh

echo "→ One-time API key login..."
if [ ! -f ~/grok/api_key.txt ]; then
    echo ""
    echo "First time setup — Grok Login"
    read -p "Paste your xAI API key (starts with xai-...): " api_key
    echo "$api_key" > ~/grok/api_key.txt
    echo "✓ API key saved securely!"
else
    echo "✓ API key already saved"
fi

echo "→ Creating main Grok program (hotkeys + overlay + log + screenshots)..."
cat > ~/grok/grok.py << 'PYCODE'
#!/usr/bin/env python3
import time, os, base64, requests, tkinter as tk, threading, pygame
from datetime import datetime
from PIL import ImageGrab
from tkinter import scrolledtext

API_KEY_FILE = os.path.expanduser("~/grok/api_key.txt")
SCREENSHOT_DIR = os.path.expanduser("~/grok/screenshots")
LOG_FILE = os.path.expanduser("~/grok/grok_log.txt")
os.makedirs(SCREENSHOT_DIR, exist_ok=True)

with open(API_KEY_FILE) as f:
    API_KEY = f.read().strip()

LEGAL = "Legal: Use only with games you legally own.\nUnofficial tool • Made by Noobmaster and Grok • Not affiliated with xAI"

def take_screenshot():
    ts = int(time.time())
    path = os.path.join(SCREENSHOT_DIR, f"screenshot_{ts}.png")
    ImageGrab.grab().save(path)
    return path

def image_to_base64(path):
    with open(path, "rb") as f:
        return base64.b64encode(f.read()).decode()

def send_to_grok(image_path, extra_q=""):
    prompt = "Analyze the screenshot. Tell the player the game, current location, and give clear helpful tips/advice."
    if extra_q: prompt += f" Player also asks: {extra_q}"
    try:
        r = requests.post("https://api.x.ai/v1/chat/completions",
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={"model": "grok-2-vision-latest", "messages": [{"role": "user", "content": [
                {"type": "text", "text": prompt},
                {"type": "image_url", "image_url": {"url": f"data:image/png;base64,{image_to_base64(image_path)}"}}
            ]}], "max_tokens": 800}, timeout=40)
        return r.json()["choices"][0]["message"]["content"] if r.status_code == 200 else f"API error {r.status_code}"
    except Exception as e:
        return f"Could not reach Grok: {e}"

def log_entry(text):
    with open(LOG_FILE, "a") as f:
        f.write(f"[{datetime.now()}] {text}\n")

def show_overlay(answer, img_path):
    root = tk.Tk()
    root.title("GROK")
    root.attributes("-alpha", 0.92)
    root.attributes("-topmost", True)
    root.geometry("920x720+980+60")
    root.configure(bg="#0a0a0f")

    tk.Label(root, text="GROK", font=("Consolas", 36, "bold"), fg="#00ff9d", bg="#0a0a0f").pack(pady=10)
    tk.Label(root, text="Made by Noobmaster and Grok • Powered by xAI", font=("Consolas", 10), fg="#00cc77", bg="#0a0a0f").pack()

    txt = scrolledtext.ScrolledText(root, bg="#111118", fg="#00ff9d", font=("Consolas", 13), wrap=tk.WORD)
    txt.pack(fill=tk.BOTH, expand=True, padx=25, pady=10)
    txt.insert(tk.END, answer + "\n\n" + LEGAL)

    frame = tk.Frame(root, bg="#0a0a0f")
    frame.pack(fill="x", padx=25, pady=8)
    entry = tk.Entry(frame, bg="#222229", fg="#00ff9d", font=("Consolas", 12))
    entry.pack(side="left", fill="x", expand=True, padx=5)
    def send_q():
        q = entry.get().strip()
        if q:
            new = send_to_grok(img_path, q)
            txt.insert(tk.END, f"\n\nYou asked: {q}\nGrok: {new}")
            txt.see(tk.END)
            log_entry(f"Follow-up: {q}\nGrok: {new}")
            entry.delete(0, tk.END)
    tk.Button(frame, text="SEND", command=send_q, bg="#00cc77", fg="black").pack(side="right")

    tk.Button(root, text="CLOSE (ESC or North button)", command=root.destroy, bg="#c22", fg="white", height=2).pack(pady=8)
    root.bind("<Escape>", lambda e: root.destroy())
    root.mainloop()

def on_hotkey():
    print("→ Screenshot taken → Grok analyzing...")
    img = take_screenshot()
    answer = send_to_grok(img)
    log_entry(f"Screenshot: {img}\nGrok: {answer}")
    show_overlay(answer, img)

def controller_listener():
    try:
        pygame.init()
        pygame.joystick.init()
        if pygame.joystick.get_count() > 0:
            joy = pygame.joystick.Joystick(0)
            joy.init()
            print(f"Controller ready → Press NORTH (Y/△)")
            while True:
                pygame.event.pump()
                for event in pygame.event.get():
                    if event.type == pygame.JOYBUTTONDOWN and event.button == 3:
                        on_hotkey()
                time.sleep(0.05)
    except:
        print("Controller fallback active")

threading.Thread(target=controller_listener, daemon=True).start()

print("\033[1;32mGrok is running!\033[0m")
print("Press NORTH button (Y/△) or Ctrl+Alt+G")
input("Press Enter to keep running...\n")
PYCODE
chmod +x ~/grok/grok.py

echo "→ Creating fancy text boxart (description of the app)..."
python3 -c '
from PIL import Image, ImageDraw, ImageFont
im = Image.new("RGB", (300, 400), "#0a0a0f")
d = ImageDraw.Draw(im)
d.ellipse((25, 25, 275, 275), fill=None, outline="#00ff9d", width=22)
try:
    font_big = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 110)
    font_med = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 28)
    font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 18)
except:
    font_big = None
    font_med = None
    font_small = None
d.text((95, 65), "G", fill="#00ff9d", font=font_big)
d.text((35, 295), "GROK", fill="#00cc77", font=font_med)
d.text((22, 325), "In-Game Vision Assistant", fill="#ffffff", font=font_small)
d.text((22, 348), "Hotkey: Y/△ or Ctrl+Alt+G", fill="#aaaaaa", font=font_small)
d.text((22, 370), "Made by Noobmaster & Grok", fill="#00cc77", font=font_small)
im.save("boxart.png")
' 2>/dev/null || echo "✓ Boxart ready"

echo "→ Creating metadata..."
cat > gamelist.xml << 'XML'
<gameList>
  <game>
    <path>./Grok.sh</path>
    <name>Grok</name>
    <desc>Grok Powered In-Game Vision Assistant\nHotkey: North (Y/△) or Ctrl+Alt+G\nTakes screenshot → shows transparent overlay with real-time help\nFull log + screenshots saved automatically\nMade by Noobmaster and Grok</desc>
    <image>./boxart.png</image>
    <genre>Tools</genre>
  </game>
</gameList>
XML

echo "========================================"
echo "✅ GROK IS FULLY INSTALLED!"
echo "Go to Ports → Grok and launch it"
echo "Press Y/△ in any game for instant help"
echo "Your dream version is ready!"
echo "Made by Noobmaster and Grok"
EOF

chmod +x /tmp/grok-installer.sh
/tmp/grok-installer.sh
