#!/bin/zsh
# Test shell detection and variable precedence

echo "=== Shell Detection Test ==="
cd ~/Downloads

# Source the loader to get access to functions
source "$HOME/.local/share/env-loader/zsh/loader.zsh"

echo "Shell detection tests:"
echo "  \$0 = $0"
echo "  \$SHELL = $SHELL"
echo "  detect_shell() = $(detect_shell)"
echo "  detect_platform() = $(detect_platform)"
echo

echo "=== Variable Precedence Test ==="
echo "Testing variable precedence for test_env_loader:"

# Test the precedence function directly
echo "Testing get_variable_precedence:"
echo "  test_env_loader (generic): $(get_variable_precedence "test_env_loader" "ZSH" "LINUX")"
echo "  test_env_loader_ZSH (shell-specific): $(get_variable_precedence "test_env_loader_ZSH" "ZSH" "LINUX")"
echo "  test_env_loader_BASH (wrong shell): $(get_variable_precedence "test_env_loader_BASH" "ZSH" "LINUX")"
echo

echo "=== Manual Variable Resolution Test ==="
# Create test candidates
candidates="test_env_loader=shell_env_loader
test_env_loader_BASH=bash_env_loader
test_env_loader_ZSH=zsh_env_loader
test_env_loader_FISH=fish_env_loader"

echo "Test candidates:"
echo "$candidates"
echo

echo "Resolving precedence for 'test_env_loader':"
result=$(resolve_variable_precedence "test_env_loader" "$candidates")
echo "Result: '$result'"
echo

echo "=== Parsing .env File Test ==="
echo "Parsing ~/Downloads/.env file:"
parse_env_file ~/Downloads/.env | grep test_env_loader
echo

echo "=== Current Environment Check ==="
echo "Current values:"
echo "  test_env_loader = '${test_env_loader:-NOT SET}'"
echo "  test_env_loader_ZSH = '${test_env_loader_ZSH:-NOT SET}'"
echo

echo "=== Test Complete ==="
