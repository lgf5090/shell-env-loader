#!/bin/bash
# Simple High-Performance Bash/Zsh Compatible Environment Variable Loader
# ===============================================
# Optimized implementation based on ref/load_env.sh approach

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

# Simple environment file loading (bash/zsh compatible)
# Usage: load_env_file <file_path>
load_env_file() {
    local env_file="$1"
    
    [ ! -f "$env_file" ] && return 0
    
    # Get shell and platform info
    local shell_suffix=""
    local platform_suffix=""
    
    # Detect shell
    if [ -n "$BASH_VERSION" ]; then
        shell_suffix="_BASH"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_suffix="_ZSH"
    fi
    
    # Detect platform
    local platform=$(detect_platform)
    case "$platform" in
        LINUX) platform_suffix="_LINUX" ;;
        MACOS) platform_suffix="_MACOS" ;;
        WIN) platform_suffix="_WIN" ;;
        WSL) platform_suffix="_WSL" ;;
    esac
    
    # Read file line by line
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        case "$line" in
            ''|'#'*) continue ;;
        esac
        
        # Skip lines without '='
        case "$line" in
            *=*) ;;
            *) continue ;;
        esac
        
        # Extract key and value
        local key=$(echo "$line" | cut -d'=' -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        local value=$(echo "$line" | cut -d'=' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Validate key name
        case "$key" in
            *[!A-Za-z0-9_]*) continue ;;
            [0-9]*) continue ;;
        esac
        
        # Remove quotes if present
        case "$value" in
            \"*\") value=$(echo "$value" | sed 's/^"//;s/"$//') ;;
            \'*\') value=$(echo "$value" | sed "s/^'//;s/'$//") ;;
        esac
        
        # Determine if we should export this variable
        local should_export=false
        local export_key="$key"
        
        # Handle shell-specific variables (highest priority)
        case "$key" in
            *_BASH)
                if [ -n "$BASH_VERSION" ]; then
                    export_key=$(echo "$key" | sed 's/_BASH$//')
                    should_export=true
                fi
                ;;
            *_ZSH)
                if [ -n "$ZSH_VERSION" ]; then
                    export_key=$(echo "$key" | sed 's/_ZSH$//')
                    should_export=true
                fi
                ;;
            *_FISH|*_NU|*_PS)
                # Skip other shell variables
                continue
                ;;
            *_WSL)
                if [ "$platform" = "WSL" ] || [ "$platform" = "LINUX" ]; then
                    export_key=$(echo "$key" | sed 's/_WSL$//')
                    should_export=true
                fi
                ;;
            *_LINUX)
                if [ "$platform" = "LINUX" ] || [ "$platform" = "WSL" ]; then
                    export_key=$(echo "$key" | sed 's/_LINUX$//')
                    should_export=true
                fi
                ;;
            *_MACOS)
                if [ "$platform" = "MACOS" ]; then
                    export_key=$(echo "$key" | sed 's/_MACOS$//')
                    should_export=true
                fi
                ;;
            *_UNIX)
                case "$platform" in
                    LINUX|WSL|MACOS) 
                        export_key=$(echo "$key" | sed 's/_UNIX$//')
                        should_export=true
                        ;;
                esac
                ;;
            *_WIN|*_WINDOWS)
                if [ "$platform" = "WIN" ]; then
                    export_key=$(echo "$key" | sed 's/_WIN\(DOWS\)\?$//')
                    should_export=true
                fi
                ;;
            *)
                # Regular variable - export if no shell/platform specific version exists
                should_export=true
                ;;
        esac
        
        if [ "$should_export" = true ]; then
            # Simple variable expansion for common cases
            case "$value" in
                *'$HOME'*) value=$(echo "$value" | sed "s|\$HOME|$HOME|g") ;;
            esac
            case "$value" in
                *'$USER'*) value=$(echo "$value" | sed "s|\$USER|$USER|g") ;;
            esac
            case "$value" in
                *'~'*) value=$(echo "$value" | sed "s|~|$HOME|g") ;;
            esac
            
            # Handle PATH additions
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
    
    # Process files (handle ZSH differently)
    if [ -n "$ZSH_VERSION" ]; then
        # ZSH-specific handling
        setopt SH_WORD_SPLIT 2>/dev/null || true
        local IFS_OLD="$IFS"
        IFS=$'\n'
        local -a files_array
        files_array=(${(f)files})
        for file in "${files_array[@]}"; do
            if [ -n "$file" ] && [ -f "$file" ]; then
                load_env_file "$file"
                loaded_count=$((loaded_count + 1))
            fi
        done
        IFS="$IFS_OLD"
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
