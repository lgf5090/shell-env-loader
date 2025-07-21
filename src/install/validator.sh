#!/bin/bash
# Installation Validation and Testing System
# ==========================================
# Comprehensive validation, testing, and rollback functionality for shell installations

# Source dependencies
VALIDATOR_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Only source dependencies if they haven't been sourced already
if ! command -v detect_platform >/dev/null 2>&1; then
    source "$VALIDATOR_SCRIPT_DIR/../common/platform.sh"
fi

if ! command -v is_shell_available >/dev/null 2>&1; then
    source "$VALIDATOR_SCRIPT_DIR/shell_detector.sh"
fi

# Configuration
INSTALL_DIR="$HOME/.local/share/env-loader"
BACKUP_DIR="$HOME/.local/share/env-loader/backups"
TEST_ENV_FILE="/tmp/env-loader-test.env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_validation() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - VALIDATION: $*" >> "${LOG_FILE:-/tmp/env-loader-validation.log}"
}

info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
    log_validation "INFO: $*"
}

success() {
    echo -e "${GREEN}✅ $*${NC}"
    log_validation "SUCCESS: $*"
}

warning() {
    echo -e "${YELLOW}⚠️  $*${NC}"
    log_validation "WARNING: $*"
}

error() {
    echo -e "${RED}❌ $*${NC}"
    log_validation "ERROR: $*"
}

# Create test environment file
create_test_env() {
    cat > "$TEST_ENV_FILE" << 'EOF'
# Test environment file for validation
TEST_VAR_BASIC=test_value
TEST_VAR_QUOTED="value with spaces"
TEST_VAR_SHELL_BASH=bash_specific
TEST_VAR_SHELL_ZSH=zsh_specific
TEST_VAR_SHELL_FISH=fish_specific
TEST_VAR_SHELL_NU=nu_specific
TEST_VAR_SHELL_PS=ps_specific
TEST_VAR_PLATFORM_LINUX=linux_value
TEST_VAR_PLATFORM_MACOS=macos_value
TEST_VAR_PLATFORM_WIN=windows_value
TEST_VAR_PATH_EXPANSION=~/.test/path
TEST_VAR_UNICODE="Unicode: αβγ 中文 🎉"
EOF
}

# Clean up test files
cleanup_test_files() {
    rm -f "$TEST_ENV_FILE"
}

# Validate file installation for a shell
validate_file_installation() {
    local shell_name="$1"
    local errors=0
    
    info "Validating file installation for $shell_name..."
    
    # Check if shell directory exists
    if [ ! -d "$INSTALL_DIR/$shell_name" ]; then
        error "Shell directory not found: $INSTALL_DIR/$shell_name"
        ((errors++))
    fi
    
    # Check for required files based on shell type
    case "$shell_name" in
        bash)
            local required_files=(
                "$INSTALL_DIR/bash/loader.sh"
                "$INSTALL_DIR/common/platform.sh"
                "$INSTALL_DIR/common/parser.sh"
            )
            ;;
        zsh)
            local required_files=(
                "$INSTALL_DIR/zsh/loader.zsh"
                "$INSTALL_DIR/common/platform.sh"
                "$INSTALL_DIR/common/parser.sh"
            )
            ;;
        fish)
            local required_files=(
                "$INSTALL_DIR/fish/loader.fish"
            )
            ;;
        nu)
            local required_files=(
                "$INSTALL_DIR/nu/loader.nu"
            )
            ;;
        pwsh)
            local required_files=(
                "$INSTALL_DIR/pwsh/loader.ps1"
            )
            ;;
        *)
            error "Unknown shell type: $shell_name"
            return 1
            ;;
    esac
    
    # Check each required file
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            error "Required file not found: $file"
            ((errors++))
        elif [ ! -r "$file" ]; then
            error "Required file not readable: $file"
            ((errors++))
        fi
    done
    
    if [ $errors -eq 0 ]; then
        success "File installation validation passed for $shell_name"
        return 0
    else
        error "File installation validation failed for $shell_name ($errors errors)"
        return 1
    fi
}

# Validate configuration integration for a shell
validate_config_integration() {
    local shell_name="$1"
    local config_file
    
    info "Validating configuration integration for $shell_name..."
    
    config_file=$(get_default_config_file "$shell_name")
    
    if [ ! -f "$config_file" ]; then
        error "Configuration file not found: $config_file"
        return 1
    fi
    
    # Check if integration code is present
    if ! grep -q "env-loader" "$config_file"; then
        error "Integration code not found in $config_file"
        return 1
    fi
    
    # Check for shell-specific integration patterns
    case "$shell_name" in
        bash)
            if ! grep -q "Cross-Shell Environment Loader (Bash)" "$config_file"; then
                error "Bash-specific integration marker not found"
                return 1
            fi
            ;;
        zsh)
            if ! grep -q "Cross-Shell Environment Loader (Zsh)" "$config_file"; then
                error "Zsh-specific integration marker not found"
                return 1
            fi
            ;;
        fish)
            if ! grep -q "Cross-Shell Environment Loader (Fish)" "$config_file"; then
                error "Fish-specific integration marker not found"
                return 1
            fi
            ;;
        nu)
            if ! grep -q "Cross-Shell Environment Loader (Nushell)" "$config_file"; then
                error "Nushell-specific integration marker not found"
                return 1
            fi
            ;;
        pwsh)
            if ! grep -q "Cross-Shell Environment Loader (PowerShell)" "$config_file"; then
                error "PowerShell-specific integration marker not found"
                return 1
            fi
            ;;
    esac
    
    success "Configuration integration validation passed for $shell_name"
    return 0
}

# Test functional integration for a shell
test_functional_integration() {
    local shell_name="$1"
    local shell_executable
    
    info "Testing functional integration for $shell_name..."
    
    # Get shell executable
    shell_executable=$(get_shell_executable "$shell_name")
    if [ -z "$shell_executable" ]; then
        error "Shell executable not found for $shell_name"
        return 1
    fi
    
    # Create test environment
    create_test_env
    
    # Test based on shell type
    case "$shell_name" in
        bash)
            test_bash_integration "$shell_executable"
            ;;
        zsh)
            test_zsh_integration "$shell_executable"
            ;;
        fish)
            test_fish_integration "$shell_executable"
            ;;
        nu)
            test_nu_integration "$shell_executable"
            ;;
        pwsh)
            test_pwsh_integration "$shell_executable"
            ;;
        *)
            error "No functional test available for $shell_name"
            cleanup_test_files
            return 1
            ;;
    esac
    
    local result=$?
    cleanup_test_files
    
    if [ $result -eq 0 ]; then
        success "Functional integration test passed for $shell_name"
    else
        error "Functional integration test failed for $shell_name"
    fi
    
    return $result
}

# Test Bash integration
test_bash_integration() {
    local bash_executable="$1"
    local config_file=$(get_default_config_file "bash")
    
    # Test in a clean environment
    "$bash_executable" --noprofile --norc -c "
        source '$config_file'
        
        # Test if loader functions are available
        if ! command -v load_env_file >/dev/null 2>&1; then
            echo 'ERROR: load_env_file function not available'
            exit 1
        fi
        
        # Test loading the test environment
        if ! load_env_file '$TEST_ENV_FILE' >/dev/null 2>&1; then
            echo 'ERROR: Failed to load test environment file'
            exit 1
        fi
        
        # Test if variables were loaded
        if [ \"\$TEST_VAR_BASIC\" != 'test_value' ]; then
            echo 'ERROR: Basic variable not loaded correctly'
            exit 1
        fi
        
        echo 'SUCCESS: Bash integration test passed'
    " 2>/dev/null
}

# Test Zsh integration
test_zsh_integration() {
    local zsh_executable="$1"
    local config_file=$(get_default_config_file "zsh")
    
    # Test in a clean environment
    "$zsh_executable" --no-rcs --no-globalrcs -c "
        source '$config_file'
        
        # Test if loader functions are available
        if ! command -v load_env_file >/dev/null 2>&1; then
            echo 'ERROR: load_env_file function not available'
            exit 1
        fi
        
        # Test loading the test environment
        if ! load_env_file '$TEST_ENV_FILE' >/dev/null 2>&1; then
            echo 'ERROR: Failed to load test environment file'
            exit 1
        fi
        
        # Test if variables were loaded
        if [[ \"\$TEST_VAR_BASIC\" != 'test_value' ]]; then
            echo 'ERROR: Basic variable not loaded correctly'
            exit 1
        fi
        
        echo 'SUCCESS: Zsh integration test passed'
    " 2>/dev/null
}

# Test Fish integration
test_fish_integration() {
    local fish_executable="$1"
    local config_file=$(get_default_config_file "fish")
    
    # Test in a clean environment
    "$fish_executable" --no-config -c "
        source '$config_file'
        
        # Test if loader functions are available
        if not functions -q load_env_file
            echo 'ERROR: load_env_file function not available'
            exit 1
        end
        
        # Test loading the test environment
        if not load_env_file '$TEST_ENV_FILE' >/dev/null 2>&1
            echo 'ERROR: Failed to load test environment file'
            exit 1
        end
        
        # Test if variables were loaded
        if test \"\$TEST_VAR_BASIC\" != 'test_value'
            echo 'ERROR: Basic variable not loaded correctly'
            exit 1
        end
        
        echo 'SUCCESS: Fish integration test passed'
    " 2>/dev/null
}

# Test Nushell integration
test_nu_integration() {
    local nu_executable="$1"
    local config_file=$(get_default_config_file "nu")
    
    # Test in a clean environment
    "$nu_executable" --no-config-file -c "
        source '$config_file'
        
        # Test loading the test environment
        try {
            let env_vars = (get_env_vars_to_set '$TEST_ENV_FILE')
            if (\$env_vars | columns | length) == 0 {
                print 'ERROR: No variables loaded from test file'
                exit 1
            }
        } catch {
            print 'ERROR: Failed to load test environment file'
            exit 1
        }
        
        print 'SUCCESS: Nushell integration test passed'
    " 2>/dev/null
}

# Test PowerShell integration
test_pwsh_integration() {
    local pwsh_executable="$1"
    local config_file=$(get_default_config_file "pwsh")
    
    # Test in a clean environment
    "$pwsh_executable" -NoProfile -c "
        . '$config_file'
        
        # Test if loader functions are available
        if (-not (Get-Command Load-EnvFile -ErrorAction SilentlyContinue)) {
            Write-Output 'ERROR: Load-EnvFile function not available'
            exit 1
        }
        
        # Test loading the test environment
        try {
            Load-EnvFile '$TEST_ENV_FILE' | Out-Null
        } catch {
            Write-Output 'ERROR: Failed to load test environment file'
            exit 1
        }
        
        # Test if variables were loaded
        if (\$env:TEST_VAR_BASIC -ne 'test_value') {
            Write-Output 'ERROR: Basic variable not loaded correctly'
            exit 1
        }
        
        Write-Output 'SUCCESS: PowerShell integration test passed'
    " 2>/dev/null
}

# Create backup of configuration file
create_config_backup() {
    local shell_name="$1"
    local config_file
    local backup_file
    
    config_file=$(get_default_config_file "$shell_name")
    
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
        local config_file=$(get_default_config_file "$shell_name")
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

# Comprehensive validation for a shell installation
validate_shell_installation() {
    local shell_name="$1"
    local validation_errors=0
    
    info "Starting comprehensive validation for $shell_name..."
    
    # File installation validation
    if ! validate_file_installation "$shell_name"; then
        ((validation_errors++))
    fi
    
    # Configuration integration validation
    if ! validate_config_integration "$shell_name"; then
        ((validation_errors++))
    fi
    
    # Functional integration test
    if ! test_functional_integration "$shell_name"; then
        ((validation_errors++))
    fi
    
    if [ $validation_errors -eq 0 ]; then
        success "All validation tests passed for $shell_name ✅"
        return 0
    else
        error "Validation failed for $shell_name ($validation_errors errors) ❌"
        return 1
    fi
}

# Generate validation report
generate_validation_report() {
    local shells=("$@")
    local total_shells=${#shells[@]}
    local passed_shells=0
    local failed_shells=()
    
    echo ""
    echo "Validation Report"
    echo "================"
    echo "Total shells tested: $total_shells"
    echo ""
    
    for shell in "${shells[@]}"; do
        echo "Testing $shell..."
        if validate_shell_installation "$shell"; then
            ((passed_shells++))
        else
            failed_shells+=("$shell")
        fi
        echo ""
    done
    
    echo "Summary:"
    echo "  Passed: $passed_shells/$total_shells"
    echo "  Failed: ${#failed_shells[@]}/$total_shells"
    
    if [ ${#failed_shells[@]} -gt 0 ]; then
        echo "  Failed shells: ${failed_shells[*]}"
    fi
    
    if [ $passed_shells -eq $total_shells ]; then
        success "All shell installations validated successfully! 🎉"
        return 0
    else
        error "Some shell installations failed validation"
        return 1
    fi
}

# Main function for command-line usage
main() {
    case "${1:-help}" in
        validate)
            if [ -n "$2" ]; then
                validate_shell_installation "$2"
            else
                echo "Usage: $0 validate <shell_name>"
                exit 1
            fi
            ;;
        test)
            if [ -n "$2" ]; then
                test_functional_integration "$2"
            else
                echo "Usage: $0 test <shell_name>"
                exit 1
            fi
            ;;
        rollback)
            if [ -n "$2" ]; then
                rollback_installation "$2" "$3"
            else
                echo "Usage: $0 rollback <shell_name> [backup_file]"
                exit 1
            fi
            ;;
        report)
            shift
            if [ $# -eq 0 ]; then
                # Test all available shells
                readarray -t shells <<< "$(discover_available_shells | tr ' ' '\n')"
                generate_validation_report "${shells[@]}"
            else
                generate_validation_report "$@"
            fi
            ;;
        help|*)
            echo "Installation Validator - Validation and testing for shell installations"
            echo ""
            echo "Usage: $0 <command> [arguments]"
            echo ""
            echo "Commands:"
            echo "  validate <shell>    - Validate installation for a specific shell"
            echo "  test <shell>        - Test functional integration for a specific shell"
            echo "  rollback <shell>    - Rollback installation for a specific shell"
            echo "  report [shells...]  - Generate validation report (all shells if none specified)"
            echo "  help                - Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 validate bash"
            echo "  $0 test fish"
            echo "  $0 report bash zsh fish"
            echo "  $0 rollback nu"
            ;;
    esac
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
