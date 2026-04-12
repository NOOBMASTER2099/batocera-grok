#!/bin/bash
# Grok Port Installer for Batocera - NOOBMASTER99

echo "=== Installing Grok Chat + Overlay ==="

mkdir -p /userdata/roms/ports/Grok

cat > /userdata/roms/ports/Grok/Grok.sh << 'EOF'
#!/bin/bash
echo "=== Grok - Your Retro Gaming Buddy ==="

API_KEY=$(batocera-settings get xai.api.key)
if [ -z "$API_KEY" ]; then
    echo "❌ API key not found!"
    echo "Add it with: batocera-settings set xai.api.key 'xai-...'"
    read -p "Press Enter..."; exit 1
fi

python3 - <<'PY'
import tkinter as tk
from tkinter import scrolledtext
import requests, threading

API_KEY = "$API_KEY"

def send_message():
    msg = entry.get().strip()
    if not msg: return
    chat.config(state=tk.NORMAL)
    chat.insert(tk.END, f"You: {msg}\n\n", "user")
    chat.see(tk.END)
    entry.delete(0, tk.END)
    
    def get_reply():
        try:
            r = requests.post("https://api.x.ai/v1/chat/completions",
                headers={"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"},
                json={"model": "grok-4", "messages": [{"role":"system","content":"You are Grok. Be fun, helpful and game-focused."},{"role":"user","content":msg}],"temperature":0.8}, timeout=30)
            reply = r.json()['choices'][0]['message']['content']
            chat.insert(tk.END, f"Grok: {reply}\n\n", "grok")
        except:
            chat.insert(tk.END, "Grok: Connection error...\n\n", "grok")
        chat.see(tk.END)
        chat.config(state=tk.DISABLED)
    
    threading.Thread(target=get_reply, daemon=True).start()

root = tk.Tk()
root.title("Grok Chat")
root.geometry("720x620")
root.attributes("-topmost", True)

chat = scrolledtext.ScrolledText(root, wrap=tk.WORD, state=tk.DISABLED)
chat.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
chat.tag_config("user", foreground="cyan")
chat.tag_config("grok", foreground="lime")

entry = tk.Entry(root, font=("Arial", 12))
entry.pack(fill=tk.X, padx=10, pady=5)
entry.bind("<Return>", lambda e: send_message())

tk.Button(root, text="Send", command=send_message).pack(pady=5)
tk.Label(root, text="Close this window to return to Batocera").pack()

root.mainloop()
PY

echo "Grok installed! Launch it from Ports."
echo "Next step: We will add hotkey + overlay."
EOF

chmod +x /userdata/roms/ports/Grok/Grok.sh
echo "Installation complete!"
