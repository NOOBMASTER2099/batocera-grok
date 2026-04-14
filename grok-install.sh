#!/bin/bash
# ===============================================
#   Grok — Simple In-Game Assistant with Login
#   Grok Powered • One-time login
# ===============================================

clear
echo "========================================"
echo "           GROK IS STARTING"
echo "      Grok Powered In-Game Assistant"
echo "========================================"

# Check if API key is already saved
if [ ! -f ~/grok/api_key.txt ]; then
    echo "First time setup - Grok Login"
    echo ""
    echo "Please enter your xAI API key (starts with xai-...)"
    read -p "API Key: " api_key
    mkdir -p ~/grok
    echo "$api_key" > ~/grok/api_key.txt
    echo "✓ API key saved securely."
    echo ""
else
    api_key=$(cat ~/grok/api_key.txt)
    echo "✓ Logged in as Grok user."
fi

echo "→ Starting Grok..."

mkdir -p ~/grok
cd ~/grok

cat > grok.py << 'EOF'
#!/usr/bin/env python3
import time, os, base64, requests, tkinter as tk, threading, pygame
from datetime import datetime
from PIL import ImageGrab
from tkinter import scrolledtext

API_KEY = open(os.path.expanduser("~/grok/api_key.txt")).read().strip()

print(f"[{datetime.now().strftime('%H:%M:%S')}] Grok is now ACTIVE (Logged in)")

def take_screenshot():
    path = os.path.expanduser(f"~/grok/shot_{int(time.time())}.png")
    ImageGrab.grab().save(path)
    return path

def image_to_base64(path):
    with open(path, "rb") as f:
        return base64.b64encode(f.read()).decode()

def send_to_grok(image_path):
    prompt = "You are Grok. Analyze the screenshot. Tell the player what game this is, where they are, and give clear helpful advice."
    try:
        r = requests.post(
            "https://api.x.ai/v1/chat/completions",
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={"model": "grok-2-vision-latest", "messages": [{"role": "user", "content": [{"type": "text", "text": prompt}, {"type": "image_url", "image_url": {"url": f"data:image/png;base64,{image_to_base64(image_path)}"}}]}], "max_tokens": 700},
            timeout=30)
        return r.json()["choices"][0]["message"]["content"] if r.status_code == 200 else "API Error"
    except:
        return "Could not reach Grok. Check internet."

def show_overlay(text):
    root = tk.Tk()
    root.title("Grok")
    root.attributes("-alpha", 0.94)
    root.attributes("-topmost", True)
    root.geometry("880x680+1000+80")
    root.configure(bg="#0a0a0f")

    tk.Label(root, text="GROK", font=("Consolas", 28, "bold"), fg="#00ffaa", bg="#0a0a0f").pack(pady=15)
    tk.Label(root, text="Powered by xAI", font=("Consolas", 11), fg="#00cc88", bg="#0a0a0f").pack()

    txt = scrolledtext.ScrolledText(root, bg="#111118", fg="#00ffaa", font=("Consolas", 12), wrap=tk.WORD)
    txt.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)
    txt.insert(tk.END, text)

    tk.Button(root, text="CLOSE (ESC)", command=root.destroy, bg="#c22", fg="white", font=("Consolas", 11), height=2).pack(pady=12)
    root.bind("<Escape>", lambda e: root.destroy())
    root.mainloop()

def on_hotkey():
    print("→ Screenshot captured → Asking Grok...")
    img = take_screenshot()
    answer = send_to_grok(img)
    show_overlay(answer)

def controller_listener():
    try:
        pygame.init()
        pygame.joystick.init()
        if pygame.joystick.get_count() > 0:
            joy = pygame.joystick.Joystick(0)
            joy.init()
            print(f"Controller ready → Press NORTH button (Y/△)")
            while True:
                pygame.event.pump()
                for event in pygame.event.get():
                    if event.type == pygame.JOYBUTTONDOWN and event.button == 3:
                        on_hotkey()
                time.sleep(0.05)
    except:
        print("Controller not detected → Use Ctrl+Alt+G")

threading.Thread(target=controller_listener, daemon=True).start()

print("\033[1;32mGrok is running!\033[0m")
print("Press NORTH button (Y/△) on controller or Ctrl+Alt+G")
input("Press Enter to keep Grok running...\n")
EOF

chmod +x grok.py

cat > run-grok.sh << 'EOF'
#!/bin/bash
cd ~/grok
python3 grok.py
EOF
chmod +x run-grok.sh

echo "✅ Grok is ready and logged in!"
echo "You can now launch it from Ports → Grok"
echo "or run: ~/grok/run-grok.sh"
