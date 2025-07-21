#!/bin/bash
# Final comprehensive test for all shells

echo "=== Final All Shells Test ==="
cd ~/Downloads

echo "Testing directory: $PWD"
echo "Contents of .env file:"
head -6 .env
echo

# Test 1: Bash
echo "=== Testing Bash ==="
bash << 'EOF'
unset test_env_loader
source "$HOME/.local/share/env-loader/bash/loader.sh"
echo "  Result: test_env_loader = ${test_env_loader:-NOT SET}"
echo "  Expected: bash_env_loader"
EOF
echo

# Test 2: Zsh
echo "=== Testing Zsh ==="
zsh << 'EOF'
unset test_env_loader
source "$HOME/.local/share/env-loader/zsh/loader.zsh"
echo "  Result: test_env_loader = ${test_env_loader:-NOT SET}"
echo "  Expected: zsh_env_loader"
EOF
echo

# Test 3: Fish
echo "=== Testing Fish ==="
fish --no-config << 'EOF'
set -e test_env_loader 2>/dev/null
source "$HOME/.local/share/env-loader/fish/loader.fish"
echo "  Result: test_env_loader = "(set -q test_env_loader; and echo $test_env_loader; or echo "NOT SET")
echo "  Expected: fish_env_loader"
EOF
echo

# Test 4: Nushell (if available)
echo "=== Testing Nushell ==="
if command -v nu >/dev/null 2>&1; then
    nu -c 'source $env.HOME/.local/share/env-loader/nu/loader.nu; echo $"  Result: test_env_loader = ($env.test_env_loader? | default \"NOT SET\")"; echo "  Expected: nushell_env_loader"' 2>/dev/null || echo "  ❌ Nushell test failed"
else
    echo "  ❌ Nushell not available"
fi
echo

# Test 5: PowerShell (if available)
echo "=== Testing PowerShell ==="
if command -v pwsh >/dev/null 2>&1; then
    pwsh -c 'if (Test-Path "$env:HOME/.local/share/env-loader/pwsh/loader.ps1") { . "$env:HOME/.local/share/env-loader/pwsh/loader.ps1"; Write-Host "  Result: test_env_loader = $(if ($env:test_env_loader) { $env:test_env_loader } else { \"NOT SET\" })"; Write-Host "  Expected: powershell_env_loader" } else { Write-Host "  ❌ PowerShell loader not found" }' 2>/dev/null || echo "  ❌ PowerShell test failed"
else
    echo "  ❌ PowerShell not available"
fi
echo

echo "=== Summary ==="
echo "✅ Working shells should show their specific env values:"
echo "   - Bash: bash_env_loader"
echo "   - Zsh: zsh_env_loader" 
echo "   - Fish: fish_env_loader"
echo "   - Nushell: nushell_env_loader"
echo "   - PowerShell: powershell_env_loader"
echo
echo "❌ Any shell showing 'NOT SET' has path resolution or loading issues"
