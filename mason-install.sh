#!/bin/bash
# ===============================================
#   M.A.S.O.N. — Complete All-in-One Installer v1.3
#   Mobile Assistant for Screen Observation & Navigation
# ===============================================

set -e

echo -e "\033[1;36m"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║                   🚀  M.A.S.O.N. v1.3 Installer             ║"
echo "║          Mobile Assistant for Screen Observation             ║"
echo "║                   & Navigation                               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "\033[0m"

echo -e "\033[1;33m→ Installing system dependencies...\033[0m"
sudo apt update -qq
sudo apt install -y python3 python3-pip python3-tk scrot xclip libx11-dev libxtst-dev

echo -e "\033[1;33m→ Creating M.A.S.O.N. directory...\033[0m"
mkdir -p ~/mason/icons
cd ~/mason

echo -e "\033[1;33m→ Installing Python packages...\033[0m"
pip3 install --upgrade pip
pip3 install pillow requests keyboard pyautogui opencv-python-headless

echo -e "\033[1;33m→ Generating M.A.S.O.N. logo & icon...\033[0m"

# Create a clean futuristic icon using Python + PIL
python3 - << 'PYCODE'
from PIL import Image, ImageDraw, ImageFont
import os

img = Image.new('RGB', (256, 256), color='#0a0a0f')
draw = ImageDraw.Draw(img)

# Background circle
draw.ellipse((30, 30, 226, 226), fill='#1a1a2e', outline='#00ffaa', width=18)

# "M" logo
draw.text((80, 65), "M", fill="#00ffaa", font=ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 120) if os.path.exists("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf") else None)

# Bottom text
draw.text((68, 190), "A.S.O.N.", fill="#00cc88", font=ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 28) if os.path.exists("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf") else None)

img.save("icons/mason_icon.png")
img.save("icon.png")
print("✓ Icon generated successfully")
PYCODE

# Main M.A.S.O.N. script
cat > mason.py << 'EOF'
#!/usr/bin/env python3
import time
import os
import base64
from datetime import datetime
from PIL import ImageGrab
import requests
import tkinter as tk
from tkinter import scrolledtext
import keyboard

# ===================== CONFIG =====================
API_KEY = "YOUR_XAI_API_KEY_HERE"   # ← CHANGE THIS
HOTKEY = "ctrl+alt+m"
SAVE_LOG = os.path.expanduser("~/mason/mason_log.txt")
# ================================================

os.makedirs(os.path.dirname(SAVE_LOG), exist_ok=True)

print(f"[{datetime.now().strftime('%H:%M:%S')}] M.A.S.O.N. is active | Hotkey: {HOTKEY}")

def save_log(message):
    with open(SAVE_LOG, "a", encoding="utf-8") as f:
        f.write(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {message}\n\n")

def take_screenshot():
    filepath = os.path.expanduser(f"~/mason/mason_shot_{int(time.time())}.png")
    ImageGrab.grab().save(filepath)
    return filepath

def image_to_base64(image_path):
    with open(image_path, "rb") as f:
        return base64.b64encode(f.read()).decode('utf-8')

def send_to_grok(image_path):
    base64_img = image_to_base64(image_path)
    prompt = """You are M.A.S.O.N., a real-time in-game AI assistant.
Analyze this screenshot and give clear, actionable help:
- What game it is
- Current location / situation
- Best tips, next steps, boss strategies, secrets, or objectives"""

    try:
        response = requests.post(
            "https://api.x.ai/v1/chat/completions",
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={
                "model": "grok-2-vision-latest",
                "messages": [{"role": "user", "content": [
                    {"type": "text", "text": prompt},
                    {"type": "image_url", "image_url": {"url": f"data:image/png;base64,{base64_img}"}}
                ]}],
                "max_tokens": 750,
                "temperature": 0.7
            },
            timeout=30
        )
        if response.status_code == 200:
            return response.json()["choices"][0]["message"]["content"]
        else:
            return f"API Error ({response.status_code}): Check your API key."
    except Exception as e:
        return f"Connection error: {str(e)}"

def show_overlay(text):
    root = tk.Tk()
    root.title("M.A.S.O.N.")
    root.attributes("-alpha", 0.94)
    root.attributes("-topmost", True)
    root.geometry("860x640+1050+120")
    root.configure(bg="#0a0a0f")

    header = tk.Frame(root, bg="#0a0a0f")
    header.pack(fill=tk.X, pady=10)
    tk.Label(header, text="M.A.S.O.N.", font=("Consolas", 20, "bold"), fg="#00ffaa", bg="#0a0a0f").pack(side=tk.LEFT, padx=25)
    tk.Label(header, text="LIVE", font=("Consolas", 11), fg="#00cc88", bg="#0a0a0f").pack(side=tk.RIGHT, padx=25)

    text_area = scrolledtext.ScrolledText(root, bg="#111118", fg="#00ffaa", font=("Consolas", 12), wrap=tk.WORD)
    text_area.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)
    text_area.insert(tk.END, text)

    btn_frame = tk.Frame(root, bg="#0a0a0f")
    btn_frame.pack(pady=12)
    tk.Button(btn_frame, text="CLOSE (ESC)", command=root.destroy, bg="#c22", fg="white", font=("Consolas", 11), width=18, height=2).pack(side=tk.LEFT, padx=8)
    tk.Button(btn_frame, text="Save to Log", command=lambda: [save_log(text), print("Saved to log")], bg="#333", fg="white", font=("Consolas", 11)).pack(side=tk.LEFT, padx=8)

    root.bind("<Escape>", lambda e: root.destroy())
    root.mainloop()

def on_hotkey():
    print("→ Capturing screenshot...")
    img_path = take_screenshot()
    print("→ Analyzing with Grok...")
    answer = send_to_grok(img_path)
    save_log(answer)
    print("→ Opening overlay")
    show_overlay(answer)

keyboard.add_hotkey(HOTKEY, on_hotkey)
print("\033[1;32mM.A.S.O.N. is now running in the background!\033[0m")
print("Press Ctrl+Alt+M while playing any game.")
keyboard.wait()
EOF

chmod +x mason.py

# Run script
cat > run-mason.sh << 'EOF'
#!/bin/bash
cd ~/mason
python3 mason.py
EOF
chmod +x run-mason.sh

# Desktop shortcut
cat > ~/.local/share/applications/mason.desktop << 'EOF'
[Desktop Entry]
Name=M.A.S.O.N.
Comment=Real-time In-Game AI Vision Assistant
Exec=/home/$USER/mason/run-mason.sh
Icon=/home/$USER/mason/icon.png
Terminal=true
Type=Application
Categories=Game;Utility;
EOF

echo -e "\033[1;32m"
echo "✅ M.A.S.O.N. successfully installed!"
echo ""
echo "Next steps:"
echo "1. Get your xAI API key at → https://console.x.ai"
echo "2. Edit the config:   nano ~/mason/mason.py"
echo "   Replace YOUR_XAI_API_KEY_HERE with your real key"
echo "3. Start it:          ~/mason/run-mason.sh"
echo ""
echo "Hotkey → Ctrl + Alt + M"
echo "Desktop shortcut created as 'M.A.S.O.N.'"
echo -e "\033[0m"
