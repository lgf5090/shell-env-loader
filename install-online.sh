#!/bin/bash
# Cross-Shell Environment Loader - Online Installation Script
# ===========================================================
# Simplified installation script optimized for online installation
# Downloads all necessary files and performs installation

set -e  # Exit on any error

# GitHub repository configuration
GITHUB_REPO="https://github.com/lgf5090/shell-env-loader"
GITHUB_RAW="https://raw.githubusercontent.com/lgf5090/shell-env-loader/main"
INSTALL_DIR="$HOME/.local/share/env-loader"
LOG_FILE="/tmp/env-loader-install.log"
TEMP_DIR="/tmp/env-loader-install-$$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$LOG_FILE"
}

info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
    log "INFO: $*"
}

success() {
    echo -e "${GREEN}✅ $*${NC}"
    log "SUCCESS: $*"
}

warning() {
    echo -e "${YELLOW}⚠️  $*${NC}"
    log "WARNING: $*"
}

error() {
    echo -e "${RED}❌ $*${NC}"
    log "ERROR: $*"
}

# Clean up temporary files
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Show usage information
show_usage() {
    cat << 'EOF'
Cross-Shell Environment Loader - Online Installation
===================================================

Usage: curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install-online.sh | bash [OPTIONS] [SHELLS...]

OPTIONS:
    --all               Install for all available shells (recommended)
    --help              Show this help message
    --check             Check system compatibility
    --list              List available shells on this system
    --dry-run           Show what would be installed without actually installing

SHELLS:
    bash                Install for Bash shell
    zsh                 Install for Zsh shell  
    fish                Install for Fish shell
    nu                  Install for Nushell
    pwsh                Install for PowerShell

EXAMPLES:
    # Install for all available shells (recommended)
    curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install-online.sh | bash

    # Install for specific shells
    curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install-online.sh | bash -s -- bash zsh

    # Install for all shells non-interactively
    curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install-online.sh | bash -s -- --all

    # Check system compatibility
    curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install-online.sh | bash -s -- --check

NOTES:
    - Installation requires write access to ~/.local/share/ and shell config files
    - Backup files are created automatically before modification
    - All necessary files are downloaded automatically from GitHub
    - Logs are written to: /tmp/env-loader-install.log

EOF
}

# Check prerequisites
check_prerequisites() {
    info "Checking system prerequisites..."
    
    # Check for download tools
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        error "Neither curl nor wget found. Please install one of them."
        return 1
    fi
    
    # Check if we can write to install directory
    if ! mkdir -p "$INSTALL_DIR" 2>/dev/null; then
        error "Cannot create install directory: $INSTALL_DIR"
        return 1
    fi
    
    # Check for required commands
    local required_commands="cp mkdir chmod"
    for cmd in $required_commands; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            error "Required command not found: $cmd"
            return 1
        fi
    done
    
    success "System prerequisites check passed"
    return 0
}

# Download and run the full installation script
download_and_install() {
    local args="$*"
    
    info "Downloading full installation script from GitHub..."
    
    # Determine download command
    local download_cmd=""
    if command -v curl >/dev/null 2>&1; then
        download_cmd="curl -fsSL"
    else
        download_cmd="wget -qO-"
    fi
    
    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    
    # Download the main installation script
    if ! $download_cmd "$GITHUB_RAW/install.sh" > "$TEMP_DIR/install.sh"; then
        error "Failed to download main installation script"
        return 1
    fi
    chmod +x "$TEMP_DIR/install.sh"
    
    success "Downloaded installation script successfully"
    
    # Run the installation script
    info "Running installation with arguments: $args"
    cd "$TEMP_DIR"
    ./install.sh $args
}

# Simple shell detection for basic functionality
detect_available_shells() {
    local shells=""
    for shell in bash zsh fish nu pwsh; do
        if command -v "$shell" >/dev/null 2>&1; then
            shells="$shells $shell"
        fi
    done
    echo "$shells" | sed 's/^ *//'
}

# Simple system check
simple_system_check() {
    echo "Cross-Shell Environment Loader - Online Installation"
    echo "==================================================="
    echo ""
    echo "System Information:"
    echo "  Platform: $(uname -s)"
    echo "  Architecture: $(uname -m)"
    echo "  Current Shell: $(basename "$SHELL")"
    echo ""
    echo "Available Shells:"
    local available_shells=$(detect_available_shells)
    if [ -n "$available_shells" ]; then
        for shell in $available_shells; do
            local version=""
            case "$shell" in
                bash) version=$($shell --version 2>/dev/null | head -1 | cut -d' ' -f4 | cut -d'(' -f1) ;;
                zsh) version=$($shell --version 2>/dev/null | cut -d' ' -f2) ;;
                fish) version=$($shell --version 2>/dev/null | cut -d' ' -f3) ;;
                nu) version=$($shell --version 2>/dev/null | head -1 | cut -d' ' -f2) ;;
                pwsh) version=$($shell --version 2>/dev/null | head -1 | cut -d' ' -f2) ;;
            esac
            echo "  ✅ $shell${version:+ ($version)}"
        done
    else
        echo "  ❌ No supported shells found"
    fi
    echo ""
}

# Parse command line arguments
parse_arguments() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-h)
                show_usage
                exit 0
                ;;
            --check)
                simple_system_check
                exit 0
                ;;
            --list)
                echo "Available shells on this system:"
                detect_available_shells | tr ' ' '\n' | sed 's/^/  /'
                exit 0
                ;;
            --all|--dry-run|bash|zsh|fish|nu|pwsh)
                # Pass through to main installer
                download_and_install "$@"
                exit $?
                ;;
            *)
                error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # No arguments - default to interactive installation
    download_and_install --all
}

# Main function
main() {
    echo "🚀 Cross-Shell Environment Loader - Online Installation"
    echo "======================================================="
    echo ""
    
    # Initialize log
    log "Online installation started"
    
    # Check prerequisites
    check_prerequisites || exit 1
    
    # Parse arguments and run installation
    parse_arguments "$@"
}

# Run main function
main "$@"
