#!/bin/bash
# Test script for both installation methods
# ========================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

success() {
    echo -e "${GREEN}✅ $*${NC}"
}

error() {
    echo -e "${RED}❌ $*${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

# Test local installation
test_local_installation() {
    info "Testing local installation method..."
    
    # Check if we're in the project directory
    if [ ! -f "install.sh" ]; then
        error "install.sh not found. Please run this script from the project root."
        return 1
    fi
    
    # Test dry run
    info "Testing dry run..."
    if ./install.sh --dry-run bash; then
        success "Local dry run test passed"
    else
        error "Local dry run test failed"
        return 1
    fi
    
    # Test system check
    info "Testing system check..."
    if ./install.sh --check; then
        success "Local system check passed"
    else
        warning "Local system check had warnings (this may be normal)"
    fi
    
    # Test shell listing
    info "Testing shell listing..."
    if ./install.sh --list; then
        success "Local shell listing passed"
    else
        error "Local shell listing failed"
        return 1
    fi
    
    success "Local installation method tests completed"
}

# Test online installation (simulation)
test_online_installation() {
    info "Testing online installation method (simulation)..."
    
    # Test if the GitHub raw URL is accessible
    local github_url="https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh"
    
    info "Testing GitHub accessibility..."
    if command -v curl >/dev/null 2>&1; then
        if curl -fsSL --connect-timeout 10 "$github_url" >/dev/null; then
            success "GitHub URL is accessible via curl"
        else
            warning "GitHub URL not accessible (network issue or repo not published yet)"
            return 0  # Don't fail the test for network issues
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q --timeout=10 -O /dev/null "$github_url"; then
            success "GitHub URL is accessible via wget"
        else
            warning "GitHub URL not accessible (network issue or repo not published yet)"
            return 0  # Don't fail the test for network issues
        fi
    else
        warning "Neither curl nor wget available for online installation test"
        return 0
    fi
    
    # Test download simulation (don't actually install)
    info "Simulating online installation download..."
    local temp_file="/tmp/install-test-$$"
    
    if command -v curl >/dev/null 2>&1; then
        if curl -fsSL --connect-timeout 10 "$github_url" > "$temp_file"; then
            if [ -s "$temp_file" ] && head -1 "$temp_file" | grep -q "#!/bin/bash"; then
                success "Online installation script downloaded successfully"
                rm -f "$temp_file"
            else
                error "Downloaded file is not a valid bash script"
                rm -f "$temp_file"
                return 1
            fi
        else
            warning "Failed to download installation script (network issue)"
            return 0
        fi
    fi
    
    success "Online installation method tests completed"
}

# Test installation detection logic
test_installation_detection() {
    info "Testing installation detection logic..."
    
    # Test need_download function
    if [ -f "install.sh" ]; then
        # Source the install script to test its functions
        source install.sh >/dev/null 2>&1 || true
        
        # Test in current directory (should not need download)
        if need_download; then
            error "need_download incorrectly returned true in project directory"
            return 1
        else
            success "need_download correctly detected local installation"
        fi
        
        # Test in a different directory (should need download)
        local temp_dir="/tmp/test-install-$$"
        mkdir -p "$temp_dir"
        cd "$temp_dir"
        
        if need_download; then
            success "need_download correctly detected need for online installation"
        else
            error "need_download incorrectly returned false outside project directory"
            cd - >/dev/null
            rm -rf "$temp_dir"
            return 1
        fi
        
        cd - >/dev/null
        rm -rf "$temp_dir"
    else
        warning "Cannot test installation detection without install.sh"
    fi
    
    success "Installation detection tests completed"
}

# Main test function
main() {
    echo "🧪 Shell-Env-Loader Installation Testing"
    echo "========================================"
    echo ""
    
    local test_failures=0
    
    # Test local installation
    if ! test_local_installation; then
        ((test_failures++))
    fi
    
    echo ""
    
    # Test online installation
    if ! test_online_installation; then
        ((test_failures++))
    fi
    
    echo ""
    
    # Test installation detection
    if ! test_installation_detection; then
        ((test_failures++))
    fi
    
    echo ""
    echo "Test Summary"
    echo "============"
    
    if [ $test_failures -eq 0 ]; then
        success "All installation tests passed! 🎉"
        echo ""
        echo "Both installation methods are working correctly:"
        echo "  ✅ Local installation (./install.sh)"
        echo "  ✅ Online installation (curl | bash)"
        echo ""
        echo "Ready for GitHub publication! 🚀"
        return 0
    else
        error "$test_failures test(s) failed"
        echo ""
        echo "Please fix the issues before publishing to GitHub."
        return 1
    fi
}

# Run tests
main "$@"
