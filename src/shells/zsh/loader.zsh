#!/usr/bin/env zsh
# Ultra High-Performance ZSH Environment Variable Loader
# ======================================================
# Self-contained ZSH loader with zero external dependencies

# Enable ZSH options for maximum performance
setopt EXTENDED_GLOB
setopt NULL_GLOB
setopt NO_NOMATCH
setopt LOCAL_OPTIONS
setopt LOCAL_TRAPS

# Detect platform without external commands
detect_platform_fast() {
    case "$(uname -s)" in
        Linux*)
            if [[ -n "${WSL_DISTRO_NAME:-}" || -n "${WSLENV:-}" ]]; then
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

# Safe variable expansion using ZSH features
safe_expand_vars() {
    local value="$1"
    local max_depth=10
    local depth=0

    # First, check for command injection attempts and treat them as literal strings
    [[ "$value" == *'$('* || "$value" == *'`'* ]] && { echo "$value"; return }

    # First handle tilde expansion (doesn't require $ symbol)
    if [[ "$value" == *'~'* ]]; then
        value="${value//\~/$HOME}"
    fi

    # Iterative variable expansion for compatibility
    while [[ "$value" == *'$'* ]] && ((depth < max_depth)); do
        local found_var=false

        # Expand common variables using ZSH parameter expansion
        if [[ "$value" == *'$HOME'* ]]; then
            value="${value//\$HOME/$HOME}"
            found_var=true
        fi
        if [[ "$value" == *'$USER'* ]]; then
            value="${value//\$USER/$USER}"
            found_var=true
        fi
        if [[ "$value" == *'$PWD'* ]]; then
            value="${value//\$PWD/$PWD}"
            found_var=true
        fi

        # Expand other environment variables that are already set
        local common_vars=(GOPATH GOROOT NODE_ENV PYTHONPATH JAVA_HOME MAVEN_HOME CARGO_HOME RUSTUP_HOME)
        for var in "${common_vars[@]}"; do
            if [[ "$value" == *"\$$var"* ]]; then
                local var_value="${(P)var}"  # ZSH indirect parameter expansion
                if [[ -n "$var_value" ]]; then
                    value="${value//\$$var/$var_value}"
                    found_var=true
                fi
            fi
        done

        # Expand any other variables that are already set (for PATH_ADDITION variables)
        # Extract variable names from $VAR patterns using ZSH
        local temp_value="$value"
        while [[ "$temp_value" == *'$'* ]]; do
            # Find the next $VAR pattern
            local before="${temp_value%%\$*}"
            local after="${temp_value#*\$}"
            if [[ "$after" != "$temp_value" ]]; then
                # Extract variable name (alphanumeric and underscore only)
                local var_name=""
                local i=1
                while [[ $i -le ${#after} ]]; do
                    local char="${after[$i]}"
                    if [[ "$char" == [A-Za-z0-9_] ]]; then
                        var_name="$var_name$char"
                    else
                        break
                    fi
                    ((i++))
                done

                if [[ -n "$var_name" ]]; then
                    local var_value="${(P)var_name}"  # ZSH indirect parameter expansion
                    if [[ -n "$var_value" ]]; then
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

        [[ "$found_var" == false ]] && break
        ((depth++))
    done

    echo "$value"
}

# Ultra-fast ZSH environment file loading using native ZSH features
# Usage: load_env_file <file_path> [silent]
load_env_file() {
    local env_file="$1"
    local silent="${2:-false}"

    [[ ! -f "$env_file" ]] && return 0

    [[ "$silent" != "true" ]] && print "Loading environment variables from: $env_file"

    # Get platform info once (ZSH caching)
    local platform=${_ENV_PLATFORM:-$(detect_platform_fast)}
    _ENV_PLATFORM="$platform"

    # ZSH associative arrays for best candidates (much faster than repeated lookups)
    local -A best_values best_scores

    # Platform-specific suffixes for fast matching
    # Priority: ZSH > Platform-specific > Platform > Generic Unix > No suffix
    # Note: We explicitly exclude other shell suffixes (_BASH, _FISH, etc.)
    local -a valid_suffixes
    case "$platform" in
        LINUX) valid_suffixes=(_ZSH _LINUX _UNIX) ;;
        WSL)   valid_suffixes=(_ZSH _WSL _LINUX _UNIX) ;;
        MACOS) valid_suffixes=(_ZSH _MACOS _UNIX) ;;
        WIN)   valid_suffixes=(_ZSH _WIN) ;;
        *)     valid_suffixes=(_ZSH _UNIX) ;;
    esac

    # Read entire file into array (ZSH is very efficient at this)
    local -a lines
    lines=("${(@f)$(<$env_file)}")

    # Process each line using ZSH's fast array iteration
    local line key value base_name suffix score
    for line in "${lines[@]}"; do
        # Skip empty lines and comments using ZSH pattern matching
        [[ -z "$line" || "$line" == [[:space:]]#\#* ]] && continue

        # Skip lines without '=' using ZSH pattern matching
        [[ "$line" != *=* ]] && continue

        # Extract key and value using ZSH parameter expansion (fastest method)
        key="${line%%=*}"
        value="${line#*=}"

        # Trim whitespace using ZSH parameter expansion
        key="${key##[[:space:]]#}"
        key="${key%%[[:space:]]#}"
        value="${value##[[:space:]]#}"
        value="${value%%[[:space:]]#}"

        # Validate key name using ZSH pattern matching
        [[ "$key" != [A-Za-z_][A-Za-z0-9_]# ]] && continue

        # Remove quotes using ZSH parameter expansion (much faster than sed)
        [[ "$value" == \"*\" ]] && value="${value[2,-2]}"
        [[ "$value" == \'*\' ]] && value="${value[2,-2]}"

        # Calculate priority score and base name using ZSH's fast suffix matching
        base_name="$key"
        score=10  # Default score for variables without suffix

        # Check if key ends with any valid suffix (ZSH array contains check is very fast)
        local found_suffix=""
        for suffix in "${valid_suffixes[@]}"; do
            if [[ "$key" == *"$suffix" ]]; then
                found_suffix="$suffix"
                base_name="${key%$suffix}"
                break
            fi
        done

        # Assign priority scores (ZSH case is very fast)
        if [[ -n "$found_suffix" ]]; then
            case "$found_suffix" in
                _ZSH)   score=1000 ;;  # Highest priority for ZSH
                _WSL)   score=500 ;;   # Platform-specific
                _LINUX) score=400 ;;
                _MACOS) score=400 ;;
                _WIN)   score=400 ;;
                _UNIX)  score=300 ;;   # Generic Unix
            esac
        fi

        # Skip if we have a better value for this base name (ZSH associative array lookup is O(1))
        [[ -n "${best_scores[$base_name]}" && "${best_scores[$base_name]}" -ge "$score" ]] && continue

        # Store the best candidate
        best_scores[$base_name]="$score"
        best_values[$base_name]="$value"
    done

    # Two-phase export to handle variable dependencies correctly
    local export_key export_value

    # Phase 1: Export all regular variables first (excluding PATH_ADDITION)
    for base_name in "${(@k)best_values}"; do
        # Skip PATH_ADDITION variables in phase 1
        case "$base_name" in
            PATH_ADDITION|PATH_ADDITIONS) continue ;;
        esac

        export_value="${best_values[$base_name]}"
        # Expand variables in value using enhanced expansion
        export_value=$(safe_expand_vars "$export_value")

        export "$base_name"="$export_value"
        [[ "$silent" != "true" ]] && print -r "  Set $base_name=$export_value"
    done

    # Phase 2: Process PATH_ADDITION variables after all regular variables are exported
    for base_name in "${(@k)best_values}"; do
        # Only process PATH_ADDITION variables in phase 2
        case "$base_name" in
            PATH_ADDITION|PATH_ADDITIONS) ;;
            *) continue ;;
        esac

        export_value="${best_values[$base_name]}"
        # Now all dependency variables should be available for expansion
        export_value=$(safe_expand_vars "$export_value")

        if [[ -n "$export_value" && ":$PATH:" != *":$export_value:"* ]]; then
            export PATH="$export_value:$PATH"
            [[ "$silent" != "true" ]] && print -r "  Added to PATH: $export_value"
        fi
    done
}

# Ultra-fast ZSH environment variables loading using native arrays
load_env_variables() {
    local silent="${1:-false}"
    local -a files_to_load
    local loaded_count=0

    if (( $# > 1 )); then
        # Use provided files (skip first argument which is silent flag)
        files_to_load=("${@[2,-1]}")
    else
        # Simple file hierarchy without external commands
        local -a temp_files

        # Global user settings
        [[ -f "$HOME/.env" ]] && temp_files+=("$HOME/.env")

        # User configuration directory
        [[ -f "$HOME/.cfgs/.env" ]] && temp_files+=("$HOME/.cfgs/.env")

        # Project-specific settings
        [[ -f "$PWD/.env" ]] && temp_files+=("$PWD/.env")

        files_to_load=("${temp_files[@]}")
    fi

    # Process files using ZSH's efficient array iteration
    local file
    for file in "${files_to_load[@]}"; do
        if [[ -n "$file" && -f "$file" ]]; then
            load_env_file "$file" "$silent"
            (( loaded_count++ ))
        fi
    done

    [[ "$silent" != "true" ]] && print -r "Loaded environment variables from $loaded_count files"

    return 0
}

# Fast ZSH initialization
init_env_loader() {
    local silent="${1:-false}"

    # Fast directory creation
    [[ ! -d "$HOME/.cfgs" ]] && mkdir -p "$HOME/.cfgs" 2>/dev/null

    # Load environment variables
    load_env_variables "$silent"
}

# ZSH-specific sourcing detection (much faster than generic method)
is_sourced() {
    [[ "${(%):-%x}" != "${(%):-%N}" ]]
}

# Auto-initialize with ZSH-specific optimization
if is_sourced && [[ -z "${ENV_LOADER_INITIALIZED:-}" ]]; then
    export ENV_LOADER_INITIALIZED=true
    init_env_loader true  # Silent mode for auto-initialization
fi
