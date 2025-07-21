#!/bin/bash
# Bash/Zsh Compatible Environment Variable Loader
# ===============================================
# Compatible implementation for both Bash and Zsh shells
# Uses POSIX-compatible commands with shell-specific optimizations

# Get the directory of this script (compatible with both bash and zsh)
if [ -n "${BASH_SOURCE[0]}" ]; then
    # Bash
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "${(%):-%x}" ]; then
    # Zsh - use safer method for sourced scripts
    local script_path="${(%):-%x}"
    SCRIPT_DIR="${script_path:A:h}"
else
    # Fallback
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

# Source common utilities (adjust path for installation location)
# When installed, this script is in ~/.local/share/env-loader/{bash,zsh}/
# and common files are in ~/.local/share/env-loader/common/
COMMON_DIR="$SCRIPT_DIR/../common"
. "$COMMON_DIR/platform.sh"
. "$COMMON_DIR/hierarchy.sh"
. "$COMMON_DIR/parser.sh"

# Detect current shell for compatibility
# Usage: get_current_shell
# Returns: BASH or ZSH
get_current_shell() {
    if [ -n "${BASH_VERSION}" ]; then
        echo "BASH"
    elif [ -n "${ZSH_VERSION}" ]; then
        echo "ZSH"
    else
        echo "UNKNOWN"
    fi
}

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

# Expand environment variables in a value (bash/zsh compatible)
# Usage: expand_environment_variables <value>
# Returns: Value with environment variables expanded
expand_environment_variables() {
    local value="$1"
    local expanded
    local current_shell

    current_shell=$(get_current_shell)

    # Use shell-appropriate expansion method
    case "$current_shell" in
        ZSH)
            # Use zsh's print command for expansion
            expanded=$(eval "print -r -- \"$value\"" 2>/dev/null || print -r -- "$value")
            ;;
        BASH|*)
            # Use bash/POSIX compatible method
            expanded=$(eval "printf '%s' \"$value\"" 2>/dev/null || printf '%s' "$value")
            ;;
    esac

    echo "$expanded"
}

# Process candidates for a base name (shared logic)
# Usage: process_candidates_for_base_name <base_name> <candidates>
process_candidates_for_base_name() {
    local base_name="$1"
    local candidates="$2"
    local best_value

    # Resolve precedence and get the best value
    best_value=$(resolve_variable_precedence "$base_name" "$candidates")

    if [ -n "$best_value" ]; then
        # Expand environment variables if needed
        if echo "$best_value" | grep --color=never -q '\$'; then
            best_value=$(expand_environment_variables "$best_value")
        fi

        # Special handling for PATH variables
        case "$base_name" in
            PATH_ADDITION)
                # Expand tilde and variables in PATH addition
                if echo "$best_value" | grep --color=never -q '~'; then
                    best_value=$(echo "$best_value" | sed "s|~|$HOME|g")
                fi
                if echo "$best_value" | grep --color=never -q '\$'; then
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
                if echo "$best_value" | grep --color=never -q '~'; then
                    best_value=$(echo "$best_value" | sed "s|~|$HOME|g")
                fi
                if echo "$best_value" | grep --color=never -q '\$'; then
                    best_value=$(expand_environment_variables "$best_value")
                fi
                set_environment_variable "PATH" "$best_value"
                ;;
            PATH)
                # Ensure all variables in PATH are expanded
                if echo "$best_value" | grep --color=never -q '~'; then
                    best_value=$(echo "$best_value" | sed "s|~|$HOME|g")
                fi
                if echo "$best_value" | grep --color=never -q '\$'; then
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
    
    # Process each base name (bash-compatible method with zsh compatibility)
    current_shell=$(get_current_shell)

    # Set zsh compatibility options if running in zsh
    if [ "$current_shell" = "ZSH" ]; then
        # Enable bash-like behavior in zsh
        setopt SH_WORD_SPLIT 2>/dev/null || true
        setopt POSIX_BUILTINS 2>/dev/null || true
    fi

    # Use for loop instead of while read to avoid subshell (works in both shells)
    local IFS_OLD="$IFS"

    if [ "$current_shell" = "ZSH" ]; then
        # ZSH-specific array handling
        local -a base_names_array
        IFS=$'\n' base_names_array=(${(f)base_names})
        for base_name in "${base_names_array[@]}"; do
            [ -z "$base_name" ] && continue

            # Use zsh native pattern matching to avoid grep binary file issues
            candidates=""
            local -a parsed_vars_array
            IFS=$'\n' parsed_vars_array=(${(f)parsed_vars})
            for line in "${parsed_vars_array[@]}"; do
                case "$line" in
                    ${base_name}=*|${base_name}_*=*)
                        if [ -z "$candidates" ]; then
                            candidates="$line"
                        else
                            candidates="$candidates
$line"
                        fi
                        ;;
                esac
            done

            # Process the candidates (shared logic)
            process_candidates_for_base_name "$base_name" "$candidates"
        done
    else
        # BASH-specific handling
        IFS=$'\n'
        for base_name in $base_names; do
            IFS="$IFS_OLD"
            [ -z "$base_name" ] && continue

            # Use grep for bash with color disabled
            candidates=$(echo "$parsed_vars" | grep --color=never "^${base_name}\(=\|_.*=\)")

            # Process the candidates (shared logic)
            process_candidates_for_base_name "$base_name" "$candidates"
        done
    fi
    IFS="$IFS_OLD"
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
    
    # Load each file (handle ZSH differently)
    local current_shell=$(get_current_shell)
    if [ "$current_shell" = "ZSH" ]; then
        # ZSH-specific array handling
        local -a files_array
        IFS=$'\n' files_array=(${(f)files})
        for file in "${files_array[@]}"; do
            if [ -n "$file" ] && [ -f "$file" ]; then
                load_env_file "$file"
                loaded_count=$((loaded_count + 1))
            fi
        done
    else
        # BASH handling
        for file in $files; do
            if [ -n "$file" ] && [ -f "$file" ]; then
                load_env_file "$file"
                loaded_count=$((loaded_count + 1))
            fi
        done
    fi
    
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
# Compatible with both bash and zsh
is_sourced() {
    if [ -n "${BASH_SOURCE[0]}" ]; then
        # Bash: check if BASH_SOURCE[0] != $0
        [ "${BASH_SOURCE[0]}" != "${0}" ]
    elif [ -n "${ZSH_VERSION}" ]; then
        # Zsh: check if script is being sourced
        [ "${(%):-%x}" != "${(%):-%N}" ]
    else
        # Fallback: assume sourced if $0 doesn't end with this script name
        case "$0" in
            *loader.sh) return 1 ;;
            *) return 0 ;;
        esac
    fi
}

if is_sourced && [ -z "${ENV_LOADER_INITIALIZED:-}" ]; then
    # Script is being sourced, auto-initialize
    export ENV_LOADER_INITIALIZED=true
    init_env_loader
fi
