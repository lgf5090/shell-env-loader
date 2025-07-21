#!/bin/zsh
# Final comprehensive test

echo "=== Final ZSH Loader Test ==="
echo "Testing all scenarios that were previously failing..."
echo

# Test 1: Direct sourcing (your original issue)
echo "Test 1: Direct sourcing of loader"
cd ~/Downloads
unset ENV_LOADER_INITIALIZED test_env_loader
source "$HOME/.local/share/env-loader/zsh/loader.zsh"
echo "  Result: test_env_loader = '${test_env_loader:-NOT SET}'"
echo "  Expected: 'zsh_env_loader' (Shell-specific value should win)"
echo

# Test 2: Sourcing via .zshrc
echo "Test 2: Sourcing via .zshrc"
cd ~/Downloads
zsh -c 'source ~/.zshrc; echo "  Result: test_env_loader = '\''${test_env_loader:-NOT SET}'\''"'
echo "  Expected: 'zsh_env_loader'"
echo

# Test 3: New zsh session
echo "Test 3: New zsh session (simulating opening new terminal)"
cd ~/Downloads
zsh -c 'echo "  Result: test_env_loader = '\''${test_env_loader:-NOT SET}'\''"'
echo "  Expected: 'zsh_env_loader'"
echo

# Test 4: Different directories
echo "Test 4: Testing in different directories"
cd /tmp
zsh -c 'source ~/.zshrc; echo "  In /tmp: test_env_loader = '\''${test_env_loader:-NOT SET}'\''"'
cd ~/Downloads
zsh -c 'source ~/.zshrc; echo "  In ~/Downloads: test_env_loader = '\''${test_env_loader:-NOT SET}'\''"'
echo "  Expected: Both should show 'zsh_env_loader' (Downloads has highest priority)"
echo

# Test 5: Verify Shell-specific behavior
echo "Test 5: Verify Shell-specific variable precedence"
cd ~/Downloads
echo "  .env file contents:"
cat .env | grep test_env_loader
echo
zsh -c 'source "$HOME/.local/share/env-loader/zsh/loader.zsh"; echo "  ZSH result: test_env_loader = '\''$test_env_loader'\''"'
echo "  Expected: 'zsh_env_loader' (ZSH-specific should win over generic)"
echo

# Test 6: Test the original failing scenario
echo "Test 6: Original failing scenario reproduction"
cd ~/Downloads
echo "  Before: test_env_loader = '${test_env_loader:-NOT SET}'"
source /home/lgf/Desktop/code/augment/shell-env-loader/src/shells/zsh/loader.zsh
echo "  After sourcing dev version: test_env_loader = '${test_env_loader:-NOT SET}'"
echo

echo "=== Test Summary ==="
echo "If all tests show 'zsh_env_loader', the issue is fixed!"
echo "The ZSH loader should now:"
echo "  ✅ Auto-initialize when sourced"
echo "  ✅ Load variables from .env files"
echo "  ✅ Respect Shell-specific precedence"
echo "  ✅ Work in any directory"
echo "  ✅ Work with both installed and dev versions"
