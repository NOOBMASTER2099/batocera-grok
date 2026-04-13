#!/bin/bash
clear
echo "========================================"
echo " M.A.S.O.N. LITE - Batocera Version"
echo "========================================"

mkdir -p ~/mason
cd ~/mason

cat > mason.py << 'EOF'
#!/usr/bin/env python3
import time
import requests

API_KEY = "PUT-YOUR-KEY-HERE"

def ask_grok():
    print("→ Asking Grok for help...")
    try:
        r = requests.post(
            "https://api.x.ai/v1/chat/completions",
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={
                "model": "grok-2-latest",
                "messages": [
                    {"role": "user", "content": "Give me a useful gameplay tip for retro games."}
                ],
                "max_tokens": 200
            },
            timeout=15
        )

        if r.status_code == 200:
            print("\n=== M.A.S.O.N. SAYS ===\n")
            print(r.json()["choices"][0]["message"]["content"])
        else:
            print("API error:", r.status_code)

    except Exception as e:
        print("Connection error:", e)

while True:
    input("\nPress ENTER for a tip (Ctrl+C to quit)")
    ask_grok()
EOF

chmod +x mason.py

echo "Installing minimal dependency..."
python3 -m pip install --quiet requests || echo "pip install failed (may already exist)"

echo "Launching M.A.S.O.N..."
python3 mason.py
