#!/usr/bin/env python3
# =============================================
# GROK BATOCERA ASSISTANT v1.5 - FIXED BUBBLE
# Uses Pillow + feh (reliable on Batocera)
# =============================================

import os, time, requests, json, subprocess, pygame, base64
from PIL import Image, ImageDraw, ImageFont

API_KEY = os.getenv("GROK_API_KEY")
API_URL = "https://api.x.ai/v1/chat/completions"
HISTORY_FILE = "/userdata/roms/ports/grok/history.json"
CURRENT_GAME_FILE = "/tmp/grok_current_game.json"
SCREENSHOT_PATH = "/userdata/roms/ports/grok/screenshot.png"
BUBBLE_PATH = "/userdata/roms/ports/grok/bubble.png"

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

def create_bubble(text, title="GROK"):
    img = Image.new('RGBA', (620, 180), (10, 10, 10, 230))
    draw = ImageDraw.Draw(img)
    try:
        font_title = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 18)
        font_text = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 22)
    except:
        font_title = ImageFont.load_default()
        font_text = ImageFont.load_default()

    draw.text((20, 15), title, fill="#00ffcc", font=font_title)
    draw.text((20, 55), text, fill="#ffffff", font=font_text)
    
    img.save(BUBBLE_PATH)

def show_bubble(text, title="GROK"):
    create_bubble(text, title)
    subprocess.run(["feh", "--title", "GROK", "-x", "-g", "620x180+100+600", "--zoom", "fill", "--no-title", BUBBLE_PATH], 
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(12)  # bubble stays 12 seconds
    subprocess.run(["pkill", "-f", "feh"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

# ==================== MAIN LOOP ====================
print("Grok v1.5 running in background")
print("Select + L1 → Chat")
print("Select + R1 → Translation")

while True:
    for event in pygame.event.get():
        if event.type == pygame.KEYDOWN:
            keys = pygame.key.get_pressed()
            
            if keys[pygame.K_SELECT] and keys[pygame.K_l]:          # Select + L1
                show_bubble("Thinking...", "GROK")
                answer = ask_grok("Help me with this game right now")   # ← your ask_grok function from before
                show_bubble(answer, "GROK")
            
            elif keys[pygame.K_SELECT] and keys[pygame.K_r]:        # Select + R1
                show_bubble("Translating...", "TRANSLATION")
                answer = ask_grok("Translate this screen", is_translation=True)
                show_bubble(answer, "TRANSLATION")
    
    clock.tick(30)
