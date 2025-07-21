#!/bin/bash
# Test path resolution for all shells

echo "=== Testing Path Resolution for All Shells ==="
echo "Current directory: $PWD"
echo "Testing from: ~/Downloads"
echo

cd ~/Downloads

# Test 1: Bash
echo "=== Testing Bash ==="
if command -v bash >/dev/null 2>&1; then
    echo "Testing bash path resolution..."
    bash -c '
        echo "Before sourcing:"
        echo "  test_env_loader: ${test_env_loader:-NOT SET}"
        
        echo "Sourcing bash loader..."
        source "$HOME/.local/share/env-loader/bash/loader.sh" 2>&1
        
        echo "After sourcing:"
        echo "  test_env_loader: ${test_env_loader:-NOT SET}"
    '
else
    echo "❌ Bash not available"
fi
echo

# Test 2: Bzsh (using bash)
echo "=== Testing Bzsh (Bash/Zsh compatible) ==="
if command -v bash >/dev/null 2>&1; then
    echo "Testing bzsh with bash..."
    bash -c '
        echo "Before sourcing:"
        echo "  test_env_loader: ${test_env_loader:-NOT SET}"
        
        echo "Sourcing bzsh loader..."
        source "$HOME/.local/share/env-loader/bzsh/loader.sh" 2>&1
        
        echo "After sourcing:"
        echo "  test_env_loader: ${test_env_loader:-NOT SET}"
    '
else
    echo "❌ Bash not available for bzsh test"
fi
echo

# Test 3: Bzsh (using zsh)
echo "=== Testing Bzsh with Zsh ==="
if command -v zsh >/dev/null 2>&1; then
    echo "Testing bzsh with zsh..."
    zsh -c '
        echo "Before sourcing:"
        echo "  test_env_loader: ${test_env_loader:-NOT SET}"
        
        echo "Sourcing bzsh loader..."
        source "$HOME/.local/share/env-loader/bzsh/loader.sh" 2>&1
        
        echo "After sourcing:"
        echo "  test_env_loader: ${test_env_loader:-NOT SET}"
    '
else
    echo "❌ Zsh not available for bzsh test"
fi
echo

# Test 4: Fish
echo "=== Testing Fish ==="
if command -v fish >/dev/null 2>&1; then
    echo "Testing fish path resolution..."
    fish -c '
        echo "Before sourcing:"
        echo "  test_env_loader: "(set -q test_env_loader; and echo $test_env_loader; or echo "NOT SET")
        
        echo "Sourcing fish loader..."
        source "$HOME/.local/share/env-loader/fish/loader.fish" 2>&1
        
        echo "After sourcing:"
        echo "  test_env_loader: "(set -q test_env_loader; and echo $test_env_loader; or echo "NOT SET")
    '
else
    echo "❌ Fish not available"
fi
echo

# Test 5: Nushell
echo "=== Testing Nushell ==="
if command -v nu >/dev/null 2>&1; then
    echo "Testing nushell path resolution..."
    nu -c '
        echo "Before sourcing:"
        echo $"  test_env_loader: (try { $env.test_env_loader } catch { "NOT SET" })"
        
        echo "Sourcing nushell loader..."
        source "$env.HOME/.local/share/env-loader/nu/loader.nu"
        
        echo "After sourcing:"
        echo $"  test_env_loader: (try { $env.test_env_loader } catch { "NOT SET" })"
    ' 2>&1
else
    echo "❌ Nushell not available"
fi
echo

# Test 6: PowerShell
echo "=== Testing PowerShell ==="
if command -v pwsh >/dev/null 2>&1; then
    echo "Testing PowerShell path resolution..."
    pwsh -c '
        Write-Host "Before sourcing:"
        Write-Host "  test_env_loader: $(if ($env:test_env_loader) { $env:test_env_loader } else { "NOT SET" })"
        
        Write-Host "Sourcing PowerShell loader..."
        . "$env:HOME/.local/share/env-loader/pwsh/loader.ps1"
        
        Write-Host "After sourcing:"
        Write-Host "  test_env_loader: $(if ($env:test_env_loader) { $env:test_env_loader } else { "NOT SET" })"
    ' 2>&1
else
    echo "❌ PowerShell not available"
fi
echo

echo "=== Test Summary ==="
echo "Expected results for all shells:"
echo "  test_env_loader should be set to shell-specific values"
echo "  No path resolution errors should occur"
echo "  All shells should successfully load .env files"
