#!/bin/bash
# Cross-Shell Environment Loader - GitHub Installation Script
# ===========================================================
# One-command installation from GitHub for all supported shells
# Usage: curl -fsSL https://raw.githubusercontent.com/your-username/shell-env-loader/main/install-github.sh | bash

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

# Download files from GitHub
download_files() {
    info "Downloading shell-env-loader from GitHub..."
    
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
    info "Downloading main installation script..."
    if ! $download_cmd "$GITHUB_RAW/install.sh" > "$TEMP_DIR/install.sh"; then
        error "Failed to download main installation script"
        return 1
    fi
    chmod +x "$TEMP_DIR/install.sh"
    
    # Download required files
    local files=(
        "src/common/platform.sh"
        "src/common/hierarchy.sh" 
        "src/common/parser.sh"
        "src/shells/bash/loader.sh"
        "src/shells/bash/integration.sh"
        "src/shells/zsh/loader.zsh"
        "src/shells/zsh/integration.zsh"
        "src/shells/fish/loader.fish"
        "src/shells/nu/loader.nu"
        "src/shells/pwsh/loader.ps1"
        "src/shells/bzsh/loader.sh"
        "src/shells/bzsh/integration.sh"
        "src/install/shell_detector.sh"
    )
    
    for file in "${files[@]}"; do
        local url="$GITHUB_RAW/$file"
        local local_path="$TEMP_DIR/$file"
        local dir=$(dirname "$local_path")
        
        mkdir -p "$dir"
        
        info "Downloading $file..."
        if ! $download_cmd "$url" > "$local_path"; then
            error "Failed to download $file"
            return 1
        fi
    done
    
    success "Successfully downloaded all files from GitHub"
    return 0
}

# Detect available shells
detect_shells() {
    local available_shells=""
    
    # Check for common shells
    for shell in bash zsh fish nu pwsh; do
        if command -v "$shell" >/dev/null 2>&1; then
            available_shells="$available_shells $shell"
        fi
    done
    
    echo "$available_shells" | sed 's/^ *//'
}

# Show installation options
show_options() {
    local available_shells=$(detect_shells)
    
    echo ""
    echo "🐚 Shell-Env-Loader GitHub Installation"
    echo "======================================"
    echo ""
    echo "Available shells on your system: $available_shells"
    echo ""
    echo "Installation options:"
    echo "  1) Install for all available shells (recommended)"
    echo "  2) Install for specific shells"
    echo "  3) Just download and exit"
    echo ""
    
    while true; do
        read -p "Choose an option (1-3): " choice
        case $choice in
            1)
                return 1  # Install all
                ;;
            2)
                return 2  # Install specific
                ;;
            3)
                return 3  # Download only
                ;;
            *)
                echo "Please enter 1, 2, or 3"
                ;;
        esac
    done
}

# Main installation function
main() {
    echo "🚀 Cross-Shell Environment Loader - GitHub Installation"
    echo "======================================================="
    echo ""
    
    # Initialize log
    log "GitHub installation started"
    
    # Check prerequisites
    check_prerequisites || exit 1
    
    # Download files
    download_files || exit 1
    
    # Show options if running interactively
    if [ -t 0 ]; then
        show_options
        local choice=$?
        
        case $choice in
            1)
                # Install for all shells
                info "Installing for all available shells..."
                cd "$TEMP_DIR"
                ./install.sh --all
                ;;
            2)
                # Install for specific shells
                local available_shells=$(detect_shells)
                echo "Available shells: $available_shells"
                read -p "Enter shells to install (space-separated): " selected_shells
                cd "$TEMP_DIR"
                ./install.sh $selected_shells
                ;;
            3)
                # Download only
                info "Files downloaded to: $TEMP_DIR"
                info "To install manually, run: cd $TEMP_DIR && ./install.sh --all"
                # Don't cleanup in this case
                trap - EXIT
                ;;
        esac
    else
        # Non-interactive mode - install for all shells
        info "Non-interactive mode: Installing for all available shells..."
        cd "$TEMP_DIR"
        ./install.sh --all
    fi
    
    if [ $? -eq 0 ]; then
        echo ""
        success "🎉 Installation completed successfully!"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Restart your shell or run 'source ~/.bashrc' (or equivalent)"
        echo "   2. Create a .env file in your project directory"
        echo "   3. Add environment variables like: API_KEY=your_key_here"
        echo "   4. Your shell will automatically load these variables!"
        echo ""
        echo "📚 For more information, visit: $GITHUB_REPO"
    else
        error "Installation failed. Check the log file: $LOG_FILE"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Cross-Shell Environment Loader - GitHub Installation"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "OPTIONS:"
        echo "  --help, -h     Show this help message"
        echo "  --all          Install for all available shells (non-interactive)"
        echo "  --shells SHELLS Install for specific shells (e.g., --shells bash zsh)"
        echo ""
        echo "Examples:"
        echo "  curl -fsSL $GITHUB_RAW/install-github.sh | bash"
        echo "  curl -fsSL $GITHUB_RAW/install-github.sh | bash -s -- --all"
        echo "  curl -fsSL $GITHUB_RAW/install-github.sh | bash -s -- --shells bash zsh"
        exit 0
        ;;
    --all)
        # Non-interactive install all
        check_prerequisites || exit 1
        download_files || exit 1
        cd "$TEMP_DIR"
        ./install.sh --all
        ;;
    --shells)
        # Non-interactive install specific shells
        shift
        if [ $# -eq 0 ]; then
            error "No shells specified after --shells"
            exit 1
        fi
        check_prerequisites || exit 1
        download_files || exit 1
        cd "$TEMP_DIR"
        ./install.sh "$@"
        ;;
    *)
        # Interactive mode
        main "$@"
        ;;
esac
