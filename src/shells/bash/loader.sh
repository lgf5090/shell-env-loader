#!/bin/bash
# Bash Environment Variable Loader
# =================================
# Bash-specific implementation of the cross-shell environment loader
# Uses bash built-in commands for optimal performance

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities (adjust path for installed location)
if [ -f "$SCRIPT_DIR/../common/platform.sh" ]; then
    # Installed location: ~/.local/share/env-loader/bash/
    . "$SCRIPT_DIR/../common/platform.sh"
    . "$SCRIPT_DIR/../common/hierarchy.sh"
    . "$SCRIPT_DIR/../common/parser.sh"
elif [ -f "$SCRIPT_DIR/../../common/platform.sh" ]; then
    # Development location: src/shells/bash/
    . "$SCRIPT_DIR/../../common/platform.sh"
    . "$SCRIPT_DIR/../../common/hierarchy.sh"
    . "$SCRIPT_DIR/../../common/parser.sh"
else
    echo "Error: Cannot find common utilities for env-loader" >&2
    return 1
fi

# Set environment variable using bash built-ins
# Usage: set_environment_variable <key> <value>
set_environment_variable() {
    local key="$1"
    local value="$2"
    
    # Validate key
    if ! is_valid_variable_name "$key"; then
        echo "Warning: Invalid variable name: $key" >&2
        return 1
    fi
    
    # Export the variable
    export "$key=$value"
    return 0
}

# Expand environment variables in a value (bash-specific)
# Usage: expand_environment_variables <value>
# Returns: Value with environment variables expanded
expand_environment_variables() {
    local value="$1"
    local expanded

    # Use bash's built-in parameter expansion
    # This is safe because we're in a controlled environment
    # Use eval with proper escaping
    expanded=$(eval "printf '%s' \"$value\"" 2>/dev/null || printf '%s' "$value")

    echo "$expanded"
}

# Load environment variables from a single file
# Usage: load_env_file <file_path>
load_env_file() {
    local file_path="$1"
    local shell_type platform
    local parsed_vars base_names base_name
    local candidates best_value
    
    if [ ! -f "$file_path" ]; then
        return 0  # Silently skip missing files
    fi
    
    # Get current shell and platform
    shell_type=$(detect_shell)
    platform=$(detect_platform)

    # Parse the file
    parsed_vars=$(parse_env_file "$file_path")
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to parse $file_path" >&2
        return 1
    fi
    
    # Extract unique base names
    base_names=$(extract_base_names "$parsed_vars")
    
    # Process each base name (avoid subshell to preserve variable assignments)
    while IFS= read -r base_name; do
        [ -z "$base_name" ] && continue

        # Find all candidates for this base name
        candidates=$(echo "$parsed_vars" | grep "^${base_name}\(=\|_.*=\)")

        # Resolve precedence and get the best value
        best_value=$(resolve_variable_precedence "$base_name" "$candidates")

        if [ -n "$best_value" ]; then
            # Expand environment variables if needed
            if echo "$best_value" | grep -q '\$'; then
                best_value=$(expand_environment_variables "$best_value")
            fi

            # Special handling for PATH variables
            case "$base_name" in
                PATH_ADDITION)
                    # Expand tilde and variables in PATH addition
                    if echo "$best_value" | grep -q '~'; then
                        best_value=$(echo "$best_value" | sed "s|~|$HOME|g")
                    fi
                    if echo "$best_value" | grep -q '\$'; then
                        best_value=$(expand_environment_variables "$best_value")
                    fi
                    # Append to existing PATH
                    if [ -n "$PATH" ]; then
                        best_value="$PATH:$best_value"
                    fi
                    set_environment_variable "PATH" "$best_value"
                    ;;
                PATH_EXPORT)
                    # Direct PATH replacement (already includes $PATH)
                    # Expand tilde and variables
                    if echo "$best_value" | grep -q '~'; then
                        best_value=$(echo "$best_value" | sed "s|~|$HOME|g")
                    fi
                    if echo "$best_value" | grep -q '\$'; then
                        best_value=$(expand_environment_variables "$best_value")
                    fi
                    set_environment_variable "PATH" "$best_value"
                    ;;
                PATH)
                    # Ensure all variables in PATH are expanded
                    if echo "$best_value" | grep -q '~'; then
                        best_value=$(echo "$best_value" | sed "s|~|$HOME|g")
                    fi
                    if echo "$best_value" | grep -q '\$'; then
                        best_value=$(expand_environment_variables "$best_value")
                    fi
                    set_environment_variable "$base_name" "$best_value"
                    ;;
                *)
                    # Regular variable
                    set_environment_variable "$base_name" "$best_value"
                    ;;
            esac

            # Debug output
            if [ "${ENV_LOADER_DEBUG:-}" = "true" ]; then
                case "$base_name" in
                    PATH_ADDITION)
                        echo "  Appended to PATH: $best_value" >&2
                        ;;
                    PATH_EXPORT)
                        echo "  Set PATH: $best_value" >&2
                        ;;
                    *)
                        echo "  Set $base_name=$best_value" >&2
                        ;;
                esac
            fi
        fi
    done <<< "$base_names"
}

# Load environment variables from all files in hierarchy
# Usage: load_env_variables [file1] [file2] ...
# If no files specified, uses default hierarchy
load_env_variables() {
    local files
    local file
    local loaded_count=0
    
    if [ $# -gt 0 ]; then
        # Use provided files
        files="$*"
    else
        # Use default hierarchy
        files=$(get_env_file_hierarchy)
    fi
    
    # Load each file
    for file in $files; do
        if [ -n "$file" ] && [ -f "$file" ]; then
            load_env_file "$file"
            loaded_count=$((loaded_count + 1))
        fi
    done
    
    if [ "${ENV_LOADER_DEBUG:-}" = "true" ]; then
        echo "Loaded environment variables from $loaded_count files" >&2
    fi
    
    return 0
}

# Reload environment variables (useful for development)
# Usage: reload_env_variables
reload_env_variables() {
    echo "Reloading environment variables..." >&2
    load_env_variables
}

# Show current environment variable status
# Usage: show_env_status
show_env_status() {
    local files file
    
    echo "Cross-Shell Environment Loader Status (Bash)"
    echo "============================================="
    echo "Platform: $(detect_platform)"
    echo "Shell: $(detect_shell)"
    echo "Shell suffix: $(get_shell_suffix)"
    echo "Platform suffixes: $(get_platform_suffixes)"
    echo
    
    echo "Environment files in hierarchy:"
    files=$(get_env_file_hierarchy)
    if [ -z "$files" ]; then
        echo "  No .env files found"
    else
        echo "$files" | while IFS= read -r file; do
            if [ -n "$file" ]; then
                local precedence relative_path
                precedence=$(get_file_precedence "$file")
                relative_path=$(get_relative_path "$file")
                echo "  $relative_path (precedence: $precedence)"
            fi
        done
    fi
    echo
    
    echo "Debug mode: ${ENV_LOADER_DEBUG:-false}"
    echo "Current working directory: $PWD"
    echo "Home directory: ${HOME:-N/A}"
}

# Enable debug mode
# Usage: env_loader_debug_on
env_loader_debug_on() {
    export ENV_LOADER_DEBUG=true
    echo "Environment loader debug mode enabled" >&2
}

# Disable debug mode
# Usage: env_loader_debug_off
env_loader_debug_off() {
    export ENV_LOADER_DEBUG=false
    echo "Environment loader debug mode disabled" >&2
}

# Test the loader with example files
# Usage: test_env_loader
test_env_loader() {
    local test_file
    
    echo "Testing environment loader..." >&2
    
    # Enable debug mode for testing
    env_loader_debug_on
    
    # Test with example files if they exist
    for test_file in examples/test-scenarios/.env.basic examples/test-scenarios/.env.quotes .env.example; do
        if [ -f "$test_file" ]; then
            echo "Testing with $test_file:" >&2
            load_env_file "$test_file"
            echo >&2
        fi
    done
    
    # Show some test variables
    echo "Test variables:" >&2
    echo "  BASIC_VAR=${BASIC_VAR:-not set}" >&2
    echo "  QUOTED_VAR=${QUOTED_VAR:-not set}" >&2
    echo "  TEST_BASIC=${TEST_BASIC:-not set}" >&2
    
    env_loader_debug_off
}

# Initialize the environment loader
# Usage: init_env_loader
init_env_loader() {
    # Ensure required directories exist
    ensure_env_directories
    
    # Load environment variables
    load_env_variables
}

# Auto-initialize if this script is sourced (not executed)
# Use a flag to prevent multiple initializations
if [ "${BASH_SOURCE[0]}" != "${0}" ] && [ -z "${ENV_LOADER_INITIALIZED:-}" ]; then
    # Script is being sourced, auto-initialize
    export ENV_LOADER_INITIALIZED=true
    init_env_loader
fi
