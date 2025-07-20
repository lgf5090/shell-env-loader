#!/usr/bin/env fish
# Fish Shell Environment Variable Loader
# =======================================
# Fish-specific implementation of the cross-shell environment loader
# Uses fish built-in commands for optimal performance

# Get the directory of this script
set SCRIPT_DIR (dirname (status --current-filename))

# Source Fish-compatible common utilities
source "$SCRIPT_DIR/common_wrapper.fish"

# Set environment variable using fish built-ins
# Usage: set_environment_variable <key> <value>
function set_environment_variable
    set -l key $argv[1]
    set -l value $argv[2]
    
    # Validate key
    if not is_valid_variable_name "$key"
        echo "Warning: Invalid variable name: $key" >&2
        return 1
    end
    
    # Export the variable using fish syntax
    set -gx $key $value
    return 0
end

# Expand environment variables in a value (fish-specific)
# Usage: expand_environment_variables <value>
# Returns: Value with environment variables expanded
function expand_environment_variables
    set -l value $argv[1]
    
    # Fish handles variable expansion automatically in most contexts
    # For explicit expansion, we can use eval or string replace
    # This is safe because we're in a controlled environment
    echo $value | fish -c 'read -l input; echo $input'
end

# Load environment variables from a single file
# Usage: load_env_file <file_path>
function load_env_file
    set -l file_path $argv[1]
    
    if not test -f "$file_path"
        return 0  # Silently skip missing files
    end
    
    # Get current shell and platform
    set -l shell_type (detect_shell)
    set -l platform (detect_platform)
    
    echo "Loading environment variables from: "(get_relative_path "$file_path") >&2
    
    # Parse the file
    set -l parsed_vars (parse_env_file "$file_path")
    if test $status -ne 0
        echo "Warning: Failed to parse $file_path" >&2
        return 1
    end
    
    # Extract unique base names
    set -l base_names (extract_base_names $parsed_vars)
    
    # Process each base name
    for base_name in $base_names
        if test -z "$base_name"
            continue
        end
        
        # Find all candidates for this base name using fish string matching
        set -l candidates
        for line in $parsed_vars
            if string match -q "$base_name=*" -- $line; or string match -q "$base_name"_"*=*" -- $line
                set candidates $candidates $line
            end
        end
        
        # Resolve precedence and get the best value
        set -l best_value (resolve_variable_precedence "$base_name" (string join \n $candidates))
        
        if test -n "$best_value"
            # Expand environment variables if needed
            if string match -q '*$*' -- $best_value
                set best_value (expand_environment_variables "$best_value")
            end
            
            # Special handling for PATH variables
            switch $base_name
                case PATH_ADDITION
                    # Expand tilde and variables in PATH addition
                    if string match -q '*~*' -- $best_value
                        set best_value (string replace -a '~' $HOME -- $best_value)
                    end
                    if string match -q '*$*' -- $best_value
                        set best_value (expand_environment_variables "$best_value")
                    end
                    # Append to existing PATH (fish uses space-separated paths)
                    if test -n "$PATH"
                        set -gx PATH $PATH (string split ':' -- $best_value)
                    else
                        set -gx PATH (string split ':' -- $best_value)
                    end
                    
                case PATH_EXPORT
                    # Direct PATH replacement (already includes $PATH)
                    # Expand tilde and variables
                    if string match -q '*~*' -- $best_value
                        set best_value (string replace -a '~' $HOME -- $best_value)
                    end
                    if string match -q '*$*' -- $best_value
                        set best_value (expand_environment_variables "$best_value")
                    end
                    set -gx PATH (string split ':' -- $best_value)
                    
                case PATH
                    # Ensure all variables in PATH are expanded
                    if string match -q '*~*' -- $best_value
                        set best_value (string replace -a '~' $HOME -- $best_value)
                    end
                    if string match -q '*$*' -- $best_value
                        set best_value (expand_environment_variables "$best_value")
                    end
                    set_environment_variable "$base_name" "$best_value"
                    
                case '*'
                    # Regular variable
                    set_environment_variable "$base_name" "$best_value"
            end
            
            # Debug output
            if test "$ENV_LOADER_DEBUG" = "true"
                switch $base_name
                    case PATH_ADDITION
                        echo "  Appended to PATH: $best_value" >&2
                    case PATH_EXPORT
                        echo "  Set PATH: $best_value" >&2
                    case '*'
                        echo "  Set $base_name=$best_value" >&2
                end
            end
        end
    end
end

# Load environment variables from all files in hierarchy
# Usage: load_env_variables [file1] [file2] ...
# If no files specified, uses default hierarchy
function load_env_variables
    set -l files
    set -l loaded_count 0
    
    if test (count $argv) -gt 0
        # Use provided files
        set files $argv
    else
        # Use default hierarchy
        set files (get_env_file_hierarchy)
    end
    
    # Load each file
    for file in $files
        if test -n "$file" -a -f "$file"
            load_env_file "$file"
            set loaded_count (math $loaded_count + 1)
        end
    end
    
    if test "$ENV_LOADER_DEBUG" = "true"
        echo "Loaded environment variables from $loaded_count files" >&2
    end
    
    return 0
end

# Reload environment variables (useful for development)
# Usage: reload_env_variables
function reload_env_variables
    echo "Reloading environment variables..." >&2
    load_env_variables
end

# Show current environment variable status
# Usage: show_env_status
function show_env_status
    echo "Cross-Shell Environment Loader Status (Fish)"
    echo "============================================="
    echo "Platform: "(detect_platform)
    echo "Shell: "(detect_shell)
    echo "Shell suffix: "(get_shell_suffix)
    echo "Platform suffixes: "(get_platform_suffixes)
    echo
    
    echo "Environment files in hierarchy:"
    set -l files (get_env_file_hierarchy)
    if test -z "$files"
        echo "  No .env files found"
    else
        for file in $files
            if test -n "$file"
                set -l precedence (get_file_precedence "$file")
                set -l relative_path (get_relative_path "$file")
                echo "  $relative_path (precedence: $precedence)"
            end
        end
    end
    echo
    
    echo "Debug mode: "(test "$ENV_LOADER_DEBUG" = "true"; and echo "true"; or echo "false")
    echo "Current working directory: $PWD"
    echo "Home directory: "(test -n "$HOME"; and echo "$HOME"; or echo "N/A")
end

# Enable debug mode
# Usage: env_loader_debug_on
function env_loader_debug_on
    set -gx ENV_LOADER_DEBUG true
    echo "Environment loader debug mode enabled" >&2
end

# Disable debug mode
# Usage: env_loader_debug_off
function env_loader_debug_off
    set -gx ENV_LOADER_DEBUG false
    echo "Environment loader debug mode disabled" >&2
end

# Test the loader with example files
# Usage: test_env_loader
function test_env_loader
    echo "Testing environment loader..." >&2
    
    # Enable debug mode for testing
    env_loader_debug_on
    
    # Test with example files if they exist
    for test_file in examples/test-scenarios/.env.basic examples/test-scenarios/.env.quotes .env.example
        if test -f "$test_file"
            echo "Testing with $test_file:" >&2
            load_env_file "$test_file"
            echo >&2
        end
    end
    
    # Show some test variables
    echo "Test variables:" >&2
    echo "  BASIC_VAR="(test -n "$BASIC_VAR"; and echo "$BASIC_VAR"; or echo "not set") >&2
    echo "  QUOTED_VAR="(test -n "$QUOTED_VAR"; and echo "$QUOTED_VAR"; or echo "not set") >&2
    echo "  TEST_BASIC="(test -n "$TEST_BASIC"; and echo "$TEST_BASIC"; or echo "not set") >&2
    
    env_loader_debug_off
end

# Initialize the environment loader
# Usage: init_env_loader
function init_env_loader
    # Ensure required directories exist
    ensure_env_directories
    
    # Load environment variables
    load_env_variables
end

# Auto-initialize if this script is sourced (not executed)
# Use a flag to prevent multiple initializations
if status --is-interactive; and not set -q ENV_LOADER_INITIALIZED
    # Script is being sourced in interactive mode, auto-initialize
    set -gx ENV_LOADER_INITIALIZED true
    init_env_loader
end
