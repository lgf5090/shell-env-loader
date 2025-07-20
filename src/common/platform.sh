#!/bin/bash
# Platform Detection Utilities
# ============================
# POSIX-compatible platform and shell detection functions
# Used by all shell implementations for consistent platform detection

# Detect the current platform
# Returns: LINUX, MACOS, WIN, or UNIX (fallback)
detect_platform() {
    case "$(uname -s 2>/dev/null || echo 'Unknown')" in
        Linux*)
            # Check for WSL
            if [ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null; then
                echo "WSL"
            else
                echo "LINUX"
            fi
            ;;
        Darwin*)
            echo "MACOS"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "WIN"
            ;;
        *)
            echo "UNIX"
            ;;
    esac
}

# Detect the current shell
# Returns: BASH, ZSH, FISH, NU, PS, or UNKNOWN
detect_shell() {
    # First try to detect from $0 (current shell)
    case "${0##*/}" in
        bash|*bash*)
            echo "BASH"
            return 0
            ;;
        zsh|*zsh*)
            echo "ZSH"
            return 0
            ;;
        fish|*fish*)
            echo "FISH"
            return 0
            ;;
        nu|*nu*)
            echo "NU"
            return 0
            ;;
        pwsh|powershell|*powershell*)
            echo "PS"
            return 0
            ;;
    esac
    
    # Try to detect from SHELL environment variable
    case "${SHELL##*/}" in
        bash)
            echo "BASH"
            return 0
            ;;
        zsh)
            echo "ZSH"
            return 0
            ;;
        fish)
            echo "FISH"
            return 0
            ;;
        nu)
            echo "NU"
            return 0
            ;;
        pwsh|powershell)
            echo "PS"
            return 0
            ;;
    esac
    
    # Try to detect from shell-specific variables
    if [ -n "$BASH_VERSION" ]; then
        echo "BASH"
    elif [ -n "$ZSH_VERSION" ]; then
        echo "ZSH"
    elif [ -n "$FISH_VERSION" ]; then
        echo "FISH"
    elif [ -n "$NU_VERSION" ]; then
        echo "NU"
    elif [ -n "$PSVersionTable" ]; then
        echo "PS"
    else
        echo "UNKNOWN"
    fi
}

# Get platform-specific suffixes in priority order
# Usage: get_platform_suffixes
# Returns: Space-separated list of suffixes (most specific first)
get_platform_suffixes() {
    local platform
    platform=$(detect_platform)
    
    case "$platform" in
        WSL)
            echo "_WSL _LINUX _UNIX"
            ;;
        LINUX)
            echo "_LINUX _UNIX"
            ;;
        MACOS)
            echo "_MACOS _UNIX"
            ;;
        WIN)
            echo "_WIN"
            ;;
        UNIX)
            echo "_UNIX"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Get shell-specific suffix
# Usage: get_shell_suffix
# Returns: Shell suffix (e.g., "_BASH", "_ZSH")
get_shell_suffix() {
    local shell
    shell=$(detect_shell)
    
    case "$shell" in
        BASH)
            echo "_BASH"
            ;;
        ZSH)
            echo "_ZSH"
            ;;
        FISH)
            echo "_FISH"
            ;;
        NU)
            echo "_NU"
            ;;
        PS)
            echo "_PS"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Check if a command exists
# Usage: command_exists <command>
# Returns: 0 if command exists, 1 otherwise
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get the number of CPU cores (for parallel processing)
# Usage: get_cpu_count
# Returns: Number of CPU cores
get_cpu_count() {
    if command_exists nproc; then
        nproc
    elif [ -f /proc/cpuinfo ]; then
        grep -c ^processor /proc/cpuinfo
    elif command_exists sysctl; then
        sysctl -n hw.ncpu 2>/dev/null || echo "1"
    else
        echo "1"
    fi
}

# Normalize path separators for the current platform
# Usage: normalize_path <path>
# Returns: Path with appropriate separators
normalize_path() {
    local path="$1"
    local platform
    platform=$(detect_platform)
    
    case "$platform" in
        WIN)
            # Convert forward slashes to backslashes for Windows
            echo "$path" | sed 's|/|\\|g'
            ;;
        *)
            # Convert backslashes to forward slashes for Unix-like systems
            echo "$path" | sed 's|\\|/|g'
            ;;
    esac
}

# Expand tilde (~) in paths
# Usage: expand_tilde <path>
# Returns: Path with tilde expanded
expand_tilde() {
    local path="$1"

    case "$path" in
        "~")
            echo "$HOME"
            ;;
        "~/"*)
            # Use sed to replace ~/ with $HOME/
            echo "$path" | sed "s|^~/|$HOME/|"
            ;;
        *)
            echo "$path"
            ;;
    esac
}

# Debug function to print platform information
# Usage: debug_platform_info
debug_platform_info() {
    echo "Platform Detection Debug Information:"
    echo "  Platform: $(detect_platform)"
    echo "  Shell: $(detect_shell)"
    echo "  Platform suffixes: $(get_platform_suffixes)"
    echo "  Shell suffix: $(get_shell_suffix)"
    echo "  CPU count: $(get_cpu_count)"
    echo "  uname -s: $(uname -s 2>/dev/null || echo 'N/A')"
    echo "  \$0: $0"
    echo "  \$SHELL: ${SHELL:-N/A}"
    echo "  \$BASH_VERSION: ${BASH_VERSION:-N/A}"
    echo "  \$ZSH_VERSION: ${ZSH_VERSION:-N/A}"
    echo "  \$FISH_VERSION: ${FISH_VERSION:-N/A}"
    echo "  \$HOME: ${HOME:-N/A}"
    echo "  \$PWD: ${PWD:-N/A}"
}
