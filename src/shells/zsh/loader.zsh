#!/bin/zsh
# Zsh Environment Variable Loader
# ================================
# Zsh-specific implementation of the cross-shell environment loader
# Uses zsh built-in commands for optimal performance

# Get the directory of this script
SCRIPT_DIR="${0:A:h}"

# Source common utilities (only if not already loaded)
if ! command -v detect_platform >/dev/null 2>&1; then
    . "$SCRIPT_DIR/../../common/platform.sh"
fi
if ! command -v get_env_file_hierarchy >/dev/null 2>&1; then
    . "$SCRIPT_DIR/../../common/hierarchy.sh"
fi
if ! command -v parse_env_file >/dev/null 2>&1; then
    . "$SCRIPT_DIR/../../common/parser.sh"
fi

# Set environment variable using zsh built-ins
# Usage: set_environment_variable <key> <value>
set_environment_variable() {
    local key="$1"
    local value="$2"
    
    # Validate key
    if ! is_valid_variable_name "$key"; then
        echo "Warning: Invalid variable name: $key" >&2
        return 1
    fi
    
    # Export the variable using zsh syntax
    export "$key=$value"
    return 0
}

# Expand environment variables in a value (zsh-specific)
# Usage: expand_environment_variables <value>
# Returns: Value with environment variables expanded
expand_environment_variables() {
    local value="$1"
    local expanded
    
    # Use zsh's parameter expansion with eval
    # This is safe because we're in a controlled environment
    expanded=$(eval "print -r -- \"$value\"" 2>/dev/null || print -r -- "$value")
    
    print -r -- "$expanded"
}

# Load environment variables from a single file
# Usage: load_env_file <file_path>
load_env_file() {
    local file_path="$1"
    local shell_type platform
    local parsed_vars base_names base_name
    local candidates best_value
    
    if [[ ! -f "$file_path" ]]; then
        return 0  # Silently skip missing files
    fi
    
    # Get current shell and platform
    shell_type=$(detect_shell)
    platform=$(detect_platform)
    
    echo "Loading environment variables from: $(get_relative_path "$file_path")" >&2
    
    # Parse the file
    parsed_vars=$(parse_env_file "$file_path")
    if [[ $? -ne 0 ]]; then
        echo "Warning: Failed to parse $file_path" >&2
        return 1
    fi
    
    # Extract unique base names
    base_names=$(extract_base_names "$parsed_vars")
    
    # Process each base name (use zsh array processing)
    local -a base_name_array
    base_name_array=(${(f)base_names})
    
    for base_name in $base_name_array; do
        [[ -z "$base_name" ]] && continue
        
        # Find all candidates for this base name using zsh pattern matching
        local -a parsed_lines candidates_array
        parsed_lines=(${(f)parsed_vars})
        candidates_array=()
        for line in $parsed_lines; do
            if [[ "$line" == ${base_name}=* ]] || [[ "$line" == ${base_name}_*=* ]]; then
                candidates_array+=("$line")
            fi
        done
        candidates="${(F)candidates_array}"
        
        # Resolve precedence and get the best value
        best_value=$(resolve_variable_precedence "$base_name" "$candidates")
        
        if [[ -n "$best_value" ]]; then
            # Expand environment variables if needed
            if [[ "$best_value" == *'$'* ]]; then
                best_value=$(expand_environment_variables "$best_value")
            fi
            
            # Special handling for PATH variables
            case "$base_name" in
                PATH_ADDITION)
                    # Expand tilde and variables in PATH addition
                    if [[ "$best_value" == *'~'* ]]; then
                        best_value=${best_value//\~/$HOME}
                    fi
                    if [[ "$best_value" == *'$'* ]]; then
                        best_value=$(expand_environment_variables "$best_value")
                    fi
                    # Append to existing PATH
                    if [[ -n "$PATH" ]]; then
                        best_value="$PATH:$best_value"
                    fi
                    set_environment_variable "PATH" "$best_value"
                    ;;
                PATH_EXPORT)
                    # Direct PATH replacement (already includes $PATH)
                    # Expand tilde and variables
                    if [[ "$best_value" == *'~'* ]]; then
                        best_value=${best_value//\~/$HOME}
                    fi
                    if [[ "$best_value" == *'$'* ]]; then
                        best_value=$(expand_environment_variables "$best_value")
                    fi
                    set_environment_variable "PATH" "$best_value"
                    ;;
                PATH)
                    # Ensure all variables in PATH are expanded
                    if [[ "$best_value" == *'~'* ]]; then
                        best_value=${best_value//\~/$HOME}
                    fi
                    if [[ "$best_value" == *'$'* ]]; then
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
            if [[ "${ENV_LOADER_DEBUG:-}" == "true" ]]; then
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
    done
}

# Load environment variables from all files in hierarchy
# Usage: load_env_variables [file1] [file2] ...
# If no files specified, uses default hierarchy
load_env_variables() {
    local files
    local file
    local loaded_count=0
    
    if [[ $# -gt 0 ]]; then
        # Use provided files
        files=("$@")
    else
        # Use default hierarchy (convert to array)
        local hierarchy_output
        hierarchy_output=$(get_env_file_hierarchy)
        files=(${(f)hierarchy_output})
    fi
    
    # Load each file
    for file in $files; do
        if [[ -n "$file" && -f "$file" ]]; then
            load_env_file "$file"
            ((loaded_count++))
        fi
    done
    
    if [[ "${ENV_LOADER_DEBUG:-}" == "true" ]]; then
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
    
    echo "Cross-Shell Environment Loader Status (Zsh)"
    echo "============================================"
    echo "Platform: $(detect_platform)"
    echo "Shell: $(detect_shell)"
    echo "Shell suffix: $(get_shell_suffix)"
    echo "Platform suffixes: $(get_platform_suffixes)"
    echo
    
    echo "Environment files in hierarchy:"
    files=$(get_env_file_hierarchy)
    if [[ -z "$files" ]]; then
        echo "  No .env files found"
    else
        echo "$files" | while IFS= read -r file; do
            if [[ -n "$file" ]]; then
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
        if [[ -f "$test_file" ]]; then
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
if [[ "${(%):-%x}" != "${(%):-%N}" ]] && [[ -z "${ENV_LOADER_INITIALIZED:-}" ]]; then
    # Script is being sourced, auto-initialize
    export ENV_LOADER_INITIALIZED=true
    init_env_loader
fi
