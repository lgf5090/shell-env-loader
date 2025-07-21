#!/bin/bash
# Detailed debugging of CONFIG_DIR processing

echo "=== Detailed CONFIG_DIR Processing Debug ==="

# Source the loader
source src/shells/bash/loader.sh

# Enable debug mode
export ENV_LOADER_DEBUG=true

# Clear test variables
unset CONFIG_DIR CONFIG_DIR_LINUX CONFIG_DIR_WSL CONFIG_DIR_MACOS CONFIG_DIR_WIN

echo "Platform: $(detect_platform)"
echo "Shell: $(detect_shell)"
echo ""

# Parse .env.example only (not the problematic ./.env)
echo "=== Parsing .env.example only ==="
parsed_vars=$(parse_env_file ".env.example")
echo "Parsed variables (CONFIG_DIR related):"
echo "$parsed_vars" | grep "CONFIG_DIR"

echo ""
echo "=== Extracting base names ==="
base_names=$(extract_base_names "$parsed_vars")
echo "Base names:"
echo "$base_names" | grep -E "^CONFIG_DIR$|^$"

echo ""
echo "=== Finding CONFIG_DIR candidates ==="
candidates=$(echo "$parsed_vars" | grep "^CONFIG_DIR\(=\|_.*=\)")
echo "CONFIG_DIR candidates:"
echo "$candidates"

echo ""
echo "=== Resolving precedence ==="
best_value=$(resolve_variable_precedence "CONFIG_DIR" "$candidates")
echo "Best value for CONFIG_DIR: [$best_value]"

echo ""
echo "=== Testing individual variables ==="
for var in CONFIG_DIR CONFIG_DIR_LINUX CONFIG_DIR_WSL CONFIG_DIR_MACOS CONFIG_DIR_WIN; do
    if echo "$candidates" | grep -q "^$var="; then
        score=$(get_variable_precedence "$var" "BASH" "LINUX")
        echo "$var: score=$score"
    else
        echo "$var: not found in candidates"
    fi
done
