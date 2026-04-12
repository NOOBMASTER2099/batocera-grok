#!/bin/bash
# M.A.S.O.N. - One Command Installer
# Mission Assistant System Overlay Network

clear
echo "========================================"
echo "   Installing M.A.S.O.N."
echo "   Mission Assistant System Overlay Network"
echo "========================================"
echo ""
echo "⚠️ LEGAL DISCLAIMER"
echo "This is for personal use only."
echo "You must legally own the games you emulate."
echo "We do not support or provide any ROMs/BIOS."
echo "========================================"
echo ""

# Install dependencies
echo "[1/4] Installing required packages..."
apt update -qq && apt install -y python3 python3-tk curl -qq

# Create MASON
mkdir -p /userdata/roms/ports/MASON

echo "[2/4] Creating M.A.S.O.N. launcher..."

cat > /userdata/roms/ports/MASON/MASON.sh << 'EOF'
#!/bin/bash
echo "=== M.A.S.O.N. Online ==="

API_KEY=$(batocera-settings get xai.api.key)
if [ -z "$API_KEY" ]; then
    echo "❌ API key not set!"
    echo "Run: batocera-settings set xai.api.key 'xai-UCcQcKtlvC4TaXxqotml48cW8x9osoSIYPTJcFjl1wVC9hwkEh6SUeWdAr2qfPEdURg03RrD9XJsFM25'"
    read -p "Press Enter..."
    exit 1
fi

python3 - <<'PY'
import tkinter as tk
from tkinter import scrolledtext
import requests, threading

root = tk.Tk()
root.title("M.A.S.O.N.")
root.geometry("720x560")
root.configure(bg="#0a0e17")
root.attributes("-topmost", True)

tk.Label(root, text="M.A.S.O.N.", font=("Arial", 22, "bold"), fg="#00ddff", bg="#0a0e17").pack(pady=12)
tk.Label(root, text="Mission Assistant System Overlay Network", font=("Arial", 10), fg="#666666", bg="#0a0e17").pack(pady=2)

chat = scrolledtext.ScrolledText(root, font=("Consolas", 11), bg="#11171f", fg="#aaffcc", wrap=tk.WORD)
chat.pack(fill=tk.BOTH, expand=True, padx=15, pady=10)

entry = tk.Entry(root, font=("Consolas", 12), bg="#1e2738", fg="white", insertbackground="white")
entry.pack(fill=tk.X, padx=15, pady=10)

def send():
    msg = entry.get().strip()
    if not msg: return
    chat.insert(tk.END, f"You: {msg}\n", "user")
    chat.see(tk.END)
    entry.delete(0, tk.END)

    def reply():
        try:
            r = requests.post("https://api.x.ai/v1/chat/completions",
                headers={"Authorization": f"Bearer $API_KEY"},
                json={"model": "grok-4", "messages": [{"role": "user", "content": msg}], "temperature": 0.8},
                timeout=20)
            text = r.json()['choices'][0]['message']['content']
            chat.insert(tk.END, f"Mason: {text}\n\n", "mason")
        except:
            chat.insert(tk.END, "Mason: Connection issue...\n\n", "mason")
        chat.see(tk.END)

    threading.Thread(target=reply, daemon=True).start()

entry.bind("<Return>", lambda e: send())

chat.tag_config("user", foreground="#88ff88")
chat.tag_config("mason", foreground="#00ddff")

tk.Button(root, text="SEND", command=send, bg="#0088ff", fg="white", font=("Arial", 11, "bold")).pack(pady=8)

root.mainloop()
PY
EOF

chmod +x /userdata/roms/ports/MASON/MASON.sh

echo "[3/4] Setting your API key..."
batocera-settings set xai.api.key "xai-UCcQcKtlvC4TaXxqotml48cW8x9osoSIYPTJcFjl1wVC9hwkEh6SUeWdAr2qfPEdURg03RrD9XJsFM25" 2>/dev/null

echo "[4/4] Refreshing menu..."
echo ""
echo "✅ M.A.S.O.N. is now installed!"
echo "Go to Ports → MASON to launch it."
echo ""
read -p "Press Enter to finish..."
