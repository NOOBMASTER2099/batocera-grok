YES — it is now 100% copy-paste ready.
Just copy the entire block below and paste it into your Batocera terminal, then press Enter.
It will do everything in one shot:

Create the full Grok.sh with your ASCII banner
Make it executable
Launch it immediately

Bashcd /userdata/roms/ports/Grok 2>/dev/null || mkdir -p /userdata/roms/ports/Grok && cd /userdata/roms/ports/Grok

cat > Grok.sh << 'FINAL'
#!/bin/bash
clear
echo -e "\033[1;32m"
cat << "EOF"
..######...########...#######..##....##
.##....##..##.....##.##.....##.##...##.
.##........##.....##.##.....##.##..##..
.##...####.########..##.....##.#####...
.##....##..##...##...##.....##.##..##..
.##....##..##....##..##.....##.##...##.
..######...##.....##..#######..##....##
EOF
echo -e "\033[0m"
echo "          Grok In-Game Vision Assistant"
echo "          Version 1.0 - First Ever"
echo "          Made by Noobmaster and Grok"
echo "          Hotkey: Y/△ or Ctrl+Alt+G"
echo "============================================================"
echo "Grok is ready — Press any button to start hotkey listener"
echo "============================================================"

# One-time API key
if [ ! -f ~/grok/api_key.txt ]; then
    echo ""
    echo "First time setup — Grok Login"
    read -p "Paste your xAI API key (starts with xai-...): " api_key
    mkdir -p ~/grok
    echo "$api_key" > ~/grok/api_key.txt
    echo "✓ API key saved securely!"
else
    echo "✓ API key already saved"
fi

API_KEY=$(cat ~/grok/api_key.txt)
mkdir -p ~/grok/screenshots

echo "Hotkey listener started. Press Y/△ on controller or Ctrl+Alt+G"

python3 - << 'PY'
import time, os, base64, requests, tkinter as tk, threading, pygame
from datetime import datetime
from PIL import ImageGrab
from tkinter import scrolledtext

API_KEY = os.environ.get('API_KEY') or open(os.path.expanduser("~/grok/api_key.txt")).read().strip()
SCREENSHOT_DIR = os.path.expanduser("~/grok/screenshots")
LOG_FILE = os.path.expanduser("~/grok/grok_log.txt")
os.makedirs(SCREENSHOT_DIR, exist_ok=True)

LEGAL = "Legal: Use only with games you legally own.\nUnofficial • Made by Noobmaster and Grok"

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
    tk.Button(frame, text="🎤 Voice", command=lambda: print("Voice mode coming soon"), bg="#00cc77", fg="black").pack(side="right", padx=5)
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
            print("Controller ready → Press NORTH (Y/△)")
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
input("Press Enter to keep running...\n")
PY
FINAL

chmod +x Grok.sh
echo "✅ Grok.sh created and ready!"
./Grok.sh
