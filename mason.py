#!/usr/bin/env python3
"""MASON v2 -- Batocera sidekick (chat + voice + vision).

Stdlib ONLY. No pip, no pacman, no pygame, no tkinter, no PIL.
That is deliberate: Batocera's root filesystem is read-only and it has no
package manager, so anything the old installer tried to install never
existed. This file only needs python3, curl/wget (for the installer),
and a Groq API key.

Run from the Ports menu (MASON.sh) or directly:  python3 mason.py --menu
"""
import base64
import getpass
import json
import os
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.request

DIR = os.path.dirname(os.path.abspath(__file__))
ENV_FILE = os.path.join(DIR, "mason.env")
SETTINGS_FILE = os.path.join(DIR, "mason.json")
GAME_FILE = os.path.join(DIR, "current-game.json")
HISTORY_FILE = os.path.join(DIR, "history.jsonl")
LOG_FILE = os.path.join(DIR, "mason.log")
SHOT_FILE = os.path.join(DIR, "screenshot.png")

API_BASE = "https://api.groq.com/openai/v1"
CHAT_MODEL = "openai/gpt-oss-20b"          # fast text chat (Groq, current)
VISION_MODEL = "qwen/qwen3.8-27b"          # Groq's self-serve vision model
TTS_MODEL = "canopylabs/orpheus-v1-english"  # Groq TTS (playai-tts is dead)
VOICES = ["hannah", "autumn", "diana", "austin", "daniel", "troy"]

DEFAULT_SETTINGS = {
    "voice": True,
    "voice_name": "hannah",
    "chat_model": CHAT_MODEL,
    "vision_model": VISION_MODEL,
}


def log(msg):
    try:
        with open(LOG_FILE, "a") as f:
            f.write("%s %s\n" % (time.strftime("%Y-%m-%d %H:%M:%S"), msg))
    except Exception:
        pass


def load_env():
    env = {}
    try:
        with open(ENV_FILE) as f:
            for line in f:
                line = line.strip()
                if line and "=" in line and not line.startswith("#"):
                    k, v = line.split("=", 1)
                    env[k.strip()] = v.strip()
    except Exception:
        pass
    if "GROQ_API_KEY" in os.environ:
        env["GROQ_API_KEY"] = os.environ["GROQ_API_KEY"]
    return env


def save_key(key):
    with open(ENV_FILE, "w") as f:
        f.write("GROQ_API_KEY=%s\n" % key)
    try:
        os.chmod(ENV_FILE, 0o600)
    except Exception:
        pass


def load_settings():
    s = dict(DEFAULT_SETTINGS)
    try:
        with open(SETTINGS_FILE) as f:
            s.update(json.load(f))
    except Exception:
        pass
    return s


def save_settings(s):
    try:
        with open(SETTINGS_FILE, "w") as f:
            json.dump(s, f, indent=2)
    except Exception as e:
        print("Could not save settings: %s" % e)


def get_key():
    return load_env().get("GROQ_API_KEY", "")


def groq_post(path, payload, key, timeout=30):
    """POST to Groq. Returns raw bytes; raises RuntimeError with the real
    error text instead of swallowing it (the v1 bug that hid everything)."""
    req = urllib.request.Request(
        API_BASE + path,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Authorization": "Bearer " + key,
                 "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.read()
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", "replace")[:600]
        raise RuntimeError("Groq HTTP %s: %s" % (e.code, body))
    except Exception as e:
        raise RuntimeError("Groq request failed: %s" % e)


def chat(messages, model, key):
    raw = groq_post("/chat/completions",
                    {"model": model, "messages": messages}, key)
    return json.loads(raw.decode("utf-8"))["choices"][0]["message"]["content"]


def speak(text, settings, key):
    """Groq TTS -> wav -> first available player. Never crashes the app."""
    if not settings.get("voice") or not key or not text:
        return False
    try:
        wav = groq_post("/audio/speech",
                        {"model": TTS_MODEL,
                         "input": text[:4000],
                         "voice": settings.get("voice_name", "hannah"),
                         "response_format": "wav"}, key, timeout=30)
        wav_path = os.path.join(DIR, "response.wav")
        with open(wav_path, "wb") as f:
            f.write(wav)
    except Exception as e:
        print("(voice failed: %s)" % e)
        return False
    players = [
        (["aplay", "-q"], "aplay"),
        (["paplay"], "paplay"),
        (["ffplay", "-nodisp", "-autoexit", "-loglevel", "quiet"], "ffplay"),
        (["mpv", "--no-video", "--really-quiet"], "mpv"),
    ]
    for cmd, name in players:
        if shutil.which(name):
            try:
                subprocess.run(cmd + [wav_path],
                               stdout=subprocess.DEVNULL,
                               stderr=subprocess.DEVNULL)
                return True
            except Exception:
                continue
    print("(no audio player found: aplay/paplay/ffplay/mpv)")
    return False


def current_game():
    try:
        with open(GAME_FILE) as f:
            return json.load(f)
    except Exception:
        return None


def take_screenshot():
    """Best-effort screenshot. Returns a path or None. Batocera has no
    scrot by default; batocera-screenshot (stock tool) drops a timestamped
    PNG into /userdata/screenshots, so we grab the newest one."""
    if shutil.which("scrot"):
        try:
            subprocess.run(["scrot", SHOT_FILE],
                           stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL)
            if os.path.exists(SHOT_FILE) and os.path.getsize(SHOT_FILE) > 0:
                return SHOT_FILE
        except Exception:
            pass
    if shutil.which("batocera-screenshot"):
        shot_dir = "/userdata/screenshots"
        try:
            before = time.time()
            out = subprocess.run(["batocera-screenshot"],
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.DEVNULL,
                                 timeout=30)
            text = out.stdout.decode("utf-8", "replace")
            for token in text.replace("\n", " ").split(" "):
                token = token.strip().strip("'\"")
                if token.endswith(".png") and os.path.exists(token):
                    shutil.copy(token, SHOT_FILE)
                    return SHOT_FILE
            newest, newest_mtime = None, 0
            for name in os.listdir(shot_dir):
                if name.endswith(".png"):
                    p = os.path.join(shot_dir, name)
                    m = os.path.getmtime(p)
                    if m >= before - 5 and m > newest_mtime:
                        newest, newest_mtime = p, m
            if newest:
                shutil.copy(newest, SHOT_FILE)
                return SHOT_FILE
        except Exception as e:
            log("screenshot failed: %s" % e)
    return None


def ask(prompt, use_vision, key, settings):
    """One question to MASON. Returns the answer string."""
    game = current_game()
    if game:
        ctx = ("You are M.A.S.O.N., a helpful Batocera sidekick. "
               "Current game: %(game)s on system %(system)s. "
               "Give short, actionable, fun advice." % game)
    else:
        ctx = ("You are M.A.S.O.N., a helpful Batocera sidekick. "
               "Give short, actionable, fun advice.")
    model = settings.get("chat_model", CHAT_MODEL)
    messages = [{"role": "system", "content": ctx}]
    if use_vision:
        shot = take_screenshot()
        if shot and os.path.getsize(shot) <= 15 * 1024 * 1024:
            with open(shot, "rb") as f:
                b64 = base64.b64encode(f.read()).decode("ascii")
            model = settings.get("vision_model", VISION_MODEL)
            messages.append({"role": "user", "content": [
                {"type": "text", "text": prompt},
                {"type": "image_url",
                 "image_url": {"url": "data:image/png;base64," + b64}},
            ]})
        else:
            print("(no screenshot available -- answering text-only)")
            messages.append({"role": "user", "content": prompt})
    else:
        messages.append({"role": "user", "content": prompt})
    answer = chat(messages, model, key)
    try:
        entry = {"t": time.strftime("%Y-%m-%d %H:%M:%S"),
                 "game": game, "q": prompt, "a": answer}
        with open(HISTORY_FILE, "a") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception:
        pass
    return answer


def chat_loop(key, settings):
    print("\n--- MASON chat (type /quit to leave, /voice on|off) ---")
    while True:
        try:
            msg = input("\nYou: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("")
            return
        if not msg:
            continue
        if msg == "/quit":
            return
        if msg.startswith("/voice"):
            settings["voice"] = ("off" not in msg)
            save_settings(settings)
            print("Voice %s." % ("on" if settings["voice"] else "off"))
            continue
        try:
            reply = ask(msg, False, key, settings)
        except Exception as e:
            print("MASON: error: %s" % e)
            continue
        print("MASON: %s" % reply)
        speak(reply, settings, key)


def settings_menu(key, settings):
    while True:
        print("\n--- Settings ---")
        print("1) Groq API key: %s" % ("SET" if key else "NOT SET"))
        print("2) Voice: %s (voice: %s)"
              % ("on" if settings["voice"] else "off",
                 settings["voice_name"]))
        print("3) Test voice")
        print("0) Back")
        c = input("Choice: ").strip()
        if c == "0":
            return key, settings
        if c == "1":
            try:
                new = getpass.getpass("Paste Groq API key (hidden): ").strip()
            except Exception:
                new = input("Paste Groq API key: ").strip()
            if new:
                save_key(new)
                key = new
                print("Saved (chmod 600, never printed).")
            else:
                print("Unchanged.")
        elif c == "2":
            print("Voices: %s" % ", ".join(VOICES))
            v = input("Voice name (blank keeps %s, 'off' disables): "
                      % settings["voice_name"]).strip().lower()
            if v == "off":
                settings["voice"] = False
            elif v in VOICES:
                settings["voice"] = True
                settings["voice_name"] = v
            elif v:
                print("Unknown voice, unchanged.")
            save_settings(settings)
        elif c == "3":
            if not key:
                print("Set the API key first.")
            else:
                speak("MASON online. Voice check, one two.", settings, key)
                print("(if you heard nothing, check the log: %s)" % LOG_FILE)


def daemon_running():
    """Precise check via pidfile (pgrep -f also matches our own shell)."""
    try:
        with open(os.path.join(DIR, "daemon.pid")) as f:
            pid = int(f.read().strip())
        os.kill(pid, 0)
        return True
    except Exception:
        return False


def menu():
    settings = load_settings()
    key = get_key()
    while True:
        game = current_game()
        print("\n==============================")
        print("  M.A.S.O.N. v2 -- Batocera")
        print("==============================")
        print("API key: %s | Voice: %s (%s)"
              % ("SET" if key else "NOT SET",
                 "on" if settings["voice"] else "off",
                 settings["voice_name"]))
        print("Now playing: %s"
              % ("%s (%s)" % (game["game"], game["system"])
                 if game else "nothing (launch a game first)"))
        print("Voice hotkey daemon: %s"
              % ("RUNNING" if daemon_running() else "stopped"))
        print("")
        print("1) Chat with MASON")
        print("2) Help with the current game")
        print("3) Look at the screen and explain it (vision)")
        print("4) Settings (API key, voice)")
        print("5) Start voice hotkey daemon (LCTRL+1 help, LCTRL+2 translate)")
        print("6) Stop voice hotkey daemon")
        print("0) Quit")
        try:
            c = input("Choice: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("")
            return
        if c == "0":
            return
        if c == "1":
            if not key:
                print("Set the API key first (option 4).")
            else:
                chat_loop(key, settings)
        elif c == "2":
            if not key:
                print("Set the API key first (option 4).")
            else:
                try:
                    a = ask("Help me with this game right now.",
                            False, key, settings)
                    print("MASON: %s" % a)
                    speak(a, settings, key)
                except Exception as e:
                    print("MASON: error: %s" % e)
        elif c == "3":
            if not key:
                print("Set the API key first (option 4).")
            else:
                try:
                    a = ask("Describe and explain what is on this screen.",
                            True, key, settings)
                    print("MASON: %s" % a)
                    speak(a, settings, key)
                except Exception as e:
                    print("MASON: error: %s" % e)
        elif c == "4":
            key, settings = settings_menu(key, settings)
        elif c == "5":
            svc = None
            for cand in ("/userdata/system/services/mason",
                         os.path.join(DIR, "mason-service")):
                if os.path.exists(cand):
                    svc = cand
                    break
            if svc:
                subprocess.run([svc, "start"])
            else:
                subprocess.run(["nohup", "python3",
                                os.path.join(DIR, "mason-daemon.py")],
                               stdout=subprocess.DEVNULL,
                               stderr=subprocess.DEVNULL)
            time.sleep(1)
            print("Daemon: %s (log: %s)"
                  % ("RUNNING" if daemon_running() else
                     "FAILED TO START -- see log",
                     os.path.join(DIR, "daemon.log")))
        elif c == "6":
            pidfile = os.path.join(DIR, "daemon.pid")
            try:
                with open(pidfile) as f:
                    os.kill(int(f.read().strip()), 15)
            except Exception:
                subprocess.run(["pkill", "-f", "mason-daemon.py"],
                               stdout=subprocess.DEVNULL,
                               stderr=subprocess.DEVNULL)
            print("Daemon stopped.")


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--menu":
        menu()
    else:
        menu()
