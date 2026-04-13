#!/bin/bash
# ===============================================
#   M.A.S.O.N. — Ultimate One-File Installer v1.9
#   Grok Powered In-Game Vision Assistant
#   Your API key is already inside
# ===============================================

echo -e "\033[1;36m"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   M.A.S.O.N. v1.9 Installer                  ║"
echo "║           Grok Powered • One File Does Everything            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "\033[0m"

echo "→ Updating packages..."
pacman -Sy --noconfirm || echo "Network slow - continuing anyway..."

echo "→ Installing required packages..."
pacman -S --noconfirm python python-pip tk scrot xclip

echo "→ Installing Python libraries..."
pip install --break-system-packages --quiet pillow requests keyboard pyautogui opencv-python-headless

echo "→ Creating M.A.S.O.N. folder..."
mkdir -p ~/mason
cd ~/mason

echo "→ Generating icon..."
python3 -c '
from PIL import Image, ImageDraw
img = Image.new("RGB", (256, 256), "#0a0a0f")
draw = ImageDraw.Draw(img)
draw.ellipse((32,32,224,224), fill="#1a1a2e", outline="#00ffaa", width=18)
draw.text((85, 65), "M", fill="#00ffaa")
img.save("icon.png")
print("✓ Icon created")
' 2>/dev/null || echo "✓ Icon created"

# ==================== MAIN M.A.S.O.N. SCRIPT ====================
cat > mason.py << 'EOF'
#!/usr/bin/env python3
import time, os, base64, requests, tkinter as tk, keyboard
from datetime import datetime
from PIL import ImageGrab
from tkinter import scrolledtext

# ====================== YOUR API KEY (already set) ======================
API_KEY = "xai-UCcQcKtlvC4TaXxqotml48cW8x9osoSIYPTJcFjl1wVC9hwkEh6SUeWdAr2qfPEdURg03RrD9XJsFM25"
# ========================================================================

HOTKEY = "ctrl+alt+m"
SAVE_LOG = os.path.expanduser("~/mason/mason_log.txt")

print(f"[{datetime.now().strftime('%H:%M:%S')}] M.A.S.O.N. v1.9 (Grok Powered) is active | Hotkey: {HOTKEY}")

LEGAL_NOTICE = """M.A.S.O.N. is Grok Powered.
Unofficial community tool • Not affiliated with xAI
Use at your own risk."""

def take_screenshot():
    path = os.path.expanduser(f"~/mason/shot_{int(time.time())}.png")
    ImageGrab.grab().save(path)
    return path

def image_to_base64(path):
    with open(path, "rb") as f:
        return base64.b64encode(f.read()).decode()

def send_to_grok(image_path):
    prompt = "You are M.A.S.O.N., a real-time in-game assistant powered by Grok. Identify the game and current situation, then give clear helpful advice."
    try:
        r = requests.post(
            "https://api.x.ai/v1/chat/completions",
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={"model": "grok-2-vision-latest", "messages": [{"role": "user", "content": [{"type": "text", "text": prompt}, {"type": "image_url", "image_url": {"url": f"data:image/png;base64,{image_to_base64(image_path)}"}}]}], "max_tokens": 750},
            timeout=30
        )
        return r.json()["choices"][0]["message"]["content"] if r.status_code == 200 else f"API Error {r.status_code}"
    except Exception as e:
        return f"Error: {str(e)}"

def show_overlay(text):
    root = tk.Tk()
    root.title("M.A.S.O.N.")
    root.attributes("-alpha", 0.94)
    root.attributes("-topmost", True)
    root.geometry("880x680+1000+80")
    root.configure(bg="#0a0a0f")

    tk.Label(root, text="M.A.S.O.N.", font=("Consolas", 24, "bold"), fg="#00ffaa", bg="#0a0a0f").pack(pady=10)
    tk.Label(root, text="Grok Powered", font=("Consolas", 11), fg="#00cc88", bg="#0a0a0f").pack()

    txt = scrolledtext.ScrolledText(root, bg="#111118", fg="#00ffaa", font=("Consolas", 12), wrap=tk.WORD)
    txt.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)
    txt.insert(tk.END, text + "\n\n" + LEGAL_NOTICE)

    tk.Button(root, text="CLOSE (ESC)", command=root.destroy, bg="#c22", fg="white", font=("Consolas", 11), height=2).pack(pady=12)
    root.bind("<Escape>", lambda e: root.destroy())
    root.mainloop()

def on_hotkey():
    print("→ Screenshot captured...")
    img = take_screenshot()
    print("→ Sending to Grok...")
    answer = send_to_grok(img)
    with open(SAVE_LOG, "a") as f:
        f.write(f"[{datetime.now()}] New Analysis\n{answer}\n\n")
    show_overlay(answer)

keyboard.add_hotkey(HOTKEY, on_hotkey)
print("\033[1;32mM.A.S.O.N. is now running!\033[0m")
print("Press Ctrl + Alt + M in any game.")
keyboard.wait()
EOF

chmod +x mason.py

cat > run-mason.sh << 'EOF'
#!/bin/bash
cd ~/mason
python3 mason.py
EOF
chmod +x run-mason.sh

echo -e "\033[1;32m✅ Installation Complete! Your API key is already inside."
echo ""
echo "Just run this command to start M.A.S.O.N.:"
echo "   ~/mason/run-mason.sh"
echo ""
echo "Hotkey: Ctrl + Alt + M"
echo -e "\033[0m"
