#!/bin/bash
# M.A.S.O.N. v2.4 - Final Working Version for Batocera
# Grok Powered • North Button (Y/△) Ready

clear
echo "========================================"
echo "   M.A.S.O.N. v2.4 - STARTING NOW"
echo "   Grok Powered In-Game Assistant"
echo "========================================"

echo "→ Installing missing tools..."
python3 -m ensurepip --upgrade --default-pip > /dev/null 2>&1
python3 -m pip install --break-system-packages --quiet --upgrade pillow requests opencv-python-headless pygame

echo "→ Creating program files..."
mkdir -p ~/mason
cd ~/mason

cat > mason.py << 'EOF'
#!/usr/bin/env python3
import time, os, base64, requests, tkinter as tk, threading, pygame
from datetime import datetime
from PIL import ImageGrab
from tkinter import scrolledtext

API_KEY = "xai-UCcQcKtlvC4TaXxqotml48cW8x9osoSIYPTJcFjl1wVC9hwkEh6SUeWdAr2qfPEdURg03RrD9XJsFM25"

print(f"[{datetime.now().strftime('%H:%M:%S')}] M.A.S.O.N. v2.4 is now ACTIVE")

def take_screenshot():
    path = os.path.expanduser(f"~/mason/shot_{int(time.time())}.png")
    ImageGrab.grab().save(path)
    return path

def image_to_base64(path):
    with open(path, "rb") as f:
        return base64.b64encode(f.read()).decode()

def send_to_grok(image_path):
    prompt = "You are M.A.S.O.N., a real-time in-game assistant powered by Grok. Tell the player the game name, current area, and give useful tips or next steps."
    try:
        r = requests.post("https://api.x.ai/v1/chat/completions",
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={"model": "grok-2-vision-latest", "messages": [{"role": "user", "content": [{"type": "text", "text": prompt}, {"type": "image_url", "image_url": {"url": f"data:image/png;base64,{image_to_base64(image_path)}"}}]}], "max_tokens": 700},
            timeout=30)
        return r.json()["choices"][0]["message"]["content"] if r.status_code == 200 else "API Error"
    except:
        return "Connection error - check internet"

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
    txt.insert(tk.END, text + "\n\nM.A.S.O.N. is Grok Powered.\nUnofficial tool.")
    tk.Button(root, text="CLOSE (ESC)", command=root.destroy, bg="#c22", fg="white", font=("Consolas", 11), height=2).pack(pady=12)
    root.bind("<Escape>", lambda e: root.destroy())
    root.mainloop()

def on_hotkey():
    print("→ Screenshot taken → Asking Grok...")
    img = take_screenshot()
    answer = send_to_grok(img)
    show_overlay(answer)

# Controller (North button Y/△) + keyboard fallback
def controller_listener():
    try:
        pygame.init()
        pygame.joystick.init()
        if pygame.joystick.get_count() > 0:
            joy = pygame.joystick.Joystick(0)
            joy.init()
            print(f"Controller ready: {joy.get_name()} → Press NORTH button (Y/△)")
            while True:
                pygame.event.pump()
                for event in pygame.event.get():
                    if event.type == pygame.JOYBUTTONDOWN and event.button == 3:
                        on_hotkey()
                time.sleep(0.05)
    except:
        print("Controller not detected → Use Ctrl+Alt+M on keyboard")

threading.Thread(target=controller_listener, daemon=True).start()

print("\033[1;32mM.A.S.O.N. is running!\033[0m")
print("Press NORTH button (Y/△) on controller")
print("or Ctrl+Alt+M on keyboard")
input("Press Enter to keep running (close this window to stop)...\n")
EOF

chmod +x mason.py

cat > run-mason.sh << 'EOF'
#!/bin/bash
cd ~/mason
python3 mason.py
EOF
chmod +x run-mason.sh

echo "✅ M.A.S.O.N. is ready!"
echo "Launching now..."
./run-mason.sh
