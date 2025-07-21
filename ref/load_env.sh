#!/usr/bin/env bash
# Cross-platform Environment Variables Loader for bash/zsh
# Loads .env files in order: $HOME/.env -> $HOME/.cfgs/.env -> $PWD/.env
# Supports variable expansion and platform-specific variables

# Function to safely expand variables
safe_expand_vars() {
    local value="$1"
    local max_depth=10
    local depth=0
    
    # First, check for command injection attempts and treat them as literal strings
    if [[ "$value" == *'$('* ]] || [[ "$value" == *'`'* ]]; then
        # Contains command substitution - treat as literal string
        echo "$value"
        return
    fi
    
    # Simple variable expansion for compatibility
    while [[ "$value" == *'$'* ]] && ((depth < max_depth)); do
        local found_var=false
        
        # Handle $HOME specifically (most common case)
        if [[ "$value" == *'$HOME'* ]]; then
            value="${value//\$HOME/$HOME}"
            found_var=true
        fi
        
        # Handle other common variables - compatible approach
        local common_vars=(USER PWD SHELL EDITOR GOPATH GOROOT NODE_ENV PYTHONPATH JAVA_HOME MAVEN_HOME)
        for var in "${common_vars[@]}"; do
            if [[ "$value" == *"\$$var"* ]]; then
                local var_value=""
                case "$var" in
                    USER) var_value="$USER" ;;
                    PWD) var_value="$PWD" ;;
                    SHELL) var_value="$SHELL" ;;
                    EDITOR) var_value="$EDITOR" ;;
                    GOPATH) var_value="$GOPATH" ;;
                    GOROOT) var_value="$GOROOT" ;;
                    NODE_ENV) var_value="$NODE_ENV" ;;
                    PYTHONPATH) var_value="$PYTHONPATH" ;;
                    JAVA_HOME) var_value="$JAVA_HOME" ;;
                    MAVEN_HOME) var_value="$MAVEN_HOME" ;;
                esac
                value="${value//\$$var/$var_value}"
                found_var=true
            fi
        done
        
        if [[ "$found_var" == false ]]; then
            break
        fi
        ((depth++))
    done
    
    echo "$value"
}

# Function to load environment variables from a file
load_env_file() {
    local env_file="$1"
    local silent="${2:-false}"
    
    if [[ ! -f "$env_file" ]]; then
        return 0
    fi
    
    [[ "$silent" != "true" ]] && echo "Loading environment variables from: $env_file"
    
    # Read file line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Remove leading/trailing whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # Skip if line doesn't contain '='
        [[ "$line" != *"="* ]] && continue
        
        # Extract key and value - simple approach for compatibility
        local key="${line%%=*}"
        local value="${line#*=}"
        
        # Trim whitespace from key
        key="${key#"${key%%[![:space:]]*}"}"
        key="${key%"${key##*[![:space:]]}"}"
        
        # Trim whitespace from value
        value="${value#"${value%%[![:space:]]*}"}"
        value="${value%"${value##*[![:space:]]}"}"
        
        # Validate key name (must start with letter or underscore, contain only alphanumeric and underscore)
        case "$key" in
            [A-Za-z_]*) 
                if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
                    continue
                fi
                ;;
            *) continue ;;
        esac
        
        # Remove quotes if present (handle both single and double quotes)
        if [[ "$value" == \"*\" ]]; then
            value="${value#\"}"
            value="${value%\"}"
        elif [[ "$value" == \'*\' ]]; then
            value="${value#\'}"
            value="${value%\'}"
        fi
        
        # Handle platform-specific variables
        case "$key" in
            *_UNIX)
                # Only process on Unix-like systems
                local base_key="${key%_UNIX}"
                # Safely expand variables in value
                value=$(safe_expand_vars "$value")
                export "$base_key"="$value"
                [[ "$silent" != "true" ]] && echo "  Set $base_key=\"$value\" (from ${key})"
                ;;
            *_WIN)
                # Skip Windows-specific variables on Unix
                continue
                ;;
            *)
                # Regular variable - expand and export
                value=$(safe_expand_vars "$value")
                export "$key"="$value"
                [[ "$silent" != "true" ]] && echo "  Set $key=\"$value\""
                ;;
        esac
        
    done < "$env_file"
}

# Function to handle PATH additions
handle_path_additions() {
    local silent="${1:-false}"
    
    # Check for platform-specific PATH additions
    local path_var=""
    if [[ -n "$PATH_ADDITIONS_UNIX" ]]; then
        path_var="$PATH_ADDITIONS_UNIX"
    elif [[ -n "$PATH_ADDITIONS" ]]; then
        path_var="$PATH_ADDITIONS"
    fi
    
    if [[ -n "$path_var" ]]; then
        # Save and restore IFS to handle paths with spaces
        local OLD_IFS="$IFS"
        IFS=':'
        
        # Read into array, preserving spaces
        local paths=()
        while IFS= read -r -d ':' path_item; do
            [[ -n "$path_item" ]] && paths+=("$path_item")
        done <<< "$path_var:"
        
        # Restore IFS
        IFS="$OLD_IFS"
        
        # Process each path
        for path_item in "${paths[@]}"; do
            # Skip empty paths
            [[ -z "$path_item" ]] && continue
            
            # Expand variables in path
            local expanded_path=$(safe_expand_vars "$path_item")
            
            # Check if directory exists and not already in PATH
            if [[ -d "$expanded_path" ]]; then
                if [[ ":$PATH:" != *":$expanded_path:"* ]]; then
                    export PATH="$expanded_path:$PATH"
                    [[ "$silent" != "true" ]] && echo "  Added to PATH: \"$expanded_path\""
                fi
            else
                [[ "$silent" != "true" ]] && echo "  Warning: Path does not exist: \"$expanded_path\""
            fi
        done
    fi
}

# Function to detect shell type
detect_shell() {
    if [[ -n "$BASH_VERSION" ]]; then
        echo "bash"
    elif [[ -n "$ZSH_VERSION" ]]; then
        echo "zsh"
    else
        echo "unknown"
    fi
}

# Function to validate environment file syntax
validate_env_file() {
    local env_file="$1"
    local errors=0
    
    if [[ ! -f "$env_file" ]]; then
        echo "Error: File '$env_file' does not exist"
        return 1
    fi
    
    echo "Validating environment file: $env_file"
    
    local line_num=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))
        
        # Skip empty lines and comments
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Check for valid KEY=VALUE format
        if [[ "$line" != *"="* ]]; then
            echo "  Line $line_num: Invalid format (no '='): $line"
            ((errors++))
            continue
        fi
        
        # Extract key for validation
        local key="${line%%=*}"
        key="${key#"${key%%[![:space:]]*}"}"
        key="${key%"${key##*[![:space:]]}"}"
        
        # Validate key name
        case "$key" in
            [A-Za-z_]*) 
                if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
                    echo "  Line $line_num: Invalid variable name '$key'"
                    ((errors++))
                fi
                ;;
            *) 
                echo "  Line $line_num: Invalid variable name '$key'"
                ((errors++))
                ;;
        esac
        
    done < "$env_file"
    
    if [[ $errors -eq 0 ]]; then
        echo "  ✓ File is valid"
        return 0
    else
        echo "  ✗ Found $errors error(s)"
        return 1
    fi
}

# Main loading function
load_environments() {
    local silent="${1:-false}"
    local shell_type=$(detect_shell)
    
    [[ "$silent" != "true" ]] && echo "=== Loading Environment Variables (Shell: $shell_type) ==="
    
    # Set platform detection
    export IS_UNIX=true
    export IS_WINDOWS=false
    
    # Determine if we should deduplicate (avoid loading PWD/.env twice)
    local should_load_pwd=true
    if [[ "$PWD" == "$HOME" ]] || [[ "$PWD" == "$HOME/.cfgs" ]]; then
        should_load_pwd=false
    fi
    
    # Load in order: $HOME/.env -> $HOME/.cfgs/.env -> $PWD/.env
    local env_files=(
        "$HOME/.env"
        "$HOME/.cfgs/.env"
    )
    
    # Add PWD/.env only if it's different from the others
    if [[ "$should_load_pwd" == true ]]; then
        env_files+=("$PWD/.env")
    fi
    
    for env_file in "${env_files[@]}"; do
        load_env_file "$env_file" "$silent"
    done
    
    # Handle PATH additions after all files are loaded
    handle_path_additions "$silent"
    
    [[ "$silent" != "true" ]] && echo "=== Environment Variables Loaded ==="
}

# Make functions available when sourced
if [[ "$0" == "${BASH_SOURCE[0]}" ]] || [[ -z "$BASH_SOURCE" && "$0" == "$_" ]]; then
    # Script is being executed directly - show output
    load_environments false
else
    # Script is being sourced - load silently by default
    # Set LOAD_ENV_VERBOSE=true to show output when sourcing
    verbose="${LOAD_ENV_VERBOSE:-false}"
    if [[ "$verbose" == "true" ]]; then
        load_environments false
    else
        load_environments true
    fi
fi