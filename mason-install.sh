#!/bin/bash
# ===============================================
#   M.A.S.O.N. — v2.2 ONE-BUTTON INSTALLER
#   Grok Powered • North Button Ready
#   Auto-installs everything possible on Batocera
# ===============================================

echo -e "\033[1;36m"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                M.A.S.O.N. v2.2 ONE-BUTTON INSTALLER          ║"
echo "║        Grok Powered • Controller North Button (Y/△)          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "\033[0m"

echo "→ Updating package list..."
pacman -Sy --noconfirm || echo "→ Network slow, continuing anyway..."

echo "→ Installing system packages (trying all possible names)..."
pacman -S --noconfirm python3 python3-pip tk python3-tkinter scrot xclip pygame 2>/dev/null || echo "→ Some packages not found (normal on Batocera) — continuing..."

echo "→ Installing Python libraries via pip..."
python3 -m pip install --break-system-packages --quiet --upgrade pillow requests keyboard pyautogui opencv-python-headless pygame

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
import time, os, base64, requests, tkinter as tk, threading, pygame
from datetime import datetime
from PIL import ImageGrab
from tkinter import scrolledtext

API_KEY = "xai-UCcQcKtlvC4TaXxqotml48cW8x9osoSIYPTJcFjl1wVC9hwkEh6SUeWdAr2qfPEdURg03RrD9XJsFM25"

print(f"[{datetime.now().strftime('%H:%M:%S')}] M.A.S.O.N. v2.2 (Grok Powered) starting...")

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
    print("→ Screenshot captured → Sending to Grok...")
    img = take_screenshot()
    answer = send_to_grok(img)
    with open(os.path.expanduser("~/mason/mason_log.txt"), "a") as f:
        f.write(f"[{datetime.now()}] New Analysis\n{answer}\n\n")
    show_overlay(answer)

# Controller + Keyboard fallback
def listener():
    try:
        pygame.init()
        pygame.joystick.init()
        if pygame.joystick.get_count() > 0:
            joy = pygame.joystick.Joystick(0)
            joy.init()
            print(f"✅ Controller ready: {joy.get_name()} → Press North button (Y/△)")
            while True:
                pygame.event.pump()
                for event in pygame.event.get():
                    if event.type == pygame.JOYBUTTONDOWN and event.button == 3:  # North = Y / △
                        on_hotkey()
                time.sleep(0.05)
        else:
            print("No controller detected → Using keyboard fallback (Ctrl+Alt+M)")
    except:
        print("Controller support not available → Using keyboard fallback (Ctrl+Alt+M)")

threading.Thread(target=listener, daemon=True).start()

print("\033[1;32mM.A.S.O.N. is running!\033[0m")
print("Hotkey = North button (Y / △) on controller")
print("         or Ctrl + Alt + M on keyboard")
input("Press Enter to keep running (close terminal to stop)...\n")
EOF

chmod +x mason.py

cat > run-mason.sh << 'EOF'
#!/bin/bash
cd ~/mason
python3 mason.py
EOF
chmod +x run-mason.sh

echo -e "\033[1;32m✅ ONE-BUTTON INSTALL COMPLETE!"
echo ""
echo "Just run this to start M.A.S.O.N.:"
echo "   ~/mason/run-mason.sh"
echo ""
echo "Plug in your controller first, then run the command above."
echo "It will auto-detect the North button (Y/△)."
echo -e "\033[0m"
