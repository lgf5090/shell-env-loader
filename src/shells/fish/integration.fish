#!/usr/bin/env fish
# Fish Shell Integration Script
# =============================
# Integration code for adding the environment loader to fish configuration

# Get the directory of this script
set SCRIPT_DIR (dirname (status --current-filename))

# Integration code template for config.fish
set FISH_INTEGRATION_CODE '
# Cross-Shell Environment Loader (Fish)
# ======================================
# Automatically load environment variables from .env files
# Generated by shell-env-loader installation

if test -f "$HOME/.local/share/env-loader/fish/loader.fish"
    # Source the loader
    source "$HOME/.local/share/env-loader/fish/loader.fish"
    
    # Optional: Enable debug mode by uncommenting the next line
    # set -gx ENV_LOADER_DEBUG true
end
'

# Function to get fish configuration file path
function get_fish_config_file
    # Fish configuration directory
    set -l fish_config_dir
    
    if test -n "$XDG_CONFIG_HOME"
        set fish_config_dir "$XDG_CONFIG_HOME/fish"
    else
        set fish_config_dir "$HOME/.config/fish"
    end
    
    # Check if config.fish exists
    if test -f "$fish_config_dir/config.fish"
        echo "$fish_config_dir/config.fish"
        return 0
    end
    
    # Default to config.fish (will be created)
    echo "$fish_config_dir/config.fish"
end

# Function to check if integration is already installed
function is_integration_installed
    set -l config_file $argv[1]
    
    if test -f "$config_file"
        grep -q "Cross-Shell Environment Loader (Fish)" "$config_file"
    else
        return 1
    end
end

# Function to install fish integration
function install_fish_integration
    set -l config_file (get_fish_config_file)
    set -l config_dir (dirname "$config_file")
    
    echo "Installing Fish integration..."
    echo "Configuration file: $config_file"
    
    # Check if already installed
    if is_integration_installed "$config_file"
        echo "Integration already installed in $config_file"
        return 0
    end
    
    # Create config directory if it doesn't exist
    if not test -d "$config_dir"
        mkdir -p "$config_dir"
        echo "Created config directory: $config_dir"
    end
    
    # Create backup if file exists
    if test -f "$config_file"
        set -l backup_file "$config_file.env-loader-backup."(date +%Y%m%d_%H%M%S)
        cp "$config_file" "$backup_file"
        echo "Created backup: $backup_file"
    end
    
    # Add integration code
    echo $FISH_INTEGRATION_CODE >> "$config_file"
    
    echo "✅ Fish integration installed successfully"
    echo "   Configuration file: $config_file"
    echo "   To activate: source $config_file"
    echo "   Or start a new fish session"
    
    return 0
end

# Function to uninstall fish integration
function uninstall_fish_integration
    set -l config_file (get_fish_config_file)
    
    echo "Uninstalling Fish integration..."
    
    if not is_integration_installed "$config_file"
        echo "Integration not found in $config_file"
        return 1
    end
    
    # Create temporary file without integration code
    set -l temp_file (mktemp)
    
    # Remove integration block using awk
    awk '
        /^# Cross-Shell Environment Loader \(Fish\)/ { skip = 1 }
        /^end$/ && skip { skip = 0; next }
        !skip { print }
    ' "$config_file" > "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$config_file"
    
    echo "✅ Fish integration uninstalled successfully"
    return 0
end

# Function to verify fish integration
function verify_fish_integration
    set -l config_file (get_fish_config_file)
    set -l loader_path "$HOME/.local/share/env-loader/fish/loader.fish"
    
    echo "Verifying Fish integration..."
    echo "Configuration file: $config_file"
    echo "Loader script: $loader_path"
    
    # Check if integration is installed
    if not is_integration_installed "$config_file"
        echo "❌ Integration not found in configuration file"
        return 1
    end
    
    # Check if loader script exists
    if not test -f "$loader_path"
        echo "❌ Loader script not found: $loader_path"
        return 1
    end
    
    # Test loading the script
    if fish -c "source '$loader_path'; echo 'Loader script loaded successfully'" >/dev/null 2>&1
        echo "✅ Loader script loads without errors"
    else
        echo "❌ Loader script has errors"
        return 1
    end
    
    echo "✅ Fish integration verification passed"
    return 0
end

# Function to show integration status
function show_integration_status
    set -l config_file (get_fish_config_file)
    set -l loader_path "$HOME/.local/share/env-loader/fish/loader.fish"
    
    echo "Fish Integration Status"
    echo "======================="
    echo "Configuration file: $config_file"
    echo "Configuration file exists: "(test -f "$config_file"; and echo "yes"; or echo "no")
    echo "Integration installed: "(is_integration_installed "$config_file"; and echo "yes"; or echo "no")
    echo "Loader script: $loader_path"
    echo "Loader script exists: "(test -f "$loader_path"; and echo "yes"; or echo "no")
    
    if test -f "$config_file"
        echo "Configuration file size: "(wc -c < "$config_file")" bytes"
    end
    
    if test -f "$loader_path"
        echo "Loader script size: "(wc -c < "$loader_path")" bytes"
    end
end

# Function to test integration in a new fish session
function test_integration
    set -l config_file (get_fish_config_file)
    
    echo "Testing Fish integration in new session..."
    
    # Test in a new fish session
    fish -c "
        source '$config_file'
        if functions -q show_env_status
            echo '✅ Integration test passed - functions are available'
            show_env_status
        else
            echo '❌ Integration test failed - functions not available'
            exit 1
        end
    "
end

# Main function for command-line usage
function main
    switch $argv[1]
        case install
            install_fish_integration
        case uninstall
            uninstall_fish_integration
        case verify
            verify_fish_integration
        case status
            show_integration_status
        case test
            test_integration
        case '*'
            echo "Usage: "(status --current-filename)" {install|uninstall|verify|status|test}"
            echo
            echo "Commands:"
            echo "  install   - Install Fish integration"
            echo "  uninstall - Remove Fish integration"
            echo "  verify    - Verify integration is working"
            echo "  status    - Show integration status"
            echo "  test      - Test integration in new session"
            return 1
    end
end

# Run main function if script is executed directly
if status --is-interactive
    main $argv
end
