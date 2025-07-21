#!/bin/bash
# Cross-Shell Environment Loader - Universal Installation Script
# ==============================================================
# Unified installation system for all supported shells
# Supports: Bash, Zsh, Fish, Nushell, PowerShell

set -e  # Exit on any error

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/share/env-loader"
LOG_FILE="/tmp/env-loader-install.log"

# GitHub repository configuration
GITHUB_REPO="https://github.com/lgf5090/shell-env-loader"
GITHUB_RAW="https://raw.githubusercontent.com/lgf5090/shell-env-loader/main"
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

# Source shell detector (will be loaded after download if needed)
SHELL_DETECTOR_LOADED=false

load_shell_detector() {
    if [ "$SHELL_DETECTOR_LOADED" = "false" ]; then
        if [ -f "$SCRIPT_DIR/src/install/shell_detector.sh" ]; then
            source "$SCRIPT_DIR/src/install/shell_detector.sh"
            SHELL_DETECTOR_LOADED=true
        else
            error "Cannot find shell_detector.sh"
            return 1
        fi
    fi
}

# Simple shell detection for basic functionality (used when shell_detector.sh is not available)
simple_shell_detection() {
    case "$1" in
        discover_available_shells)
            local shells=""
            for shell in bash zsh fish nu pwsh; do
                if command -v "$shell" >/dev/null 2>&1; then
                    shells="$shells $shell"
                fi
            done
            # Add bzsh if both bash and zsh are available
            if command -v "bash" >/dev/null 2>&1 && command -v "zsh" >/dev/null 2>&1; then
                shells="$shells bzsh"
            fi
            echo "$shells" | sed 's/^ *//'
            ;;
        is_shell_available)
            command -v "$2" >/dev/null 2>&1
            ;;
        get_default_config_file)
            case "$2" in
                bash) echo "$HOME/.bashrc" ;;
                zsh) echo "$HOME/.zshrc" ;;
                fish) echo "$HOME/.config/fish/config.fish" ;;
                nu) echo "$HOME/.config/nushell/config.nu" ;;
                pwsh) echo "$HOME/.config/powershell/profile.ps1" ;;
                *) echo "" ;;
            esac
            ;;
        check_shell_compatibility)
            # Basic compatibility check - just return true for now
            return 0
            ;;
        generate_shell_report)
            echo "Cross-Shell Environment Loader - System Check"
            echo "============================================="
            echo ""
            echo "Platform: $(uname -s)"
            echo "Architecture: $(uname -m)"
            echo "Current Shell: $(basename "$SHELL")"
            echo ""
            echo "Available Shells:"
            local available_shells=$(simple_shell_detection discover_available_shells)
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
            ;;
    esac
}

# Source validator functions (inline to avoid path issues)
INSTALL_DIR="$HOME/.local/share/env-loader"
BACKUP_DIR="$HOME/.local/share/env-loader/backups"
TEST_ENV_FILE="/tmp/env-loader-test.env"

# Create backup of configuration file
create_config_backup() {
    local shell_name="$1"
    local config_file
    local backup_file

    load_shell_detector || true  # Don't fail if shell detector can't load
    config_file=$(get_config_file_fallback "$shell_name")

    if [ ! -f "$config_file" ]; then
        return 0  # No file to backup
    fi

    # Create backup directory
    mkdir -p "$BACKUP_DIR"

    # Create timestamped backup
    backup_file="$BACKUP_DIR/${shell_name}-config-$(date +%Y%m%d_%H%M%S).backup"

    if cp "$config_file" "$backup_file"; then
        info "Created backup: $backup_file"
        echo "$backup_file"  # Return backup file path
        return 0
    else
        error "Failed to create backup: $backup_file"
        return 1
    fi
}

# Rollback installation for a shell
rollback_installation() {
    local shell_name="$1"
    local backup_file="$2"

    info "Rolling back installation for $shell_name..."

    # Restore configuration file if backup exists
    if [ -n "$backup_file" ] && [ -f "$backup_file" ]; then
        local config_file=$(get_config_file_fallback "$shell_name")
        if cp "$backup_file" "$config_file"; then
            success "Restored configuration from backup: $backup_file"
        else
            error "Failed to restore configuration from backup"
        fi
    fi

    # Remove installed files
    if [ -d "$INSTALL_DIR/$shell_name" ]; then
        rm -rf "$INSTALL_DIR/$shell_name"
        info "Removed installed files for $shell_name"
    fi

    success "Rollback completed for $shell_name"
}

# Get default config file with fallback
get_config_file_fallback() {
    local shell_name="$1"

    # Try shell_detector first if available
    if [ "$SHELL_DETECTOR_LOADED" = "true" ]; then
        local config_file=$(get_default_config_file "$shell_name" 2>/dev/null)
        if [ -n "$config_file" ]; then
            echo "$config_file"
            return 0
        fi
    fi

    # Fallback to hardcoded paths
    case "$shell_name" in
        bash) echo "$HOME/.bashrc" ;;
        zsh) echo "$HOME/.zshrc" ;;
        fish) echo "$HOME/.config/fish/config.fish" ;;
        nu) echo "$HOME/.config/nushell/config.nu" ;;
        pwsh) echo "$HOME/.config/powershell/profile.ps1" ;;
        *) echo "" ;;
    esac
}

# Simple validation function
validate_shell_installation() {
    local shell_name="$1"

    info "Validating $shell_name installation..."

    # Ensure shell detector is loaded
    load_shell_detector || true  # Don't fail if shell detector can't load

    # Check if shell directory exists
    if [ ! -d "$INSTALL_DIR/$shell_name" ]; then
        error "Shell directory not found: $INSTALL_DIR/$shell_name"
        return 1
    fi

    # Check if config integration exists
    local config_file=$(get_config_file_fallback "$shell_name")
    if [ ! -f "$config_file" ]; then
        error "Configuration file not found: $config_file"
        return 1
    fi

    if ! grep -q "env-loader" "$config_file"; then
        error "Integration code not found in $config_file"
        return 1
    fi

    success "Basic validation passed for $shell_name"
    return 0
}

# Installation configuration
declare -A SHELL_INSTALLERS=(
    ["bash"]="install_bash"
    ["zsh"]="install_zsh"
    ["bzsh"]="install_bzsh"
    ["fish"]="install_fish"
    ["nu"]="install_nu"
    ["pwsh"]="install_pwsh"
)

# Show usage information
show_usage() {
    cat << EOF
Cross-Shell Environment Loader - Universal Installation Script
=============================================================

🌐 ONLINE INSTALLATION (recommended):
    curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash

🏠 LOCAL INSTALLATION:
    git clone https://github.com/lgf5090/shell-env-loader.git && cd shell-env-loader && ./install.sh

Usage: $0 [OPTIONS] [SHELLS...]

OPTIONS:
    --all               Install for all available shells (recommended)
    --list              List available shells on this system
    --check             Check system compatibility
    --validate          Validate existing installations
    --uninstall         Uninstall from specified shells (or all with --all)
    --force             Force installation even if already installed
    --dry-run           Show what would be installed without actually installing
    --help              Show this help message

SHELLS:
    bash                Install for Bash shell
    zsh                 Install for Zsh shell
    bzsh                Install Bash/Zsh compatible version for both shells
    fish                Install for Fish shell
    nu                  Install for Nushell
    pwsh                Install for PowerShell

ONLINE INSTALLATION EXAMPLES:
    # Install for all available shells (recommended)
    curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash

    # Install for specific shells
    curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash -s -- bash zsh

    # Install for all shells non-interactively
    curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash -s -- --all

    # Check system compatibility
    curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash -s -- --check

    # List available shells
    curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash -s -- --list

LOCAL INSTALLATION EXAMPLES:
    $0 --all                    # Install for all available shells
    $0 bash zsh                 # Install for Bash and Zsh only
    $0 --check                  # Check system compatibility
    $0 --list                   # List available shells
    $0 --uninstall --all        # Uninstall from all shells
    $0 --uninstall bash zsh     # Uninstall from Bash and Zsh

NOTES:
    - 🌐 Online installation automatically downloads all necessary files from GitHub
    - 🏠 Local installation uses existing files in the repository
    - Installation requires write access to ~/.local/share/ and shell config files
    - Backup files are created automatically before modification
    - Use --force to reinstall over existing installations
    - Logs are written to: $LOG_FILE

EOF
}

# Check if we need to download files from GitHub
need_download() {
    # If src directory doesn't exist, we need to download
    [ ! -d "$SCRIPT_DIR/src" ]
}

# Check if this is an online installation (script downloaded via curl/wget)
is_online_installation() {
    # Check if we're running from a temporary directory or if src doesn't exist
    case "$SCRIPT_DIR" in
        /tmp/*) return 0 ;;  # Running from temp directory
        *) [ ! -d "$SCRIPT_DIR/src" ] ;;  # No src directory
    esac
}

# Download files from GitHub
download_from_github() {
    info "Downloading shell-env-loader from GitHub..."

    # Check for download tools
    local download_cmd=""
    if command -v curl >/dev/null 2>&1; then
        download_cmd="curl -fsSL"
    elif command -v wget >/dev/null 2>&1; then
        download_cmd="wget -qO-"
    else
        error "Neither curl nor wget found. Please install one of them."
        return 1
    fi

    # Create temporary directory
    mkdir -p "$TEMP_DIR"

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
            rm -rf "$TEMP_DIR"
            return 1
        fi
    done

    # Update SCRIPT_DIR to point to temp directory
    SCRIPT_DIR="$TEMP_DIR"

    success "Successfully downloaded all files from GitHub"
    return 0
}

# Clean up temporary files
cleanup_temp_files() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Check system prerequisites
check_prerequisites() {
    info "Checking system prerequisites..."

    # Check if we can write to install directory
    if ! mkdir -p "$INSTALL_DIR" 2>/dev/null; then
        error "Cannot create install directory: $INSTALL_DIR"
        return 1
    fi

    # Check if we can write to log file
    if ! touch "$LOG_FILE" 2>/dev/null; then
        warning "Cannot write to log file: $LOG_FILE"
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

# Create installation directory structure
create_install_structure() {
    info "Creating installation directory structure..."
    
    local dirs=(
        "$INSTALL_DIR"
        "$INSTALL_DIR/bash"
        "$INSTALL_DIR/zsh" 
        "$INSTALL_DIR/fish"
        "$INSTALL_DIR/nu"
        "$INSTALL_DIR/pwsh"
        "$INSTALL_DIR/common"
    )
    
    for dir in "${dirs[@]}"; do
        if ! mkdir -p "$dir"; then
            error "Failed to create directory: $dir"
            return 1
        fi
    done
    
    success "Installation directory structure created"
    return 0
}

# Copy shell-specific files
copy_shell_files() {
    local shell_name="$1"
    
    info "Copying $shell_name files..."
    
    # Copy common files
    if ! cp -r "$SCRIPT_DIR/src/common/"* "$INSTALL_DIR/common/"; then
        error "Failed to copy common files"
        return 1
    fi
    
    # Copy shell-specific files
    case "$shell_name" in
        bash)
            # Copy bzsh files first, then bash-specific files (so bash files take precedence)
            cp "$SCRIPT_DIR/src/shells/bzsh/"* "$INSTALL_DIR/bash/" 2>/dev/null || true
            cp "$SCRIPT_DIR/src/shells/bash/"* "$INSTALL_DIR/bash/" 2>/dev/null || true
            ;;
        zsh)
            # Copy bzsh files first, then zsh-specific files (so zsh files take precedence)
            cp "$SCRIPT_DIR/src/shells/bzsh/"* "$INSTALL_DIR/zsh/" 2>/dev/null || true
            cp "$SCRIPT_DIR/src/shells/zsh/"* "$INSTALL_DIR/zsh/" 2>/dev/null || true
            ;;
        fish)
            cp "$SCRIPT_DIR/src/shells/fish/"* "$INSTALL_DIR/fish/" 2>/dev/null || true
            ;;
        nu)
            cp "$SCRIPT_DIR/src/shells/nu/"* "$INSTALL_DIR/nu/" 2>/dev/null || true
            ;;
        pwsh)
            cp "$SCRIPT_DIR/src/shells/pwsh/"* "$INSTALL_DIR/pwsh/" 2>/dev/null || true
            ;;
    esac
    
    # Make scripts executable
    find "$INSTALL_DIR" -name "*.sh" -exec chmod +x {} \;
    find "$INSTALL_DIR" -name "*.zsh" -exec chmod +x {} \;
    
    success "$shell_name files copied successfully"
    return 0
}

# Install integration for Bash
install_bash() {
    info "Installing Bash integration..."
    local backup_file=""

    # Ensure shell detector is loaded
    load_shell_detector || return 1

    if ! is_shell_available "bash"; then
        warning "Bash is not available on this system"
        return 1
    fi

    if ! check_shell_compatibility "bash"; then
        warning "Bash version may not be compatible"
    fi

    # Create backup before making changes
    backup_file=$(create_config_backup "bash")

    # Copy files
    if ! copy_shell_files "bash"; then
        error "Failed to copy Bash files"
        [ -n "$backup_file" ] && rollback_installation "bash" "$backup_file"
        return 1
    fi

    # Get config file
    local config_file=$(get_config_file_fallback "bash")

    # Check if already installed
    if [ "$FORCE_INSTALL" != "true" ] && grep -q "env-loader" "$config_file" 2>/dev/null; then
        warning "Bash integration already installed in $config_file"
        return 0
    fi

    # Add integration
    cat >> "$config_file" << 'EOF'

# Cross-Shell Environment Loader (Bash)
# =====================================
# Automatically load environment variables from .env files
if [ -f "$HOME/.local/share/env-loader/bash/loader.sh" ]; then
    source "$HOME/.local/share/env-loader/bash/loader.sh"
fi
EOF

    # Validate installation
    if validate_shell_installation "bash"; then
        success "Bash integration installed and validated successfully"
        return 0
    else
        error "Bash installation validation failed, rolling back..."
        rollback_installation "bash" "$backup_file"
        return 1
    fi
}

# Install integration for Zsh
install_zsh() {
    info "Installing Zsh integration..."
    local backup_file=""

    # Ensure shell detector is loaded
    load_shell_detector || return 1

    if ! is_shell_available "zsh"; then
        warning "Zsh is not available on this system"
        return 1
    fi

    if ! check_shell_compatibility "zsh"; then
        warning "Zsh version may not be compatible"
    fi

    # Create backup before making changes
    backup_file=$(create_config_backup "zsh")

    # Copy files
    if ! copy_shell_files "zsh"; then
        error "Failed to copy Zsh files"
        [ -n "$backup_file" ] && rollback_installation "zsh" "$backup_file"
        return 1
    fi

    # Get config file
    local config_file=$(get_config_file_fallback "zsh")

    # Check if already installed
    if [ "$FORCE_INSTALL" != "true" ] && grep -q "env-loader" "$config_file" 2>/dev/null; then
        warning "Zsh integration already installed in $config_file"
        return 0
    fi

    # Add integration
    cat >> "$config_file" << 'EOF'

# Cross-Shell Environment Loader (Zsh)
# ====================================
# Automatically load environment variables from .env files
if [[ -f "$HOME/.local/share/env-loader/zsh/loader.zsh" ]]; then
    source "$HOME/.local/share/env-loader/zsh/loader.zsh"
fi
EOF

    # Validate installation
    if validate_shell_installation "zsh"; then
        success "Zsh integration installed and validated successfully"
        return 0
    else
        error "Zsh installation validation failed, rolling back..."
        rollback_installation "zsh" "$backup_file"
        return 1
    fi
}

# Install Bash/Zsh compatible integration for both shells
install_bzsh() {
    info "Installing Bash/Zsh compatible integration..."
    local bash_success=false
    local zsh_success=false
    local total_success=0

    # Ensure shell detector is loaded
    load_shell_detector || return 1

    # Install for Bash if available
    if is_shell_available "bash"; then
        info "Installing bzsh integration for Bash..."
        local backup_file=""

        # Create backup before making changes
        backup_file=$(create_config_backup "bash")

        # Copy bzsh files to bash directory
        if copy_shell_files "bash"; then
            # Get config file
            local config_file=$(get_config_file_fallback "bash")

            # Check if already installed
            if [ "$FORCE_INSTALL" != "true" ] && grep -q "env-loader" "$config_file" 2>/dev/null; then
                warning "Bash integration already installed in $config_file"
            else
                # Add integration
                cat >> "$config_file" << 'EOF'

# Cross-Shell Environment Loader (Bash/Zsh Compatible)
# ===================================================
# Automatically load environment variables from .env files
if [ -f "$HOME/.local/share/env-loader/bash/loader.sh" ]; then
    source "$HOME/.local/share/env-loader/bash/loader.sh"
fi
EOF
            fi

            # Validate installation
            if validate_shell_installation "bash"; then
                success "Bash integration (bzsh) installed and validated successfully"
                bash_success=true
                ((total_success++))
            else
                error "Bash installation validation failed, rolling back..."
                rollback_installation "bash" "$backup_file"
            fi
        else
            error "Failed to copy files for Bash"
            [ -n "$backup_file" ] && rollback_installation "bash" "$backup_file"
        fi
    else
        warning "Bash is not available on this system"
    fi

    # Install for Zsh if available
    if is_shell_available "zsh"; then
        info "Installing bzsh integration for Zsh..."
        local backup_file=""

        # Create backup before making changes
        backup_file=$(create_config_backup "zsh")

        # Copy bzsh files to zsh directory
        if copy_shell_files "zsh"; then
            # Get config file
            local config_file=$(get_config_file_fallback "zsh")

            # Check if already installed
            if [ "$FORCE_INSTALL" != "true" ] && grep -q "env-loader" "$config_file" 2>/dev/null; then
                warning "Zsh integration already installed in $config_file"
            else
                # Add integration
                cat >> "$config_file" << 'EOF'

# Cross-Shell Environment Loader (Bash/Zsh Compatible)
# ===================================================
# Automatically load environment variables from .env files
if [[ -f "$HOME/.local/share/env-loader/zsh/loader.zsh" ]]; then
    source "$HOME/.local/share/env-loader/zsh/loader.zsh"
fi
EOF
            fi

            # Validate installation
            if validate_shell_installation "zsh"; then
                success "Zsh integration (bzsh) installed and validated successfully"
                zsh_success=true
                ((total_success++))
            else
                error "Zsh installation validation failed, rolling back..."
                rollback_installation "zsh" "$backup_file"
            fi
        else
            error "Failed to copy files for Zsh"
            [ -n "$backup_file" ] && rollback_installation "zsh" "$backup_file"
        fi
    else
        warning "Zsh is not available on this system"
    fi

    # Summary
    if [ $total_success -gt 0 ]; then
        success "Bzsh integration completed successfully for $total_success shell(s)"
        return 0
    else
        error "Bzsh integration failed for all shells"
        return 1
    fi
}

# Install integration for Fish
install_fish() {
    info "Installing Fish integration..."
    local backup_file=""

    # Ensure shell detector is loaded
    load_shell_detector || return 1

    if ! is_shell_available "fish"; then
        warning "Fish is not available on this system"
        return 1
    fi

    if ! check_shell_compatibility "fish"; then
        warning "Fish version may not be compatible"
    fi

    # Create backup before making changes
    backup_file=$(create_config_backup "fish")

    # Copy files
    if ! copy_shell_files "fish"; then
        error "Failed to copy Fish files"
        [ -n "$backup_file" ] && rollback_installation "fish" "$backup_file"
        return 1
    fi

    # Get config file
    local config_file=$(get_config_file_fallback "fish")
    local config_dir=$(dirname "$config_file")

    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"

    # Check if already installed
    if [ "$FORCE_INSTALL" != "true" ] && grep -q "env-loader" "$config_file" 2>/dev/null; then
        warning "Fish integration already installed in $config_file"
        return 0
    fi

    # Add integration
    cat >> "$config_file" << 'EOF'

# Cross-Shell Environment Loader (Fish)
# =====================================
# Automatically load environment variables from .env files
if test -f "$HOME/.local/share/env-loader/fish/loader.fish"
    source "$HOME/.local/share/env-loader/fish/loader.fish"
end
EOF

    # Validate installation
    if validate_shell_installation "fish"; then
        success "Fish integration installed and validated successfully"
        return 0
    else
        error "Fish installation validation failed, rolling back..."
        rollback_installation "fish" "$backup_file"
        return 1
    fi
}

# Install integration for Nushell
install_nu() {
    info "Installing Nushell integration..."
    
    if ! is_shell_available "nu"; then
        warning "Nushell is not available on this system"
        return 1
    fi
    
    if ! check_shell_compatibility "nu"; then
        warning "Nushell version may not be compatible"
    fi
    
    # Copy files
    copy_shell_files "nu" || return 1
    
    # Get config file
    local config_file=$(get_default_config_file "nu")
    local config_dir=$(dirname "$config_file")
    
    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"
    
    # Check if already installed
    if [ "$FORCE_INSTALL" != "true" ] && grep -q "env-loader" "$config_file" 2>/dev/null; then
        warning "Nushell integration already installed in $config_file"
        return 0
    fi
    
    # Create backup
    if [ -f "$config_file" ]; then
        local backup_file="${config_file}.env-loader-backup.$(date +%Y%m%d_%H%M%S)"
        cp "$config_file" "$backup_file"
        info "Created backup: $backup_file"
    fi
    
    # Add integration
    cat >> "$config_file" << 'EOF'

# Cross-Shell Environment Loader (Nushell)
# ========================================
# Automatically load environment variables from .env files
if ($env.HOME | path join ".local/share/env-loader/nu/loader.nu" | path exists) {
    source ($env.HOME | path join ".local/share/env-loader/nu/loader.nu")
}
EOF
    
    # Validate installation
    if validate_shell_installation "nu"; then
        success "Nushell integration installed and validated successfully"
        return 0
    else
        error "Nushell installation validation failed, rolling back..."
        rollback_installation "nu" "$backup_file"
        return 1
    fi
}

# Install integration for PowerShell
install_pwsh() {
    info "Installing PowerShell integration..."
    
    if ! is_shell_available "pwsh"; then
        warning "PowerShell is not available on this system"
        return 1
    fi
    
    if ! check_shell_compatibility "pwsh"; then
        warning "PowerShell version may not be compatible"
    fi
    
    # Copy files
    copy_shell_files "pwsh" || return 1
    
    # Get config file
    local config_file=$(get_default_config_file "pwsh")
    local config_dir=$(dirname "$config_file")
    
    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"
    
    # Check if already installed
    if [ "$FORCE_INSTALL" != "true" ] && grep -q "env-loader" "$config_file" 2>/dev/null; then
        warning "PowerShell integration already installed in $config_file"
        return 0
    fi
    
    # Create backup
    if [ -f "$config_file" ]; then
        local backup_file="${config_file}.env-loader-backup.$(date +%Y%m%d_%H%M%S)"
        cp "$config_file" "$backup_file"
        info "Created backup: $backup_file"
    fi
    
    # Add integration
    cat >> "$config_file" << 'EOF'

# Cross-Shell Environment Loader (PowerShell)
# ===========================================
# Automatically load environment variables from .env files
$envLoaderPath = Join-Path $env:HOME ".local/share/env-loader/pwsh/loader.ps1"
if (Test-Path $envLoaderPath) {
    . $envLoaderPath
}
EOF
    
    # Validate installation
    if validate_shell_installation "pwsh"; then
        success "PowerShell integration installed and validated successfully"
        return 0
    else
        error "PowerShell installation validation failed, rolling back..."
        rollback_installation "pwsh" "$backup_file"
        return 1
    fi
}

# Parse command line arguments
parse_arguments() {
    INSTALL_ALL=false
    FORCE_INSTALL=false
    DRY_RUN=false
    UNINSTALL=false
    SHELLS_TO_INSTALL=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                INSTALL_ALL=true
                shift
                ;;
            --list)
                echo "Available shells on this system:"
                if [ "$SHELL_DETECTOR_LOADED" = "true" ]; then
                    discover_available_shells | tr ' ' '\n' | sed 's/^/  /'
                else
                    simple_shell_detection discover_available_shells | tr ' ' '\n' | sed 's/^/  /'
                fi
                exit 0
                ;;
            --check)
                if [ "$SHELL_DETECTOR_LOADED" = "true" ]; then
                    generate_shell_report
                else
                    simple_shell_detection generate_shell_report
                fi
                exit 0
                ;;
            --validate)
                # Validation requires full shell detector, so load it first
                load_shell_detector || exit 1
                shift
                if [ $# -eq 0 ]; then
                    # Validate all available shells
                    available_shells=$(discover_available_shells)
                    for shell in $available_shells; do
                        validate_shell_installation "$shell"
                    done
                else
                    # Validate specified shells
                    for shell in "$@"; do
                        validate_shell_installation "$shell"
                    done
                fi
                exit $?
                ;;
            --uninstall)
                UNINSTALL=true
                shift
                ;;
            --force)
                FORCE_INSTALL=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            bash|zsh|bzsh|fish|nu|pwsh)
                SHELLS_TO_INSTALL+=("$1")
                shift
                ;;
            *)
                error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Main installation function
main() {
    echo "Cross-Shell Environment Loader - Installation Script"
    echo "===================================================="
    echo ""

    # Initialize log
    log "Installation started"

    # Parse arguments
    parse_arguments "$@"

    # Check prerequisites
    check_prerequisites || exit 1

    # Download files from GitHub if needed
    if need_download; then
        if is_online_installation; then
            info "Detected online installation mode - downloading files from GitHub..."
        else
            info "Detected missing files - downloading from GitHub..."
        fi
        download_from_github || exit 1
        # Set up cleanup trap
        trap cleanup_temp_files EXIT
    else
        info "Detected local installation mode - using existing files..."
    fi

    # Load shell detector after files are available
    load_shell_detector || exit 1
    
    # Determine shells to install
    local shells_to_process=()
    
    if [ "$INSTALL_ALL" = true ]; then
        if [ "$SHELL_DETECTOR_LOADED" = "true" ]; then
            readarray -t shells_to_process <<< "$(discover_available_shells | tr ' ' '\n')"
        else
            readarray -t shells_to_process <<< "$(simple_shell_detection discover_available_shells | tr ' ' '\n')"
        fi
    elif [ ${#SHELLS_TO_INSTALL[@]} -gt 0 ]; then
        shells_to_process=("${SHELLS_TO_INSTALL[@]}")
    else
        error "No shells specified. Use --all or specify shell names."
        show_usage
        exit 1
    fi
    
    # Show what will be processed
    info "Shells to process: ${shells_to_process[*]}"
    
    if [ "$DRY_RUN" = true ]; then
        info "DRY RUN - No actual changes will be made"
        for shell in "${shells_to_process[@]}"; do
            echo "  Would process: $shell"
        done
        exit 0
    fi
    
    # Create installation structure
    if [ "$UNINSTALL" != true ]; then
        create_install_structure || exit 1
    fi
    
    # Process each shell
    local success_count=0
    local total_count=${#shells_to_process[@]}
    
    for shell in "${shells_to_process[@]}"; do
        echo ""
        if [ "$UNINSTALL" = true ]; then
            info "Uninstalling $shell integration..."
            # TODO: Implement uninstall functions
            warning "Uninstall functionality not yet implemented for $shell"
        else
            if [ -n "${SHELL_INSTALLERS[$shell]}" ]; then
                if ${SHELL_INSTALLERS[$shell]}; then
                    ((success_count++))
                else
                    error "Failed to install $shell integration"
                fi
            else
                error "No installer available for shell: $shell"
            fi
        fi
    done
    
    echo ""
    echo "Installation Summary"
    echo "==================="
    success "Successfully processed: $success_count/$total_count shells"
    
    if [ $success_count -eq $total_count ]; then
        success "All installations completed successfully!"
        info "Please restart your shell or run 'source ~/.bashrc' (or equivalent) to activate"
    else
        warning "Some installations failed. Check the log file: $LOG_FILE"
        exit 1
    fi
}

# Run main function
main "$@"
