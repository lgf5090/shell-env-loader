#!/bin/zsh
# Test the complete load_env_file process

echo "=== Load Env File Test ==="
cd ~/Downloads

# Source the loader to get access to functions
source "$HOME/.local/share/env-loader/zsh/loader.zsh"

# Enable debug mode
export ENV_LOADER_DEBUG=true

echo "=== Step-by-step load_env_file test ==="

# Test the complete process manually
file_path="$PWD/.env"
echo "Loading file: $file_path"
echo

# Step 1: Parse the file
echo "Step 1: Parsing file..."
parsed_vars=$(parse_env_file "$file_path")
echo "Parsed variables:"
echo "$parsed_vars" | grep test_env_loader
echo

# Step 2: Extract base names
echo "Step 2: Extracting base names..."
base_names=$(extract_base_names "$parsed_vars")
echo "Base names:"
echo "$base_names" | grep test_env_loader
echo

# Step 3: Process test_env_loader specifically
echo "Step 3: Processing test_env_loader..."
base_name="test_env_loader"

# Find candidates
echo "Finding candidates for $base_name..."
local -a parsed_lines candidates_array
parsed_lines=(${(f)parsed_vars})
candidates_array=()
for line in $parsed_lines; do
    if [[ "$line" == ${base_name}=* ]] || [[ "$line" == ${base_name}_*=* ]]; then
        candidates_array+=("$line")
        echo "  Found candidate: $line"
    fi
done
candidates="${(F)candidates_array}"
echo

# Step 4: Resolve precedence
echo "Step 4: Resolving precedence..."
echo "Candidates for resolution:"
echo "$candidates"
echo
best_value=$(resolve_variable_precedence "$base_name" "$candidates")
echo "Best value resolved: '$best_value'"
echo

# Step 5: Set the variable
echo "Step 5: Setting environment variable..."
if [[ -n "$best_value" ]]; then
    echo "Calling set_environment_variable '$base_name' '$best_value'"
    set_environment_variable "$base_name" "$best_value"
    echo "Variable set successfully"
else
    echo "No value to set"
fi
echo

# Step 6: Check the result
echo "Step 6: Checking result..."
echo "Current value of test_env_loader: '${test_env_loader:-NOT SET}'"
echo

# Step 7: Test the complete load_env_file function
echo "Step 7: Testing complete load_env_file function..."
unset test_env_loader  # Clear any existing value
echo "Before load_env_file: '${test_env_loader:-NOT SET}'"
load_env_file "$file_path"
echo "After load_env_file: '${test_env_loader:-NOT SET}'"
echo

echo "=== Test Complete ==="
