#!/bin/bash
# =============================================
# GROK v1.6 — Voice Edition Installer for Batocera
# =============================================

clear
CYAN='\e[36m'
GREEN='\e[32m'
YELLOW='\e[33m'
BOLD='\e[1m'
RESET='\e[0m'

echo -e "${CYAN}${BOLD} GROK INSTALL STARTING... ${RESET}"
sleep 1

echo "Updating system..."
pacman -Sy --noconfirm > /dev/null 2>&1

echo "Installing dependencies..."
pacman -S --noconfirm python-pip python-tk xdotool scrot curl jq feh alsa-utils > /dev/null 2>&1

echo "Installing Python packages..."
pip3 install requests pillow pygame --break-system-packages > /dev/null 2>&1

echo "Creating directories..."
mkdir -p /userdata/roms/ports/grok/screenshots
cd /userdata/roms/ports/grok

echo "Creating launcher..."
cat << 'EOF' > /userdata/roms/ports/grok.sh
#!/bin/bash
cd /userdata/roms/ports/grok
python grok.py --menu
EOF

chmod +x /userdata/roms/ports/grok.sh

echo "Writing Grok app..."
cat << 'PYSCRIPT' > grok.py
#!/usr/bin/env python3

import os, time, requests, json, subprocess, pygame, base64, sys, tkinter as tk
from PIL import Image, ImageDraw, ImageFont
import textwrap

API_KEY = os.getenv("GROQ_API_KEY")
API_URL = "https://api.groq.com/openai/v1/chat/completions"
TTS_URL = "https://api.groq.com/openai/v1/audio/speech"

SCREENSHOT_PATH = "/userdata/roms/ports/grok/screenshot.png"
AUDIO_PATH = "/userdata/roms/ports/grok/response.wav"
HISTORY_FILE = "/userdata/roms/ports/grok/history.json"

pygame.init()
pygame.display.set_mode((1,1))

def speak(text):
    try:
        r = requests.post(TTS_URL,
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={"model":"canopylabs/orpheus-v1-english","input":text,"voice":"hannah","response_format":"wav"})
        if r.status_code == 200:
            with open(AUDIO_PATH,"wb") as f: f.write(r.content)
            subprocess.run(["aplay", AUDIO_PATH])
    except:
        pass

def screenshot():
    subprocess.run(["scrot", SCREENSHOT_PATH])

def ask(prompt):
    screenshot()
    try:
        r = requests.post(API_URL,
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={
                "model":"llama-3.2-11b-vision-preview",
                "messages":[{"role":"user","content":prompt}]
            })
        return r.json()["choices"][0]["message"]["content"]
    except:
        return "Error contacting Grok."

def bubble(text):
    img = Image.new("RGBA",(600,180),(0,0,0,220))
    draw = ImageDraw.Draw(img)
    draw.text((20,40), textwrap.fill(text,45), fill="white")
    path="/tmp/grok.png"
    img.save(path)
    subprocess.run(["feh","-x","-g","600x180+100+600",path])
    time.sleep(5)
    subprocess.run(["pkill","feh"])

def menu():
    root=tk.Tk()
    root.title("Grok")
    root.geometry("500x300")

    def run():
        q=entry.get()
        res=ask(q)
        bubble(res)
        speak(res)

    tk.Label(root,text="Grok AI",font=("Arial",20)).pack()
    entry=tk.Entry(root,width=40)
    entry.pack()
    tk.Button(root,text="Ask",command=run).pack()
    root.mainloop()

if __name__=="__main__":
    menu()

PYSCRIPT

chmod +x grok.py

echo "DONE ✔ Launch from Ports → Grok"
