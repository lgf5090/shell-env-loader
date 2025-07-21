#!/bin/bash
# Test path resolution issues specifically

echo "=== Path Resolution Test ==="
cd ~/Downloads

# Test 1: Bash
echo "=== Testing Bash Path Resolution ==="
if command -v bash >/dev/null 2>&1; then
    bash -c '
        echo "Testing bash loader path resolution..."
        unset test_env_loader
        source "$HOME/.local/share/env-loader/bash/loader.sh" 2>&1 | head -5
        echo "Result: test_env_loader = ${test_env_loader:-NOT SET}"
    '
else
    echo "❌ Bash not available"
fi
echo

# Test 2: Zsh (we know this works now)
echo "=== Testing Zsh Path Resolution ==="
if command -v zsh >/dev/null 2>&1; then
    zsh -c '
        echo "Testing zsh loader path resolution..."
        unset test_env_loader
        source "$HOME/.local/share/env-loader/zsh/loader.zsh" 2>&1 | head -5
        echo "Result: test_env_loader = ${test_env_loader:-NOT SET}"
    '
else
    echo "❌ Zsh not available"
fi
echo

# Test 3: Fish (simple test)
echo "=== Testing Fish Path Resolution ==="
if command -v fish >/dev/null 2>&1; then
    fish -c '
        echo "Testing fish loader path resolution..."
        set -e test_env_loader 2>/dev/null
        source "$HOME/.local/share/env-loader/fish/loader.fish" 2>&1 | head -5
        echo "Result: test_env_loader = "(set -q test_env_loader; and echo $test_env_loader; or echo "NOT SET")
    ' 2>/dev/null
else
    echo "❌ Fish not available"
fi
echo

# Test 4: Check if files exist
echo "=== Checking Installed Files ==="
echo "Installed shell loaders:"
for shell in bash zsh fish nu pwsh; do
    file="$HOME/.local/share/env-loader/$shell/loader.*"
    if ls $file >/dev/null 2>&1; then
        echo "  ✅ $shell: $(ls $file)"
    else
        echo "  ❌ $shell: Not found"
    fi
done
echo

# Test 5: Test path resolution methods directly
echo "=== Testing Path Resolution Methods ==="
echo "Current directory: $PWD"
echo "Testing different path resolution methods:"

echo "1. Bash method:"
bash -c 'echo "  BASH_SOURCE[0]: ${BASH_SOURCE[0]}"'
bash -c 'echo "  dirname: $(dirname "${BASH_SOURCE[0]}")"'
bash -c 'echo "  cd + pwd: $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"'

echo "2. Zsh method:"
zsh -c 'echo "  (%):-%x: ${(%):-%x}"'
zsh -c 'script_path="${(%):-%x}"; echo "  A:h: ${script_path:A:h}"'

echo "3. Fish method:"
fish -c 'echo "  status --current-filename: "(status --current-filename)'
fish -c 'echo "  dirname: "(dirname (status --current-filename))'

echo
echo "=== Test Complete ==="
