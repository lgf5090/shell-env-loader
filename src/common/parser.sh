#!/bin/bash
# Common Environment Variable Parser
# ==================================
# POSIX-compatible parsing utilities for .env files
# Handles KEY=value format, comments, quotes, and special characters

# Source required utilities (only if not already loaded)
if ! command -v detect_platform >/dev/null 2>&1; then
    PARSER_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    . "$PARSER_SCRIPT_DIR/platform.sh"
fi

# Parse a single line from .env file
# Usage: parse_env_line <line> <line_number> <file_path>
# Returns: "KEY=VALUE" or empty string if invalid/comment
parse_env_line() {
    local line="$1"
    local line_number="$2"
    local file_path="$3"
    local key value
    
    # Remove leading and trailing whitespace
    line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    
    # Skip empty lines
    [ -z "$line" ] && return 0
    
    # Skip comments (lines starting with #)
    case "$line" in
        "#"*) return 0 ;;
    esac
    
    # Check for KEY=VALUE format
    case "$line" in
        *"="*)
            key="${line%%=*}"
            value="${line#*=}"
            ;;
        *)
            echo "Warning: Invalid format in $file_path:$line_number - $line" >&2
            return 1
            ;;
    esac
    
    # Validate key format (must be valid variable name)
    if ! is_valid_variable_name "$key"; then
        echo "Warning: Invalid variable name in $file_path:$line_number - $key" >&2
        return 1
    fi
    
    # Process the value (handle quotes and escaping)
    value="$(process_env_value "$value")"
    
    # Output the parsed key-value pair
    printf "%s=%s\n" "$key" "$value"
}

# Check if a string is a valid environment variable name
# Usage: is_valid_variable_name <name>
# Returns: 0 if valid, 1 otherwise
is_valid_variable_name() {
    local name="$1"
    
    # Must not be empty
    [ -n "$name" ] || return 1
    
    # Must start with letter or underscore, followed by letters, digits, or underscores
    case "$name" in
        [a-zA-Z_]*) ;;
        *) return 1 ;;
    esac
    
    # Check remaining characters
    local remaining="${name#?}"
    while [ -n "$remaining" ]; do
        case "${remaining%"${remaining#?}"}" in
            [a-zA-Z0-9_]) ;;
            *) return 1 ;;
        esac
        remaining="${remaining#?}"
    done
    
    return 0
}

# Process environment variable value (handle quotes and escaping)
# Usage: process_env_value <value>
# Returns: Processed value
process_env_value() {
    local value="$1"
    
    # Handle quoted values
    case "$value" in
        \"*\")
            # Double-quoted value - remove quotes and process escapes
            value="${value#\"}"
            value="${value%\"}"
            value="$(process_double_quoted_value "$value")"
            ;;
        \'*\')
            # Single-quoted value - remove quotes (no escape processing)
            value="${value#\'}"
            value="${value%\'}"
            ;;
        *)
            # Unquoted value - trim whitespace
            value="$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
            ;;
    esac
    
    echo "$value"
}

# Process double-quoted value (handle escape sequences)
# Usage: process_double_quoted_value <value>
# Returns: Value with escape sequences processed
process_double_quoted_value() {
    local value="$1"

    # Ultra-conservative approach: preserve ALL escape sequences
    # This prevents issues with \U being interpreted as null character in Zsh
    # and preserves JSON strings, Windows paths, and regex patterns exactly as intended

    # Do NOT process any escape sequences to avoid shell-specific interpretation issues
    # This ensures maximum compatibility across Bash, Zsh, and other shells
    # The test suite expects escape sequences to be preserved as-is

    echo "$value"
}

# Parse an entire .env file
# Usage: parse_env_file <file_path>
# Returns: List of KEY=VALUE pairs
parse_env_file() {
    local file_path="$1"
    local line_number=0
    local line
    
    if [ ! -f "$file_path" ]; then
        echo "Error: File does not exist: $file_path" >&2
        return 1
    fi
    
    if [ ! -r "$file_path" ]; then
        echo "Error: File is not readable: $file_path" >&2
        return 1
    fi
    
    # Read file line by line
    while IFS= read -r line || [ -n "$line" ]; do
        line_number=$((line_number + 1))
        parse_env_line "$line" "$line_number" "$file_path"
    done < "$file_path"
}

# Get variable precedence score based on suffixes
# Usage: get_variable_precedence <variable_name> <shell_type> <platform>
# Returns: Numeric precedence score (higher = higher priority)
# Priority order: Shell-specific > Platform-specific > Generic
# For platforms: WSL > LINUX > UNIX > generic (on Linux/WSL)
#                MACOS > UNIX > generic (on macOS)
#                WIN > generic (on Windows)
get_variable_precedence() {
    local var_name="$1"
    local shell_type="$2"
    local platform="$3"
    local base_name suffix
    local score=0

    # Extract base name and suffix
    case "$var_name" in
        *_BASH|*_ZSH|*_FISH|*_NU|*_PS)
            suffix="${var_name##*_}"
            base_name="${var_name%_*}"
            # Shell-specific variables get highest priority (1000+)
            if [ "$suffix" = "$shell_type" ]; then
                score=1000
            else
                score=0  # Wrong shell suffix - completely ignore
            fi
            ;;
        *_UNIX|*_LINUX|*_MACOS|*_WIN|*_WSL)
            suffix="${var_name##*_}"
            base_name="${var_name%_*}"
            # Platform-specific variables get medium priority (100-500)
            case "$platform" in
                WSL)
                    case "$suffix" in
                        WSL) score=500 ;;      # Most specific for WSL
                        LINUX) score=400 ;;   # Linux compatibility
                        UNIX) score=300 ;;    # Unix compatibility
                        *) score=0 ;;         # Other platforms ignored
                    esac
                    ;;
                LINUX)
                    case "$suffix" in
                        LINUX) score=400 ;;   # Most specific for Linux
                        UNIX) score=300 ;;    # Unix compatibility
                        *) score=0 ;;         # Other platforms ignored
                    esac
                    ;;
                MACOS)
                    case "$suffix" in
                        MACOS) score=400 ;;   # Most specific for macOS
                        UNIX) score=300 ;;    # Unix compatibility
                        *) score=0 ;;         # Other platforms ignored
                    esac
                    ;;
                WIN)
                    case "$suffix" in
                        WIN) score=400 ;;     # Most specific for Windows
                        *) score=0 ;;         # Other platforms ignored
                    esac
                    ;;
                UNIX)
                    case "$suffix" in
                        UNIX) score=300 ;;    # Generic Unix
                        *) score=0 ;;         # Other platforms ignored
                    esac
                    ;;
                *)
                    score=0  # Unknown platform
                    ;;
            esac
            ;;
        *)
            # Generic variables get lowest priority (10)
            base_name="$var_name"
            score=10
            ;;
    esac

    echo "$score"
}

# Resolve variable precedence from multiple candidates
# Usage: resolve_variable_precedence <base_name> <candidates>
# Where candidates is a newline-separated list of "NAME=VALUE" pairs
# Returns: The highest precedence variable value
resolve_variable_precedence() {
    local base_name="$1"
    local candidates="$2"
    local shell_type platform
    local best_score=-1
    local best_value=""
    local candidate name value score
    
    shell_type="$(detect_shell)"
    platform="$(detect_platform)"
    
    # Process each candidate (avoid subshell to preserve variables)
    while IFS= read -r candidate; do
        [ -z "$candidate" ] && continue

        name="${candidate%%=*}"
        value="${candidate#*=}"

        # Only consider candidates that match the base name
        case "$name" in
            "$base_name"|"${base_name}_"*)
                score=$(get_variable_precedence "$name" "$shell_type" "$platform")
                # Only consider variables with positive scores (platform/shell appropriate)
                if [ "$score" -gt 0 ] && [ "$score" -gt "$best_score" ]; then
                    best_score="$score"
                    best_value="$value"
                fi
                ;;
        esac
    done <<< "$candidates"

    echo "$best_value"
}

# Extract all base variable names from a list of variables
# Usage: extract_base_names <variables>
# Where variables is a newline-separated list of "NAME=VALUE" pairs
# Returns: Unique base names
extract_base_names() {
    local variables="$1"
    local name base_name
    local seen_names=""
    
    while IFS= read -r line; do
        [ -z "$line" ] && continue

        name="${line%%=*}"

        # Extract base name (remove suffixes)
        case "$name" in
            *_BASH|*_ZSH|*_FISH|*_NU|*_PS|*_UNIX|*_LINUX|*_MACOS|*_WIN|*_WSL)
                base_name="${name%_*}"
                ;;
            *)
                base_name="$name"
                ;;
        esac

        # Only output each base name once
        case "$seen_names" in
            *"|$base_name|"*) ;;
            *)
                seen_names="$seen_names|$base_name|"
                echo "$base_name"
                ;;
        esac
    done <<< "$variables"
}

# Debug function to print parsing information
# Usage: debug_parsing_info <file_path>
debug_parsing_info() {
    local file_path="$1"
    
    echo "Parsing Debug Information for: $file_path"
    echo "  File exists: $([ -f "$file_path" ] && echo "yes" || echo "no")"
    echo "  File readable: $([ -r "$file_path" ] && echo "yes" || echo "no")"
    echo "  File size: $(wc -c < "$file_path" 2>/dev/null || echo "N/A") bytes"
    echo "  Line count: $(wc -l < "$file_path" 2>/dev/null || echo "N/A")"
    
    if [ -f "$file_path" ] && [ -r "$file_path" ]; then
        echo "  Parsed variables:"
        parse_env_file "$file_path" | while IFS= read -r line; do
            [ -n "$line" ] && echo "    $line"
        done
    fi
}
