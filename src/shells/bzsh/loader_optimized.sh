#!/bin/bash
# Ultra High-Performance Bash/Zsh Compatible Environment Variable Loader
# ======================================================================
# Optimized based on ref/load_env.sh approach with minimal external commands

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
COMMON_DIR="$SCRIPT_DIR/../common"
. "$COMMON_DIR/platform.sh"
. "$COMMON_DIR/hierarchy.sh"

# Ultra-fast environment file loading using minimal external commands
# Usage: load_env_file <file_path>
load_env_file() {
    local env_file="$1"
    
    [ ! -f "$env_file" ] && return 0
    
    # Get platform once for efficiency
    local platform=$(detect_platform)
    
    # Read file line by line
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments using pattern matching
        [ -z "$line" ] && continue
        case "$line" in
            \#*) continue ;;
        esac
        
        # Skip lines without '=' using pattern matching
        case "$line" in
            *=*) ;;
            *) continue ;;
        esac
        
        # Extract key and value using shell parameter expansion (MUCH faster)
        local key="${line%%=*}"
        local value="${line#*=}"
        
        # Trim whitespace using parameter expansion
        key="${key#"${key%%[![:space:]]*}"}"
        key="${key%"${key##*[![:space:]]}"}"
        value="${value#"${value%%[![:space:]]*}"}"
        value="${value%"${value##*[![:space:]]}"}"
        
        # Validate key name using pattern matching
        case "$key" in
            [A-Za-z_]*) ;;
            *) continue ;;
        esac
        case "$key" in
            *[!A-Za-z0-9_]*) continue ;;
        esac
        
        # Remove quotes using parameter expansion (much faster than sed)
        case "$value" in
            \"*\") value="${value#\"}" ; value="${value%\"}" ;;
            \'*\') value="${value#\'}" ; value="${value%\'}" ;;
        esac
        
        # Handle platform and shell-specific variables with optimized logic
        local should_export=false
        local export_key="$key"
        
        case "$key" in
            *_BASH)
                if [ -n "$BASH_VERSION" ]; then
                    export_key="${key%_BASH}"
                    should_export=true
                fi
                ;;
            *_ZSH)
                if [ -n "$ZSH_VERSION" ]; then
                    export_key="${key%_ZSH}"
                    should_export=true
                fi
                ;;
            *_FISH|*_NU|*_PS)
                # Skip other shell variables
                continue
                ;;
            *_WSL)
                case "$platform" in
                    WSL|LINUX)
                        export_key="${key%_WSL}"
                        should_export=true
                        ;;
                esac
                ;;
            *_LINUX)
                case "$platform" in
                    LINUX|WSL)
                        export_key="${key%_LINUX}"
                        should_export=true
                        ;;
                esac
                ;;
            *_MACOS)
                case "$platform" in
                    MACOS)
                        export_key="${key%_MACOS}"
                        should_export=true
                        ;;
                esac
                ;;
            *_UNIX)
                case "$platform" in
                    LINUX|WSL|MACOS)
                        export_key="${key%_UNIX}"
                        should_export=true
                        ;;
                esac
                ;;
            *_WIN|*_WINDOWS)
                case "$platform" in
                    WIN)
                        export_key="${key%_WIN*}"
                        should_export=true
                        ;;
                esac
                ;;
            *)
                # Regular variable - always export
                should_export=true
                ;;
        esac
        
        if [ "$should_export" = true ]; then
            # Fast variable expansion for common cases using parameter expansion
            case "$value" in
                *'$HOME'*) value="${value//\$HOME/$HOME}" ;;
            esac
            case "$value" in
                *'$USER'*) value="${value//\$USER/$USER}" ;;
            esac
            case "$value" in
                *'~'*) value="${value//\~/$HOME}" ;;
            esac
            
            # Handle PATH additions efficiently
            case "$export_key" in
                PATH_ADDITION|PATH_ADDITIONS)
                    if [ -n "$value" ]; then
                        case ":$PATH:" in
                            *":$value:"*) ;;
                            *) export PATH="$value:$PATH" ;;
                        esac
                        [ "${ENV_LOADER_DEBUG:-}" = "true" ] && echo "  Added to PATH: $value" >&2
                    fi
                    ;;
                *)
                    export "$export_key"="$value"
                    [ "${ENV_LOADER_DEBUG:-}" = "true" ] && echo "  Set $export_key=$value" >&2
                    ;;
            esac
        fi
        
    done < "$env_file"
}

# Load environment variables from all files in hierarchy
load_env_variables() {
    local files
    local file
    local loaded_count=0
    
    if [ $# -gt 0 ]; then
        files="$*"
    else
        files=$(get_env_file_hierarchy)
    fi
    
    # Process files efficiently
    for file in $files; do
        if [ -n "$file" ] && [ -f "$file" ]; then
            load_env_file "$file"
            loaded_count=$((loaded_count + 1))
        fi
    done
    
    [ "${ENV_LOADER_DEBUG:-}" = "true" ] && echo "Loaded environment variables from $loaded_count files" >&2
    
    return 0
}

# Initialize the environment loader
init_env_loader() {
    # Ensure required directories exist
    ensure_env_directories
    
    # Load environment variables
    load_env_variables
}

# Auto-initialize if this script is sourced
is_sourced() {
    if [ -n "${BASH_SOURCE[0]}" ]; then
        [ "${BASH_SOURCE[0]}" != "${0}" ]
    elif [ -n "${ZSH_VERSION}" ]; then
        [ "${(%):-%x}" != "${(%):-%N}" ]
    else
        case "$0" in
            *loader.sh) return 1 ;;
            *) return 0 ;;
        esac
    fi
}

if is_sourced && [ -z "${ENV_LOADER_INITIALIZED:-}" ]; then
    export ENV_LOADER_INITIALIZED=true
    init_env_loader
fi
