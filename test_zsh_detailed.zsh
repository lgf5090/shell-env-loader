#!/bin/zsh
# Detailed test for zsh loader

echo "=== Detailed ZSH Loader Test ==="
cd ~/Downloads

# Enable debug mode
export ENV_LOADER_DEBUG=true

echo "Current directory: $PWD"
echo "Test .env file contents:"
cat .env
echo

# Test 1: Source the loader and check what happens
echo "=== Sourcing Loader Step by Step ==="

# Clear any existing functions
unset -f detect_platform get_env_file_hierarchy parse_env_file load_env_file 2>/dev/null

echo "Step 1: Source the loader..."
source "$HOME/.local/share/env-loader/zsh/loader.zsh"

echo "Step 2: Check if functions are now available..."
echo "  detect_platform: $(command -v detect_platform >/dev/null 2>&1 && echo "✅ Available" || echo "❌ Not available")"
echo "  get_env_file_hierarchy: $(command -v get_env_file_hierarchy >/dev/null 2>&1 && echo "✅ Available" || echo "❌ Not available")"
echo "  parse_env_file: $(command -v parse_env_file >/dev/null 2>&1 && echo "✅ Available" || echo "❌ Not available")"
echo "  load_env_file: $(command -v load_env_file >/dev/null 2>&1 && echo "✅ Available" || echo "❌ Not available")"

echo "Step 3: Test hierarchy function..."
if command -v get_env_file_hierarchy >/dev/null 2>&1; then
    echo "Files found by hierarchy:"
    get_env_file_hierarchy | while IFS= read -r file; do
        echo "  $file"
    done
else
    echo "❌ Hierarchy function not available"
fi

echo "Step 4: Test manual initialization..."
if command -v init_env_loader >/dev/null 2>&1; then
    echo "Calling init_env_loader manually..."
    init_env_loader
else
    echo "❌ init_env_loader function not available"
fi

echo "Step 5: Check variables after initialization..."
echo "  test_env_loader: '${test_env_loader:-NOT SET}'"
echo "  test_env_loader_ZSH: '${test_env_loader_ZSH:-NOT SET}'"

echo "Step 6: Test load_env_variables function..."
if command -v load_env_variables >/dev/null 2>&1; then
    echo "Calling load_env_variables manually..."
    load_env_variables
    echo "After manual load_env_variables:"
    echo "  test_env_loader: '${test_env_loader:-NOT SET}'"
    echo "  test_env_loader_ZSH: '${test_env_loader_ZSH:-NOT SET}'"
else
    echo "❌ load_env_variables function not available"
fi

echo
echo "=== Test Complete ==="
