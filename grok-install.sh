#!/bin/bash

set -e

echo "🚀 Installing / Updating Grok Build on Batocera..."

# Run the official xAI installer
curl -fsSL https://x.ai/cli/install.sh | bash

# Add Grok Build to PATH
for profile in ~/.bashrc ~/.profile; do
    if [ -f "$profile" ]; then
        if ! grep -q '.grok/bin' "$profile" 2>/dev/null; then
            echo 'export PATH="$HOME/.grok/bin:$PATH"' >> "$profile"
        fi
    fi
done

# Handle XAI API Key
if ! grep -q 'XAI_API_KEY' ~/.bashrc 2>/dev/null; then
    echo ""
    echo "🔑 Please paste your xAI API key now (it starts with xai-):"
    read -r API_KEY
    
    if [[ $API_KEY == xai-* ]]; then
        echo "export XAI_API_KEY=\"$API_KEY\"" >> ~/.bashrc
        echo "✅ API key saved to ~/.bashrc"
    else
        echo "⚠️  That doesn't look like a valid xAI key. You can add it later manually."
    fi
fi

# Reload environment
source ~/.bashrc 2>/dev/null || true

echo ""
echo "✅ Grok Build is ready!"
echo ""
echo "You can now run:"
echo "   grok"
echo "   grok -p \"your prompt here\"     (headless mode)"
echo ""
echo "Tip: cd into your Project Mason folder first for better context."
