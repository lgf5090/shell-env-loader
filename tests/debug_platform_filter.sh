#!/bin/bash
# Debug platform filtering issues

echo "Debugging platform filtering..."

# Source the loader
source src/shells/bash/loader.sh

# Clear test variables
unset CONFIG_DIR CONFIG_DIR_LINUX CONFIG_DIR_WSL CONFIG_DIR_MACOS CONFIG_DIR_WIN

echo "Platform: $(get_platform)"
echo "Shell: $(detect_shell)"

# Load environment
load_env_file .env.example >/dev/null 2>&1

echo ""
echo "After loading .env.example:"
echo "CONFIG_DIR: [$CONFIG_DIR]"
echo "CONFIG_DIR_LINUX: [$CONFIG_DIR_LINUX]"
echo "CONFIG_DIR_WSL: [$CONFIG_DIR_WSL]"
echo "CONFIG_DIR_MACOS: [$CONFIG_DIR_MACOS]"
echo "CONFIG_DIR_WIN: [$CONFIG_DIR_WIN]"

echo ""
echo "Testing precedence resolution manually:"

# Test CONFIG_DIR_WSL precedence
candidates="CONFIG_DIR_WSL=~/.config/wsl"
result=$(resolve_variable_precedence "CONFIG_DIR" "$candidates")
echo "CONFIG_DIR_WSL precedence result: [$result]"

# Test CONFIG_DIR_MACOS precedence  
candidates="CONFIG_DIR_MACOS=~/Library/Application Support"
result=$(resolve_variable_precedence "CONFIG_DIR" "$candidates")
echo "CONFIG_DIR_MACOS precedence result: [$result]"

# Test individual scores
echo ""
echo "Individual variable scores:"
score=$(get_variable_precedence "CONFIG_DIR_WSL" "BASH" "LINUX")
echo "CONFIG_DIR_WSL score on LINUX: $score"

score=$(get_variable_precedence "CONFIG_DIR_MACOS" "BASH" "LINUX")
echo "CONFIG_DIR_MACOS score on LINUX: $score"

score=$(get_variable_precedence "CONFIG_DIR_LINUX" "BASH" "LINUX")
echo "CONFIG_DIR_LINUX score on LINUX: $score"
