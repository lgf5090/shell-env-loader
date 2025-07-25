#!/usr/bin/env zsh
# Ultra High-Performance ZSH Environment Variable Loader
# ===============================================
# ZSH-specific optimized implementation using native ZSH features

# Enable ZSH options for maximum performance
setopt EXTENDED_GLOB
setopt NULL_GLOB
setopt NO_NOMATCH
setopt LOCAL_OPTIONS
setopt LOCAL_TRAPS

# Get script directory using ZSH-specific method
SCRIPT_DIR="${${(%):-%x}:A:h}"

# Source common utilities
COMMON_DIR="$SCRIPT_DIR/../common"
. "$COMMON_DIR/platform.sh"
. "$COMMON_DIR/hierarchy.sh"

# Ultra-fast ZSH environment file loading using native ZSH features
# Usage: load_env_file <file_path>
load_env_file() {
    local env_file="$1"

    [[ ! -f "$env_file" ]] && return 0

    # Get platform info once (ZSH caching)
    local platform=${_ENV_PLATFORM:-$(detect_platform)}
    _ENV_PLATFORM="$platform"

    # ZSH associative arrays for best candidates (much faster than repeated lookups)
    local -A best_values best_scores

    # Platform-specific suffixes for fast matching
    local -a valid_suffixes
    case "$platform" in
        LINUX) valid_suffixes=(_ZSH _WSL _LINUX _UNIX) ;;
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

    # Export all best variables using ZSH's efficient associative array iteration
    local export_key export_value
    for base_name in "${(@k)best_values}"; do
        export_value="${best_values[$base_name]}"

        # Fast variable expansion using ZSH parameter expansion
        [[ "$export_value" == *'$HOME'* ]] && export_value="${export_value//\$HOME/$HOME}"
        [[ "$export_value" == *'$USER'* ]] && export_value="${export_value//\$USER/$USER}"
        [[ "$export_value" == *'$PWD'* ]] && export_value="${export_value//\$PWD/$PWD}"
        [[ "$export_value" == *'~'* ]] && export_value="${export_value//\~/$HOME}"

        # Handle PATH additions with ZSH pattern matching
        case "$base_name" in
            PATH_ADDITION|PATH_ADDITIONS)
                if [[ -n "$export_value" && ":$PATH:" != *":$export_value:"* ]]; then
                    export PATH="$export_value:$PATH"
                    [[ "${ENV_LOADER_DEBUG:-}" == "true" ]] && print -r "  Added to PATH: $export_value" >&2
                fi
                ;;
            *)
                export "$base_name"="$export_value"
                [[ "${ENV_LOADER_DEBUG:-}" == "true" ]] && print -r "  Set $base_name=$export_value" >&2
                ;;
        esac
    done
}

# Ultra-fast ZSH environment variables loading using native arrays
load_env_variables() {
    local -a files_to_load
    local loaded_count=0

    if (( $# > 0 )); then
        # Use provided files
        files_to_load=("$@")
    else
        # Get hierarchy and convert to array efficiently
        local files_string=$(get_env_file_hierarchy)
        files_to_load=("${(@f)files_string}")
    fi

    # Process files using ZSH's efficient array iteration
    local file
    for file in "${files_to_load[@]}"; do
        if [[ -n "$file" && -f "$file" ]]; then
            load_env_file "$file"
            (( loaded_count++ ))
        fi
    done

    [[ "${ENV_LOADER_DEBUG:-}" == "true" ]] && print -r "Loaded environment variables from $loaded_count files" >&2

    return 0
}

# Fast ZSH initialization
init_env_loader() {
    ensure_env_directories
    load_env_variables
}

# ZSH-specific sourcing detection (much faster than generic method)
is_sourced() {
    [[ "${(%):-%x}" != "${(%):-%N}" ]]
}

# Auto-initialize with ZSH-specific optimization
if is_sourced && [[ -z "${ENV_LOADER_INITIALIZED:-}" ]]; then
    export ENV_LOADER_INITIALIZED=true
    init_env_loader
fi
