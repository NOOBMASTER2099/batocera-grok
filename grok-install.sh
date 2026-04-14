cd /userdata/roms/ports

cat > "Grok.sh" << 'EOF'
#!/bin/bash
# ===============================================
#   Grok — Simple & Sweet Version
#   Clean terminal chat • One-time login
# ===============================================

clear
echo "========================================"
echo "           GROK IS HERE"
echo "      Grok Powered In-Game Assistant"
echo "========================================"

# One-time API key setup
if [ ! -f ~/grok/api_key.txt ]; then
    echo "First time setup - Welcome!"
    echo ""
    echo "Paste your xAI API key (starts with xai-...)"
    read -p "API Key: " api_key
    mkdir -p ~/grok
    echo "$api_key" > ~/grok/api_key.txt
    echo "✓ Key saved. You're logged in."
    echo ""
else
    echo "✓ Already logged in as Grok user."
fi

API_KEY=$(cat ~/grok/api_key.txt)

echo "Type your message. Type 'quit' to exit."
echo "----------------------------------------"

while true; do
    read -p "You: " msg
    
    if [[ "$msg" == "quit" || "$msg" == "exit" || "$msg" == "bye" ]]; then
        echo "Grok: Catch you later! Have fun gaming."
        break
    fi

    echo "Grok thinking..."
    
    response=$(curl -s -X POST "https://api.x.ai/v1/chat/completions" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d '{
            "model": "grok-4",
            "messages": [{"role": "user", "content": "'"$msg"'"}],
            "temperature": 0.8
        }')

    reply=$(echo "$response" | grep -o '"content":"[^"]*"' | cut -d'"' -f4 | sed 's/\\n/\n/g')

    if [ -n "$reply" ]; then
        echo "Grok: $reply"
    else
        echo "Grok: Sorry, connection issue..."
    fi
    echo "----------------------------------------"
done

echo "Returning to Batocera..."
read -p "Press Enter..."
EOF

chmod +x "Grok.sh"

echo "✅ Grok is ready!"
echo "Go to Ports → Grok to launch it."
