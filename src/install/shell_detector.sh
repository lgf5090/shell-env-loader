#!/bin/bash
# Shell Detection and Discovery System
# ====================================
# Comprehensive shell detection, version checking, and configuration path discovery
# Used by the unified installation system

# Source platform detection utilities
DETECTOR_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Only source platform.sh if not already sourced
if ! command -v detect_platform >/dev/null 2>&1; then
    source "$DETECTOR_SCRIPT_DIR/../common/platform.sh"
fi

# Supported shells configuration
declare -A SUPPORTED_SHELLS=(
    ["bash"]="bash"
    ["zsh"]="zsh" 
    ["fish"]="fish"
    ["nu"]="nu"
    ["pwsh"]="pwsh"
    ["powershell"]="powershell"
)

# Shell executable patterns for detection
declare -A SHELL_PATTERNS=(
    ["bash"]="bash"
    ["zsh"]="zsh"
    ["fish"]="fish"
    ["nu"]="nu"
    ["pwsh"]="pwsh powershell"
)

# Configuration file patterns for each shell
declare -A CONFIG_PATTERNS=(
    ["bash"]=".bashrc .bash_profile .profile"
    ["zsh"]=".zshrc .zsh_profile .profile"
    ["fish"]=".config/fish/config.fish"
    ["nu"]=".config/nushell/config.nu .config/nushell/env.nu"
    ["pwsh"]=".config/powershell/profile.ps1 Documents/PowerShell/profile.ps1"
)

# Check if a command exists
# Usage: command_exists <command>
# Returns: 0 if exists, 1 if not
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if a shell executable exists and is functional
# Usage: is_shell_available <shell_name>
# Returns: 0 if available, 1 if not
is_shell_available() {
    local shell_name="$1"
    local patterns="${SHELL_PATTERNS[$shell_name]}"
    
    [ -z "$patterns" ] && return 1
    
    for pattern in $patterns; do
        if command_exists "$pattern"; then
            # Test if the shell can execute basic commands
            case "$shell_name" in
                bash|zsh)
                    "$pattern" -c 'echo test' >/dev/null 2>&1 && return 0
                    ;;
                fish)
                    "$pattern" -c 'echo test' >/dev/null 2>&1 && return 0
                    ;;
                nu)
                    "$pattern" -c 'echo test' >/dev/null 2>&1 && return 0
                    ;;
                pwsh)
                    "$pattern" -c 'Write-Output test' >/dev/null 2>&1 && return 0
                    ;;
            esac
        fi
    done
    
    return 1
}

# Get shell version information
# Usage: get_shell_version <shell_name>
# Returns: Version string or "unknown"
get_shell_version() {
    local shell_name="$1"
    local patterns="${SHELL_PATTERNS[$shell_name]}"
    local version="unknown"
    
    [ -z "$patterns" ] && echo "$version" && return 1
    
    for pattern in $patterns; do
        if command_exists "$pattern"; then
            case "$shell_name" in
                bash)
                    version=$("$pattern" --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
                    ;;
                zsh)
                    version=$("$pattern" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)
                    ;;
                fish)
                    version=$("$pattern" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
                    ;;
                nu)
                    version=$("$pattern" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
                    ;;
                pwsh)
                    version=$("$pattern" -c '$PSVersionTable.PSVersion.ToString()' 2>/dev/null | head -n1)
                    ;;
            esac
            
            [ -n "$version" ] && [ "$version" != "unknown" ] && break
        fi
    done
    
    echo "${version:-unknown}"
}

# Get shell executable path
# Usage: get_shell_executable <shell_name>
# Returns: Full path to shell executable or empty string
get_shell_executable() {
    local shell_name="$1"
    local patterns="${SHELL_PATTERNS[$shell_name]}"
    
    [ -z "$patterns" ] && return 1
    
    for pattern in $patterns; do
        if command_exists "$pattern"; then
            command -v "$pattern" 2>/dev/null && return 0
        fi
    done
    
    return 1
}

# Find existing configuration files for a shell
# Usage: find_shell_config_files <shell_name>
# Returns: Space-separated list of existing config files
find_shell_config_files() {
    local shell_name="$1"
    local patterns="${CONFIG_PATTERNS[$shell_name]}"
    local config_files=""
    
    [ -z "$patterns" ] && return 1
    
    for pattern in $patterns; do
        local full_path="$HOME/$pattern"
        if [ -f "$full_path" ]; then
            config_files="$config_files $full_path"
        fi
    done
    
    echo "$config_files" | sed 's/^ *//'
}

# Get default configuration file path for a shell
# Usage: get_default_config_file <shell_name>
# Returns: Default config file path (may not exist yet)
get_default_config_file() {
    local shell_name="$1"
    local patterns="${CONFIG_PATTERNS[$shell_name]}"
    
    [ -z "$patterns" ] && return 1
    
    # Return the first (most preferred) pattern
    local first_pattern=$(echo "$patterns" | cut -d' ' -f1)
    echo "$HOME/$first_pattern"
}

# Get comprehensive shell information
# Usage: get_shell_info <shell_name>
# Returns: JSON-like formatted shell information
get_shell_info() {
    local shell_name="$1"
    local available executable version config_files default_config
    
    if is_shell_available "$shell_name"; then
        available="true"
        executable=$(get_shell_executable "$shell_name")
        version=$(get_shell_version "$shell_name")
        config_files=$(find_shell_config_files "$shell_name")
        default_config=$(get_default_config_file "$shell_name")
    else
        available="false"
        executable=""
        version="unknown"
        config_files=""
        default_config=$(get_default_config_file "$shell_name")
    fi
    
    cat << EOF
{
  "name": "$shell_name",
  "available": $available,
  "executable": "$executable",
  "version": "$version",
  "config_files": "$config_files",
  "default_config": "$default_config"
}
EOF
}

# Discover all available shells on the system
# Usage: discover_available_shells
# Returns: Space-separated list of available shell names
discover_available_shells() {
    local available_shells=""
    
    for shell_name in "${!SUPPORTED_SHELLS[@]}"; do
        if is_shell_available "$shell_name"; then
            available_shells="$available_shells $shell_name"
        fi
    done
    
    echo "$available_shells" | sed 's/^ *//'
}

# Generate comprehensive system shell report
# Usage: generate_shell_report
# Returns: Detailed report of all shells
generate_shell_report() {
    local platform shell current_shell available_shells
    
    platform=$(detect_platform)
    current_shell=$(detect_shell | tr '[:upper:]' '[:lower:]')
    available_shells=$(discover_available_shells)
    
    echo "Shell Detection Report"
    echo "====================="
    echo "Platform: $platform"
    echo "Current Shell: $current_shell"
    echo "Available Shells: $available_shells"
    echo ""
    
    for shell_name in "${!SUPPORTED_SHELLS[@]}"; do
        echo "--- $shell_name ---"
        if is_shell_available "$shell_name"; then
            echo "Status: Available ✅"
            echo "Executable: $(get_shell_executable "$shell_name")"
            echo "Version: $(get_shell_version "$shell_name")"
            
            local config_files=$(find_shell_config_files "$shell_name")
            if [ -n "$config_files" ]; then
                echo "Existing configs: $config_files"
            else
                echo "Existing configs: None"
            fi
            echo "Default config: $(get_default_config_file "$shell_name")"
        else
            echo "Status: Not Available ❌"
        fi
        echo ""
    done
}

# Check shell compatibility with env-loader
# Usage: check_shell_compatibility <shell_name>
# Returns: 0 if compatible, 1 if not
check_shell_compatibility() {
    local shell_name="$1"
    local min_versions
    
    # Define minimum required versions
    case "$shell_name" in
        bash)
            min_versions="4.0"
            ;;
        zsh)
            min_versions="5.0"
            ;;
        fish)
            min_versions="3.0"
            ;;
        nu)
            min_versions="0.60"
            ;;
        pwsh)
            min_versions="7.0"
            ;;
        *)
            return 1
            ;;
    esac
    
    if ! is_shell_available "$shell_name"; then
        return 1
    fi
    
    local current_version=$(get_shell_version "$shell_name")
    if [ "$current_version" = "unknown" ]; then
        # If we can't determine version, assume it's compatible
        return 0
    fi
    
    # Simple version comparison (works for most cases)
    # This is a basic implementation - could be enhanced for more complex version schemes
    if [ "$(printf '%s\n' "$min_versions" "$current_version" | sort -V | head -n1)" = "$min_versions" ]; then
        return 0
    else
        return 1
    fi
}

# Main function for command-line usage
main() {
    case "${1:-help}" in
        discover)
            discover_available_shells
            ;;
        report)
            generate_shell_report
            ;;
        info)
            if [ -n "$2" ]; then
                get_shell_info "$2"
            else
                echo "Usage: $0 info <shell_name>"
                exit 1
            fi
            ;;
        check)
            if [ -n "$2" ]; then
                if is_shell_available "$2"; then
                    echo "$2 is available"
                    exit 0
                else
                    echo "$2 is not available"
                    exit 1
                fi
            else
                echo "Usage: $0 check <shell_name>"
                exit 1
            fi
            ;;
        compatible)
            if [ -n "$2" ]; then
                if check_shell_compatibility "$2"; then
                    echo "$2 is compatible"
                    exit 0
                else
                    echo "$2 is not compatible"
                    exit 1
                fi
            else
                echo "Usage: $0 compatible <shell_name>"
                exit 1
            fi
            ;;
        help|*)
            echo "Shell Detector - Comprehensive shell detection and discovery"
            echo ""
            echo "Usage: $0 <command> [arguments]"
            echo ""
            echo "Commands:"
            echo "  discover     - List all available shells"
            echo "  report       - Generate comprehensive shell report"
            echo "  info <shell> - Get detailed information about a specific shell"
            echo "  check <shell>- Check if a shell is available"
            echo "  compatible <shell> - Check if a shell is compatible with env-loader"
            echo "  help         - Show this help message"
            echo ""
            echo "Supported shells: ${!SUPPORTED_SHELLS[*]}"
            ;;
    esac
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
