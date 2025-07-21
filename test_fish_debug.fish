#!/usr/bin/env fish
# Debug Fish loader

echo "=== Fish Loader Debug ==="
cd ~/Downloads

echo "Current directory: $PWD"
echo "Fish version: "(fish --version)
echo

# Test path resolution
echo "=== Testing Fish Path Resolution ==="
echo "status --current-filename: "(status --current-filename)
echo "dirname result: "(dirname (status --current-filename))

# Test if the loader file exists
set loader_file "$HOME/.local/share/env-loader/fish/loader.fish"
echo "Loader file: $loader_file"
echo "File exists: "(test -f $loader_file; and echo "YES" || echo "NO")
echo

# Test sourcing with debug
echo "=== Testing Fish Loader with Debug ==="
echo "Before sourcing:"
echo "  test_env_loader: "(set -q test_env_loader; and echo $test_env_loader; or echo "NOT SET")

echo "Sourcing fish loader..."
source $loader_file

echo "After sourcing:"
echo "  test_env_loader: "(set -q test_env_loader; and echo $test_env_loader; or echo "NOT SET")

echo
echo "=== Fish Debug Complete ==="
