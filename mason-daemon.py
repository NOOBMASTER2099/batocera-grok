#!/usr/bin/env python3
"""MASON voice hotkey daemon (v2, experimental).

Reads keyboards directly at the evdev level (/dev/input/event*) so hotkeys
work while a game has focus -- the thing the v1 pygame window could never
do. Pure stdlib: struct, fcntl.ioctl, select. No grab is taken, so games
keep receiving the keys too.

  LCTRL + 1  -> help with the current game (spoken answer)
  LCTRL + 2  -> translate the screen (spoken answer)

Start/stop from the MASON Ports menu, or via the mason-service script.
Log: <mason dir>/daemon.log
"""
import fcntl
import json
import os
import select
import struct
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mason  # noqa: E402  (reuses Groq/TTS/screenshot helpers)

DIR = mason.DIR
LOG = os.path.join(DIR, "daemon.log")
PIDFILE = os.path.join(DIR, "daemon.pid")

EV_KEY = 1
KEY_LEFTCTRL = 29
KEY_1 = 2
KEY_2 = 3

# ioctl numbers (stable Linux ABI):
#   EVIOCGNAME(len)      = _IOC(READ, 'E', 0x06, len)
#   EVIOCGBIT(ev, len)   = _IOC(READ, 'E', 0x20 + ev, len)
EVIOCGNAME = 0x80084506


def eviocgbit(ev, length):
    return (2 << 30) | (0x45 << 8) | (0x20 + ev) | (length << 16)


def dlog(msg):
    try:
        with open(LOG, "a") as f:
            f.write("%s %s\n" % (time.strftime("%Y-%m-%d %H:%M:%S"), msg))
    except Exception:
        pass


def has_key(bitmap, code):
    return bool(bitmap[code // 8] & (1 << (code % 8)))


def find_keyboards():
    """Event devices that have LeftCtrl + 1 + 2 keys."""
    found = []
    try:
        names = sorted(os.listdir("/dev/input"))
    except Exception:
        return found
    for name in names:
        if not name.startswith("event"):
            continue
        path = os.path.join("/dev/input", name)
        try:
            fd = os.open(path, os.O_RDONLY | os.O_NONBLOCK)
        except Exception:
            continue
        try:
            bits = fcntl.ioctl(fd, eviocgbit(EV_KEY, 96), b"\x00" * 96)
            if (has_key(bits, KEY_LEFTCTRL)
                    and has_key(bits, KEY_1)
                    and has_key(bits, KEY_2)):
                found.append((path, fd))
            else:
                os.close(fd)
        except Exception:
            try:
                os.close(fd)
            except Exception:
                pass
    return found


def already_running():
    try:
        with open(PIDFILE) as f:
            pid = int(f.read().strip())
        os.kill(pid, 0)
        return True
    except Exception:
        return False


def main():
    if already_running():
        print("daemon already running")
        return
    with open(PIDFILE, "w") as f:
        f.write(str(os.getpid()))
    settings = mason.load_settings()
    key = mason.get_key()
    if not key:
        dlog("no API key set; daemon exiting (set it in Ports -> MASON -> Settings)")
        return
    devs = find_keyboards()
    if not devs:
        dlog("no keyboard event device found; daemon exiting")
        return
    dlog("listening on %s" % ", ".join(p for p, _ in devs))
    fds = {fd: path for path, fd in devs}
    ctrl = False
    EVENT = struct.Struct("llHHi")
    try:
        while True:
            r, _, _ = select.select(list(fds), [], [], 5)
            for fd in r:
                try:
                    data = os.read(fd, 4096)
                except Exception:
                    continue
                off = 0
                while off + EVENT.size <= len(data):
                    _, _, etype, code, value = EVENT.unpack_from(data, off)
                    off += EVENT.size
                    if etype != EV_KEY or value == 2:
                        continue  # ignore repeats
                    if code == KEY_LEFTCTRL:
                        ctrl = (value == 1)
                    elif ctrl and value == 1 and code in (KEY_1, KEY_2):
                        try:
                            if code == KEY_1:
                                ans = mason.ask(
                                    "Help me with this game right now.",
                                    True, key, settings)
                            else:
                                ans = mason.ask(
                                    "Translate this screen to English. "
                                    "Be accurate and concise.",
                                    True, key, settings)
                            mason.speak(ans, settings, key)
                        except Exception as e:
                            dlog("hotkey answer failed: %s" % e)
    except KeyboardInterrupt:
        pass
    finally:
        for fd in fds:
            try:
                os.close(fd)
            except Exception:
                pass
        try:
            os.unlink(PIDFILE)
        except Exception:
            pass


if __name__ == "__main__":
    main()
