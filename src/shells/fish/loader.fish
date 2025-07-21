#!/usr/bin/env fish
# Simple Fish Shell Environment Variable Loader
# ==============================================
# Simplified Fish implementation without bash dependencies

# Get the directory of this script
set SCRIPT_DIR (dirname (status --current-filename))

# Platform detection (Fish version)
function detect_platform
    set -l uname_s (uname -s 2>/dev/null; or echo 'Unknown')
    switch $uname_s
        case 'Linux*'
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

# Simple environment file parser (Fish native)
function parse_env_file_simple
    set -l file_path $argv[1]
    
    if not test -f "$file_path"
        return 1
    end
    
    # Read file line by line and extract valid variable assignments
    while read -l line
        # Skip empty lines and comments
        if test -z "$line"; or string match -qr '^\s*#' -- $line
            continue
        end
        
        # Extract variable assignments (KEY=VALUE format)
        if string match -qr '^[A-Za-z_][A-Za-z0-9_]*=' -- $line
            echo $line
        end
    end < "$file_path"
end

# Extract base names from parsed variables (Fish native)
function extract_base_names_simple
    set -l base_names
    
    for line in $argv
        # Extract the variable name (everything before the first =)
        set -l var_name (string split -m 1 '=' -- $line)[1]
        
        # Extract base name (remove suffixes)
        set -l base_name $var_name
        
        # Remove shell suffixes
        set base_name (string replace -r '_FISH$|_ZSH$|_BASH$' '' -- $base_name)
        
        # Remove platform suffixes
        set base_name (string replace -r '_WSL$|_LINUX$|_MACOS$|_WIN$|_UNIX$' '' -- $base_name)
        
        # Add to list if not already present
        if not contains $base_name $base_names
            set base_names $base_names $base_name
        end
    end
    
    # Output base names
    for name in $base_names
        echo $name
    end
end

# Get variable precedence score (Fish native)
function get_variable_precedence_simple
    set -l var_name $argv[1]
    set -l shell_type (detect_shell)
    set -l platform (detect_platform)
    
    set -l score 0
    
    # Shell-specific bonus
    if string match -q "*_$shell_type" -- $var_name
        set score (math $score + 1000)
    end
    
    # Platform-specific bonus
    switch $platform
        case WSL
            if string match -q "*_WSL" -- $var_name
                set score (math $score + 100)
            else if string match -q "*_LINUX" -- $var_name
                set score (math $score + 50)
            else if string match -q "*_UNIX" -- $var_name
                set score (math $score + 10)
            end
        case LINUX
            if string match -q "*_LINUX" -- $var_name
                set score (math $score + 100)
            else if string match -q "*_UNIX" -- $var_name
                set score (math $score + 10)
            end
        case MACOS
            if string match -q "*_MACOS" -- $var_name
                set score (math $score + 100)
            else if string match -q "*_UNIX" -- $var_name
                set score (math $score + 10)
            end
        case WIN
            if string match -q "*_WIN" -- $var_name
                set score (math $score + 100)
            end
    end
    
    echo $score
end

# Resolve variable precedence (Fish native)
function resolve_variable_precedence_simple
    set -l base_name $argv[1]
    set -l candidates $argv[2..-1]
    
    set -l best_var ""
    set -l best_value ""
    set -l best_score -1
    
    for candidate in $candidates
        # Extract variable name and value
        set -l parts (string split -m 1 '=' -- $candidate)
        set -l var_name $parts[1]
        set -l var_value $parts[2]
        
        # Get precedence score
        set -l score (get_variable_precedence_simple $var_name)
        
        if test $score -gt $best_score
            set best_var $var_name
            set best_value $var_value
            set best_score $score
        end
    end
    
    echo $best_value
end

# Set environment variable using fish built-ins
function set_environment_variable
    set -l key $argv[1]
    set -l value $argv[2]
    
    # Validate key
    if not string match -qr '^[A-Za-z_][A-Za-z0-9_]*$' -- $key
        echo "Warning: Invalid variable name: $key" >&2
        return 1
    end
    
    # Export the variable using fish syntax
    set -gx $key $value
    return 0
end

# Expand environment variables in a value (Fish native)
function expand_environment_variables
    set -l value $argv[1]
    
    # Simple variable expansion for common cases
    # Replace $HOME with actual home directory
    set value (string replace -a '$HOME' $HOME -- $value)
    set value (string replace -a '${HOME}' $HOME -- $value)
    
    # Replace $USER with actual username
    set value (string replace -a '$USER' $USER -- $value)
    set value (string replace -a '${USER}' $USER -- $value)
    
    # Replace tilde with home directory
    set value (string replace -a '~' $HOME -- $value)
    
    # Simple command substitution for $(date +%Y%m%d)
    if string match -q '*$(date +%Y%m%d)*' -- $value
        set -l date_str (date +%Y%m%d)
        set value (string replace -a '$(date +%Y%m%d)' $date_str -- $value)
    end
    
    echo $value
end

# Load environment variables from a single file (Fish native)
function load_env_file_simple
    set -l file_path $argv[1]
    
    if not test -f "$file_path"
        return 0  # Silently skip missing files
    end
    
    if test "$ENV_LOADER_DEBUG" = "true"
        echo "Loading environment variables from: $file_path" >&2
    end
    
    # Parse the file
    set -l parsed_vars (parse_env_file_simple "$file_path")
    if test (count $parsed_vars) -eq 0
        if test "$ENV_LOADER_DEBUG" = "true"
            echo "Warning: No variables found in $file_path" >&2
        end
        return 0
    end
    
    # Extract unique base names
    set -l base_names (extract_base_names_simple $parsed_vars)
    
    # Process each base name
    for base_name in $base_names
        if test -z "$base_name"
            continue
        end
        
        # Find all candidates for this base name
        set -l candidates
        for line in $parsed_vars
            set -l var_name (string split -m 1 '=' -- $line)[1]
            if test "$var_name" = "$base_name"; or string match -q "$base_name"_'*' -- $var_name
                set candidates $candidates $line
            end
        end
        
        # Resolve precedence and get the best value
        if test (count $candidates) -gt 0
            set -l best_value (resolve_variable_precedence_simple $base_name $candidates)
            
            if test -n "$best_value"
                # Expand environment variables if needed
                if string match -q '*$*' -- $best_value; or string match -q '*~*' -- $best_value
                    set best_value (expand_environment_variables "$best_value")
                end
                
                # Set the variable
                set_environment_variable "$base_name" "$best_value"
                
                # Debug output
                if test "$ENV_LOADER_DEBUG" = "true"
                    echo "  Set $base_name=$best_value" >&2
                end
            end
        end
    end
end

# Main load function
function load_env_file
    load_env_file_simple $argv
end

# Test function
function test_fish_loader
    echo "Testing Fish loader..." >&2
    set -gx ENV_LOADER_DEBUG true
    
    # Test basic loading
    set -e TEST_BASIC EDITOR
    load_env_file_simple .env.example
    
    echo "Results:" >&2
    echo "  EDITOR: [$EDITOR]" >&2
    echo "  TEST_BASIC: [$TEST_BASIC]" >&2
end
