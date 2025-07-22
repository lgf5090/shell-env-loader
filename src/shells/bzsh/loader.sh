#!/bin/bash
# Ultra High-Performance Bash/Zsh Compatible Environment Variable Loader
# ======================================================================
# Based on ref/load_env.sh with minimal external commands and shell-specific optimizations

# Detect platform without external commands
detect_platform_fast() {
    case "$(uname -s)" in
        Linux*)
            if [ -n "${WSL_DISTRO_NAME:-}" ] || [ -n "${WSLENV:-}" ]; then
                echo "WSL"
            else
                echo "LINUX"
            fi
            ;;
        Darwin*) echo "MACOS" ;;
        CYGWIN*|MINGW*|MSYS*) echo "WIN" ;;
        *) echo "UNKNOWN" ;;
    esac
}

# Safe variable expansion without external commands
safe_expand_vars() {
    local value="$1"
    local max_depth=10
    local depth=0

    # First, check for command injection attempts and treat them as literal strings
    case "$value" in
        *'$('*|*'`'*) echo "$value"; return ;;
    esac

    # First handle tilde expansion (doesn't require $ symbol)
    case "$value" in
        *'~'*) value="${value//\~/$HOME}" ;;
    esac

    # Iterative variable expansion for compatibility
    while [[ "$value" == *'$'* ]] && ((depth < max_depth)); do
        local found_var=false

        # Expand common variables using parameter expansion
        case "$value" in
            *'$HOME'*) value="${value//\$HOME/$HOME}"; found_var=true ;;
        esac
        case "$value" in
            *'$USER'*) value="${value//\$USER/$USER}"; found_var=true ;;
        esac
        case "$value" in
            *'$PWD'*) value="${value//\$PWD/$PWD}"; found_var=true ;;
        esac

        # Expand other environment variables that are already set
        local common_vars="GOPATH GOROOT NODE_ENV PYTHONPATH JAVA_HOME MAVEN_HOME CARGO_HOME RUSTUP_HOME"
        for var in $common_vars; do
            case "$value" in
                *"\$$var"*)
                    local var_value=""
                    eval "var_value=\$$var"
                    if [ -n "$var_value" ]; then
                        value="${value//\$$var/$var_value}"
                        found_var=true
                    fi
                    ;;
            esac
        done

        # Expand any other variables that are already set (for PATH_ADDITION variables)
        # Extract variable names from $VAR patterns
        local temp_value="$value"
        while [[ "$temp_value" == *'$'* ]]; do
            # Find the next $VAR pattern
            local before="${temp_value%%\$*}"
            local after="${temp_value#*\$}"
            if [ "$after" != "$temp_value" ]; then
                # Extract variable name (alphanumeric and underscore only)
                local var_name=""
                local i=0
                while [ $i -lt ${#after} ]; do
                    local char="${after:$i:1}"
                    case "$char" in
                        [A-Za-z0-9_]) var_name="$var_name$char" ;;
                        *) break ;;
                    esac
                    i=$((i + 1))
                done

                if [ -n "$var_name" ]; then
                    local var_value=""
                    eval "var_value=\$$var_name"
                    if [ -n "$var_value" ]; then
                        value="${value//\$$var_name/$var_value}"
                        found_var=true
                    fi
                fi

                # Move past this variable for next iteration
                temp_value="${after#$var_name}"
            else
                break
            fi
        done

        [ "$found_var" = false ] && break
        depth=$((depth + 1))
    done

    echo "$value"
}

# Ultra-fast environment file loading
load_env_file() {
    local env_file="$1"
    local silent="${2:-false}"
    
    [ ! -f "$env_file" ] && return 0
    
    [ "$silent" != "true" ] && echo "Loading environment variables from: $env_file"
    
    # Get platform once for efficiency
    local platform=$(detect_platform_fast)
    
    # Read file line by line
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments using pattern matching (faster than regex)
        [ -z "$line" ] && continue
        case "$line" in
            \#*) continue ;;
        esac
        
        # Remove leading/trailing whitespace using parameter expansion
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # Skip if line doesn't contain '='
        case "$line" in
            *=*) ;;
            *) continue ;;
        esac
        
        # Extract key and value using parameter expansion (much faster than cut)
        local key="${line%%=*}"
        local value="${line#*=}"
        
        # Trim whitespace from key and value
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
        
        # Handle shell and platform-specific variables with optimized logic
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
                    WSL)
                        export_key="${key%_WSL}"
                        should_export=true
                        ;;
                esac
                ;;
            *_LINUX)
                case "$platform" in
                    LINUX)
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
            # Expand variables in value
            value=$(safe_expand_vars "$value")
            
            # Handle PATH additions
            case "$export_key" in
                PATH_ADDITION|PATH_ADDITIONS)
                    if [ -n "$value" ]; then
                        case ":$PATH:" in
                            *":$value:"*) ;;
                            *) export PATH="$value:$PATH" ;;
                        esac
                        [ "$silent" != "true" ] && echo "  Added to PATH: $value"
                    fi
                    ;;
                *)
                    export "$export_key"="$value"
                    [ "$silent" != "true" ] && echo "  Set $export_key=$value"
                    ;;
            esac
        fi
        
    done < "$env_file"
}

# Fast environment variables loading with minimal file system operations
load_env_variables() {
    local silent="${1:-false}"
    local loaded_count=0
    
    # Simple file hierarchy without external commands
    local files=""
    
    # Global user settings
    [ -f "$HOME/.env" ] && files="$files$HOME/.env "
    
    # User configuration directory  
    [ -f "$HOME/.cfgs/.env" ] && files="$files$HOME/.cfgs/.env "
    
    # Project-specific settings
    [ -f "$PWD/.env" ] && files="$files$PWD/.env "
    
    # Process files efficiently
    for file in $files; do
        if [ -n "$file" ] && [ -f "$file" ]; then
            load_env_file "$file" "$silent"
            loaded_count=$((loaded_count + 1))
        fi
    done
    
    [ "$silent" != "true" ] && echo "Loaded environment variables from $loaded_count files"
    
    return 0
}

# Fast initialization
init_env_loader() {
    local silent="${1:-false}"
    
    # Fast directory creation
    [ ! -d "$HOME/.cfgs" ] && mkdir -p "$HOME/.cfgs" 2>/dev/null
    
    # Load environment variables
    load_env_variables "$silent"
}

# Auto-initialize if this script is sourced
is_sourced() {
    if [ -n "${BASH_SOURCE[0]}" ]; then
        [ "${BASH_SOURCE[0]}" != "${0}" ]
    elif [ -n "${ZSH_VERSION}" ]; then
        [ "${(%):-%x}" != "${(%):-%N}" ]
    else
        case "$0" in
            *loader*.sh) return 1 ;;
            *) return 0 ;;
        esac
    fi
}

if is_sourced && [ -z "${ENV_LOADER_INITIALIZED:-}" ]; then
    export ENV_LOADER_INITIALIZED=true
    init_env_loader true  # Silent mode for auto-initialization
fi
