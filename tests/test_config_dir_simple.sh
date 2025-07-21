#!/bin/bash
# Simple test for CONFIG_DIR platform filtering

echo "=== Simple CONFIG_DIR Test ==="

# Source the loader
source src/shells/bash/loader.sh

# Clear variables
unset CONFIG_DIR CONFIG_DIR_LINUX CONFIG_DIR_WSL CONFIG_DIR_MACOS CONFIG_DIR_WIN

echo "Before loading:"
echo "CONFIG_DIR: [$CONFIG_DIR]"
echo "CONFIG_DIR_WSL: [$CONFIG_DIR_WSL]"
echo "CONFIG_DIR_MACOS: [$CONFIG_DIR_MACOS]"

# Load .env.example
echo ""
echo "Loading .env.example..."
load_env_file ".env.example" >/dev/null 2>&1

echo ""
echo "After loading:"
echo "CONFIG_DIR: [$CONFIG_DIR]"
echo "CONFIG_DIR_WSL: [$CONFIG_DIR_WSL]"
echo "CONFIG_DIR_MACOS: [$CONFIG_DIR_MACOS]"

echo ""
echo "Test results:"
if [ "$CONFIG_DIR" = "~/.config/linux" ]; then
    echo "✅ CONFIG_DIR correctly set to Linux value"
else
    echo "❌ CONFIG_DIR incorrect: expected '~/.config/linux', got '[$CONFIG_DIR]'"
fi

if [ -z "$CONFIG_DIR_WSL" ]; then
    echo "✅ CONFIG_DIR_WSL correctly filtered (not set)"
else
    echo "❌ CONFIG_DIR_WSL incorrectly set: [$CONFIG_DIR_WSL]"
fi

if [ -z "$CONFIG_DIR_MACOS" ]; then
    echo "✅ CONFIG_DIR_MACOS correctly filtered (not set)"
else
    echo "❌ CONFIG_DIR_MACOS incorrectly set: [$CONFIG_DIR_MACOS]"
fi
