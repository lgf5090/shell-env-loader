#!/bin/zsh
# Test auto-initialization logic

echo "=== Auto-initialization Test ==="
cd ~/Downloads

echo "Before sourcing loader:"
echo "  ENV_LOADER_INITIALIZED: '${ENV_LOADER_INITIALIZED:-NOT SET}'"
echo "  test_env_loader: '${test_env_loader:-NOT SET}'"
echo

# Clear any existing initialization
unset ENV_LOADER_INITIALIZED
unset test_env_loader

echo "Testing zsh auto-init conditions:"
echo "  \${(%):-%x}: '${(%):-%x}'"
echo "  \${(%):-%N}: '${(%):-%N}'"
echo "  Condition \${(%):-%x} != \${(%):-%N}: $([[ "${(%):-%x}" != "${(%):-%N}" ]] && echo "TRUE" || echo "FALSE")"
echo "  ENV_LOADER_INITIALIZED: '${ENV_LOADER_INITIALIZED:-NOT SET}'"
echo "  Should auto-init: $([[ "${(%):-%x}" != "${(%):-%N}" ]] && [[ -z "${ENV_LOADER_INITIALIZED:-}" ]] && echo "YES" || echo "NO")"
echo

echo "Sourcing loader..."
source "$HOME/.local/share/env-loader/zsh/loader.zsh"

echo "After sourcing loader:"
echo "  ENV_LOADER_INITIALIZED: '${ENV_LOADER_INITIALIZED:-NOT SET}'"
echo "  test_env_loader: '${test_env_loader:-NOT SET}'"
echo

# Test manual initialization
echo "Testing manual initialization..."
unset ENV_LOADER_INITIALIZED
unset test_env_loader
echo "Before manual init:"
echo "  test_env_loader: '${test_env_loader:-NOT SET}'"

init_env_loader

echo "After manual init:"
echo "  test_env_loader: '${test_env_loader:-NOT SET}'"
echo

echo "=== Test Complete ==="
