#!/usr/bin/env python3
# =============================================
# GROK BATOCERA ASSISTANT v1.5 - grok.py
# Background daemon - Select+L1 = Chat, Select+R1 = Translation
# =============================================

import os
import time
import requests
import json
import subprocess
import pygame
import tkinter as tk
import base64

API_KEY = os.getenv("GROK_API_KEY")
API_URL = "https://api.x.ai/v1/chat/completions"
HISTORY_FILE = "/userdata/roms/ports/grok/history.json"
CURRENT_GAME_FILE = "/tmp/grok_current_game.json"
SCREENSHOT_PATH = "/userdata/roms/ports/grok/screenshot.png"

pygame.init()
pygame.display.set_mode((1, 1), pygame.NOFRAME)
clock = pygame.time.Clock()

def get_metadata():
    if os.path.exists(CURRENT_GAME_FILE):
        try:
            with open(CURRENT_GAME_FILE) as f:
                return json.load(f)
        except:
            pass
    return {"game": "Unknown", "system": "Unknown", "rom": "Unknown", "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")}

def take_screenshot():
    subprocess.run(["scrot", "-o", SCREENSHOT_PATH], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return SCREENSHOT_PATH

def encode_image_to_base64(image_path):
    with open(image_path, "rb") as img_file:
        return base64.b64encode(img_file.read()).decode('utf-8')

def ask_grok(prompt, is_translation=False):
    meta = get_metadata()
    screenshot_path = take_screenshot()
    
    if is_translation:
        system_msg = f"You are Grok in Translation Mode. Translate the entire screen to English. Be accurate, concise, and natural."
    else:
        system_msg = f"You are Grok, the ultimate Batocera sidekick. Current game: {meta['game']} ({meta['system']}). Be short, fun, and helpful."

    image_base64 = encode_image_to_base64(screenshot_path)

    messages = [
        {"role": "system", "content": system_msg},
        {"role": "user", "content": [
            {"type": "text", "text": prompt},
            {"type": "image_url", "image_url": {"url": f"data:image/png;base64,{image_base64}"}}
        ]}
    ]

    try:
        r = requests.post(
            API_URL,
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={"model": "grok-2-vision", "messages": messages},
            timeout=25
        )
        answer = r.json()["choices"][0]["message"]["content"]
    except Exception:
        answer = "Error contacting Grok. Check your API key or internet connection."

    # Save to history with full metadata
    entry = {
        **meta,
        "question": prompt,
        "answer": answer,
        "screenshot": screenshot_path,
        "mode": "translation" if is_translation else "chat"
    }
    history = json.load(open(HISTORY_FILE)) if os.path.exists(HISTORY_FILE) else []
    history.append(entry)
    with open(HISTORY_FILE, "w") as f:
        json.dump(history, f, indent=2)

    return answer

def show_bubble(text, title="GROK"):
    root = tk.Tk()
    root.overrideredirect(True)
    root.attributes("-topmost", True)
    root.attributes("-alpha", 0.88)
    root.configure(bg="#0a0a0a")
    
    frame = tk.Frame(root, bg="#0a0a0a")
    frame.pack(padx=15, pady=12)
    
    tk.Label(frame, text=title, fg="#00ffcc", bg="#0a0a0a", font=("Consolas", 10, "bold")).pack(anchor="w")
    tk.Label(frame, text=text, fg="#ffffff", bg="#0a0a0a", font=("Consolas", 13), justify="left", wraplength=580).pack(anchor="w")
    
    root.geometry("+120+80")
    root.after(12000, root.destroy)
    root.mainloop()

print("Grok v1.5 is running in the background")
print("Select + L1 → Full Chat")
print("Select + R1 → Translation Mode")

while True:
    for event in pygame.event.get():
        if event.type == pygame.KEYDOWN:
            keys = pygame.key.get_pressed()
            
            if keys[pygame.K_SELECT] and keys[pygame.K_l]:          # Select + L1
                show_bubble("Thinking...", "GROK")
                answer = ask_grok("Help me with this game right now")
                show_bubble(answer, "GROK")
            
            elif keys[pygame.K_SELECT] and keys[pygame.K_r]:        # Select + R1
                show_bubble("Translating screen...", "TRANSLATION")
                answer = ask_grok("Translate this screen", is_translation=True)
                show_bubble(answer, "TRANSLATION")
    
    clock.tick(30)
