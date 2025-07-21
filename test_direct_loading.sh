#!/bin/bash
# Direct test of shell loaders

echo "=== Direct Shell Loader Test ==="
cd ~/Downloads

# Test each shell by directly sourcing their loaders
echo "Testing from directory: $PWD"
echo "Contents of .env file:"
head -3 .env
echo

# Test 1: Bash
echo "=== Testing Bash Loader ==="
bash << 'EOF'
echo "Before loading:"
echo "  test_env_loader: ${test_env_loader:-NOT SET}"

echo "Loading bash loader..."
source "$HOME/.local/share/env-loader/bash/loader.sh"

echo "After loading:"
echo "  test_env_loader: ${test_env_loader:-NOT SET}"
echo "  Expected: bash_env_loader"
EOF
echo

# Test 2: Zsh  
echo "=== Testing Zsh Loader ==="
zsh << 'EOF'
echo "Before loading:"
echo "  test_env_loader: ${test_env_loader:-NOT SET}"

echo "Loading zsh loader..."
source "$HOME/.local/share/env-loader/zsh/loader.zsh"

echo "After loading:"
echo "  test_env_loader: ${test_env_loader:-NOT SET}"
echo "  Expected: zsh_env_loader"
EOF
echo

# Test 3: Fish (with clean environment)
echo "=== Testing Fish Loader ==="
fish --no-config << 'EOF'
echo "Before loading:"
echo "  test_env_loader: "(set -q test_env_loader; and echo $test_env_loader; or echo "NOT SET")

echo "Loading fish loader..."
source "$HOME/.local/share/env-loader/fish/loader.fish"

echo "After loading:"
echo "  test_env_loader: "(set -q test_env_loader; and echo $test_env_loader; or echo "NOT SET")
echo "  Expected: fish_env_loader"
EOF
echo

echo "=== Summary ==="
echo "This test uses heredoc to avoid command-line path resolution issues"
echo "Each shell should successfully load its specific environment variables"
