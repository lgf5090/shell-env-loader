#!/usr/bin/env fish
# Fish Common Utilities Wrapper
# ==============================
# Fish-compatible wrapper for common utilities

# Platform detection (Fish version)
function detect_platform
    set -l uname_s (uname -s 2>/dev/null; or echo 'Unknown')
    switch $uname_s
        case 'Linux*'
            # Check for WSL
            if test -f /proc/version; and grep -qi microsoft /proc/version 2>/dev/null
                echo "WSL"
            else
                echo "LINUX"
            end
        case 'Darwin*'
            echo "MACOS"
        case 'CYGWIN*' 'MINGW*' 'MSYS*'
            echo "WIN"
        case '*'
            echo "UNIX"
    end
end

# Shell detection (Fish version)
function detect_shell
    echo "FISH"
end

# Get shell suffix (Fish version)
function get_shell_suffix
    echo "_FISH"
end

# Get platform suffixes (Fish version)
function get_platform_suffixes
    set -l platform (detect_platform)
    switch $platform
        case WSL
            echo "_WSL _LINUX _UNIX"
        case LINUX
            echo "_LINUX _UNIX"
        case MACOS
            echo "_MACOS _UNIX"
        case WIN
            echo "_WIN"
        case '*'
            echo "_UNIX"
    end
end

# Get file precedence (Fish version)
function get_file_precedence
    set -l file_path $argv[1]
    
    # Simple precedence based on file location
    if string match -q "*/.env" -- $file_path
        echo "100"  # Project level
    else if string match -q "*/.cfgs/.env*" -- $file_path
        echo "50"   # User level
    else if string match -q "$HOME/.env*" -- $file_path
        echo "25"   # Home level
    else
        echo "10"   # Default
    end
end

# Get relative path (Fish version)
function get_relative_path
    set -l file_path $argv[1]
    set -l current_dir (pwd)
    
    # Simple relative path calculation
    if string match -q "$current_dir/*" -- $file_path
        string replace "$current_dir/" "" -- $file_path
    else if string match -q "$HOME/*" -- $file_path
        string replace "$HOME/" "~/" -- $file_path
    else
        echo $file_path
    end
end

# Get environment file hierarchy (Fish version)
function get_env_file_hierarchy
    set -l files
    
    # Project level .env files
    if test -f ".env"
        set files $files ".env"
    end
    if test -f ".env.local"
        set files $files ".env.local"
    end
    
    # User level .env files
    if test -f "$HOME/.cfgs/.env"
        set files $files "$HOME/.cfgs/.env"
    end
    if test -f "$HOME/.cfgs/.env.local"
        set files $files "$HOME/.cfgs/.env.local"
    end
    
    # Home level .env files
    if test -f "$HOME/.env"
        set files $files "$HOME/.env"
    end
    
    # Output files (one per line)
    for file in $files
        echo $file
    end
end

# Ensure environment directories exist (Fish version)
function ensure_env_directories
    set -l dirs "$HOME/.cfgs" "$HOME/.local/share/env-loader"
    
    for dir in $dirs
        if not test -d "$dir"
            mkdir -p "$dir"
        end
    end
end

# Parse environment file (Fish version - call bash script)
function parse_env_file
    set -l file_path $argv[1]

    if not test -f "$file_path"
        return 1
    end

    # Get the script directory properly
    set -l script_dir (dirname (status --current-filename))

    # Use bash to parse the file since we have the bash parser
    bash -c "source '$script_dir/../../common/parser.sh'; parse_env_file '$file_path'"
end

# Extract base names (Fish version - call bash script)
function extract_base_names
    # Accept multiple arguments (parsed vars as separate arguments)
    # Get the script directory properly
    set -l script_dir (dirname (status --current-filename))

    # Use bash to extract base names, passing all arguments as separate lines
    printf '%s\n' $argv | bash -c "source '$script_dir/../../common/parser.sh'; extract_base_names \"\$(cat)\""
end

# Resolve variable precedence (Fish version - call bash script)
function resolve_variable_precedence
    set -l base_name $argv[1]
    set -l candidates $argv[2]

    # Get the script directory properly
    set -l script_dir (dirname (status --current-filename))

    # Use bash to resolve precedence
    printf '%s\n' $candidates | bash -c "source '$script_dir/../../common/parser.sh'; resolve_variable_precedence '$base_name' \"\$(cat)\""
end

# Get variable precedence (Fish version - call bash script)
function get_variable_precedence
    set -l var_name $argv[1]
    set -l shell_type $argv[2]
    set -l platform $argv[3]
    
    # Use bash to get precedence
    bash -c "source \"$(dirname (status --current-filename))/../../common/parser.sh\"; get_variable_precedence \"$var_name\" \"$shell_type\" \"$platform\""
end

# Validate variable name (Fish version)
function is_valid_variable_name
    set -l var_name $argv[1]
    
    # Check if variable name is valid (starts with letter or underscore, contains only alphanumeric and underscore)
    if string match -qr '^[a-zA-Z_][a-zA-Z0-9_]*$' -- $var_name
        return 0
    else
        return 1
    end
end
