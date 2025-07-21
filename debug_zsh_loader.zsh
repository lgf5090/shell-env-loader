#!/bin/zsh
# Debug script for zsh loader issues

echo "=== ZSH Environment Loader Debug ==="
echo "Current directory: $PWD"
echo "Home directory: $HOME"
echo

# Test 1: Check if common utilities are available
echo "=== Testing Common Utilities ==="
echo "Checking platform detection..."
if command -v detect_platform >/dev/null 2>&1; then
    echo "✅ detect_platform is available"
    echo "Platform: $(detect_platform)"
else
    echo "❌ detect_platform is NOT available"
fi

echo "Checking hierarchy functions..."
if command -v get_env_file_hierarchy >/dev/null 2>&1; then
    echo "✅ get_env_file_hierarchy is available"
else
    echo "❌ get_env_file_hierarchy is NOT available"
fi

echo "Checking parser functions..."
if command -v parse_env_file >/dev/null 2>&1; then
    echo "✅ parse_env_file is available"
else
    echo "❌ parse_env_file is NOT available"
fi
echo

# Test 2: Check file hierarchy
echo "=== Testing File Hierarchy ==="
echo "Looking for .env files..."

# Manual check
echo "Manual file checks:"
echo "  $HOME/.env: $([ -f "$HOME/.env" ] && echo "EXISTS" || echo "NOT FOUND")"
echo "  $HOME/.cfgs/.env: $([ -f "$HOME/.cfgs/.env" ] && echo "EXISTS" || echo "NOT FOUND")"
echo "  $PWD/.env: $([ -f "$PWD/.env" ] && echo "EXISTS" || echo "NOT FOUND")"

# Using hierarchy function
if command -v get_env_file_hierarchy >/dev/null 2>&1; then
    echo "Files found by get_env_file_hierarchy:"
    get_env_file_hierarchy | while IFS= read -r file; do
        if [[ -n "$file" ]]; then
            echo "  $file"
        fi
    done
else
    echo "Cannot test hierarchy function - not available"
fi
echo

# Test 3: Check path resolution in loader
echo "=== Testing Path Resolution ==="
echo "Testing zsh path resolution methods..."

# Test the path resolution method used in the loader
test_script_path() {
    local test_file="$HOME/.local/share/env-loader/zsh/loader.zsh"
    echo "Testing with file: $test_file"

    # Simulate what the loader does
    zsh -c "
        # Method 1: Original (broken)
        SCRIPT_DIR_OLD=\"\${0:A:h}\"
        echo \"Method 1 (old): \$SCRIPT_DIR_OLD\"

        # Method 2: Fixed
        if [[ -n \"\${(%):-%x}\" ]]; then
            local script_path=\"\${(%):-%x}\"
            SCRIPT_DIR_NEW=\"\${script_path:A:h}\"
        else
            SCRIPT_DIR_NEW=\"\${0:A:h}\"
        fi
        echo \"Method 2 (new): \$SCRIPT_DIR_NEW\"

        # Test sourcing
        source '$test_file'
        echo \"After sourcing, SCRIPT_DIR in loader: \$SCRIPT_DIR\"

        # Check if common files exist
        echo \"Checking common files:\"
        echo \"  platform.sh: \$([ -f \"\$SCRIPT_DIR/../common/platform.sh\" ] && echo \"EXISTS\" || echo \"NOT FOUND\")\"
        echo \"  hierarchy.sh: \$([ -f \"\$SCRIPT_DIR/../common/hierarchy.sh\" ] && echo \"EXISTS\" || echo \"NOT FOUND\")\"
        echo \"  parser.sh: \$([ -f \"\$SCRIPT_DIR/../common/parser.sh\" ] && echo \"EXISTS\" || echo \"NOT FOUND\")\"
    "
}

test_script_path

# Test 4: Try to source the loader with debug
echo "=== Testing Loader with Debug ==="
export ENV_LOADER_DEBUG=true

# Source the loader
echo "Sourcing zsh loader..."
if [[ -f "$HOME/.local/share/env-loader/zsh/loader.zsh" ]]; then
    source "$HOME/.local/share/env-loader/zsh/loader.zsh"
    echo "✅ Loader sourced successfully"
else
    echo "❌ Loader file not found at $HOME/.local/share/env-loader/zsh/loader.zsh"
fi
echo

# Test 5: Check if variables are loaded
echo "=== Testing Variable Loading ==="
echo "Current test_env_loader value: '${test_env_loader:-NOT SET}'"
echo "Current test_env_loader_ZSH value: '${test_env_loader_ZSH:-NOT SET}'"

# Test 6: Manual file loading
echo "=== Manual File Loading Test ==="
if [[ -f "$PWD/.env" ]]; then
    echo "Manually loading $PWD/.env..."
    if command -v load_env_file >/dev/null 2>&1; then
        load_env_file "$PWD/.env"
        echo "After manual loading:"
        echo "  test_env_loader: '${test_env_loader:-NOT SET}'"
        echo "  test_env_loader_ZSH: '${test_env_loader_ZSH:-NOT SET}'"
    else
        echo "❌ load_env_file function not available"
    fi
else
    echo "No .env file in current directory"
fi

echo
echo "=== Debug Complete ==="
