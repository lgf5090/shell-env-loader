#!/bin/bash
# Debug CONFIG_DIR precedence issue

echo "=== CONFIG_DIR Precedence Debug ==="

# Source the loader
source src/shells/bash/loader.sh

# Clear variables
unset CONFIG_DIR CONFIG_DIR_LINUX CONFIG_DIR_WSL CONFIG_DIR_MACOS CONFIG_DIR_WIN

echo "Platform: $(detect_platform)"
echo "Shell: $(detect_shell)"
echo ""

# Parse .env.example
echo "=== Parsing .env.example ==="
parsed_vars=$(parse_env_file ".env.example")
echo "CONFIG_DIR related variables:"
echo "$parsed_vars" | grep "CONFIG_DIR"

echo ""
echo "=== Finding CONFIG_DIR candidates ==="
candidates=$(echo "$parsed_vars" | grep "^CONFIG_DIR\(=\|_.*=\)")
echo "Candidates:"
echo "$candidates"

echo ""
echo "=== Testing individual scores ==="
while IFS= read -r candidate; do
    [ -z "$candidate" ] && continue
    name="${candidate%%=*}"
    score=$(get_variable_precedence "$name" "BASH" "LINUX")
    echo "$name: score=$score"
done <<< "$candidates"

echo ""
echo "=== Resolving precedence ==="
best_value=$(resolve_variable_precedence "CONFIG_DIR" "$candidates")
echo "Best value: [$best_value]"

echo ""
echo "=== Extracting base names ==="
base_names=$(extract_base_names "$parsed_vars")
echo "All base names:"
echo "$base_names" | head -10
echo "CONFIG_DIR in base names:"
echo "$base_names" | grep "^CONFIG_DIR$" || echo "NOT FOUND"

echo ""
echo "=== Manual test with score > 0 check ==="
best_score=-1
best_value_manual=""
while IFS= read -r candidate; do
    [ -z "$candidate" ] && continue
    name="${candidate%%=*}"
    value="${candidate#*=}"
    score=$(get_variable_precedence "$name" "BASH" "LINUX")
    echo "Testing $name: score=$score, value=[$value]"
    if [ "$score" -gt 0 ] && [ "$score" -gt "$best_score" ]; then
        best_score="$score"
        best_value_manual="$value"
        echo "  -> New best: score=$score, value=[$value]"
    fi
done <<< "$candidates"

echo "Manual best value: [$best_value_manual]"
