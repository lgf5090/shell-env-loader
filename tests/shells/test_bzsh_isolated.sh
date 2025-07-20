#!/bin/bash
# Isolated Bash/Zsh Compatible Implementation Tests
# =================================================
# Test the bzsh implementation in isolated shell environments

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test execution framework
run_shell_tests() {
    local shell="$1"
    local test_file="$2"
    
    # Execute tests in isolated shell environments to prevent interference
    case "$shell" in
        bash)     bash --noprofile --norc "$test_file" ;;
        zsh)      zsh --no-rcs --no-globalrcs "$test_file" ;;
        fish)     fish --no-config -c "source $test_file" ;;
        nu)       nu --no-config-file "$test_file" ;;
        ps)       pwsh -NoProfile -NoLogo -File "$test_file" ;;
    esac
}

verify_test_result() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✅ $test_name: PASS${NC}"
        return 0
    else
        echo -e "${RED}❌ $test_name: FAIL${NC} (expected: '$expected', got: '$actual')"
        return 1
    fi
}

# Create test script for bash
create_bash_test_script() {
    local test_script="$1"
    
    cat > "$test_script" << 'EOF'
#!/bin/bash
# Bash test script for bzsh loader

# Prevent auto-initialization during sourcing
export ENV_LOADER_INITIALIZED=true

# Source the bzsh loader (use absolute path)
LOADER_PATH="ABSOLUTE_LOADER_PATH"
source "$LOADER_PATH"

# Verify shell detection
current_shell=$(get_current_shell)
if [ "$current_shell" != "BASH" ]; then
    echo "ERROR: Expected BASH, got $current_shell"
    exit 1
fi

# Clear variables and load .env (thorough cleanup)
unset ENV_LOADER_INITIALIZED
unset EDITOR VISUAL PAGER TERM COLORTERM NODE_VERSION PYTHON_VERSION GO_VERSION GIT_DEFAULT_BRANCH
unset TEST_SHELL HISTSIZE HISTFILESIZE HISTCONTROL CONFIG_DIR TEST_PLATFORM
unset DOCUMENTS_DIR TEST_QUOTED GOOD_PATH WELCOME_MESSAGE EMOJI_STATUS
unset DOCKER_HOST DATABASE_URL API_KEY

load_env_file "ABSOLUTE_ENV_PATH" 2>/dev/null

# Output test results
echo "SHELL:$current_shell"
echo "EDITOR:${EDITOR:-UNSET}"
echo "TEST_SHELL:${TEST_SHELL:-UNSET}"
echo "HISTSIZE:${HISTSIZE:-UNSET}"
echo "CONFIG_DIR:${CONFIG_DIR:-UNSET}"
echo "DOCUMENTS_DIR:${DOCUMENTS_DIR:-UNSET}"
echo "WELCOME_MESSAGE:${WELCOME_MESSAGE:-UNSET}"
EOF
}

# Create test script for zsh
create_zsh_test_script() {
    local test_script="$1"
    
    cat > "$test_script" << 'EOF'
#!/bin/zsh
# Zsh test script for bzsh loader

# Prevent auto-initialization during sourcing
export ENV_LOADER_INITIALIZED=true

# Source the bzsh loader (use absolute path)
LOADER_PATH="ABSOLUTE_LOADER_PATH"
source "$LOADER_PATH"

# Verify shell detection
current_shell=$(get_current_shell)
if [[ "$current_shell" != "ZSH" ]]; then
    print "ERROR: Expected ZSH, got $current_shell"
    exit 1
fi

# Clear variables and load .env (thorough cleanup)
unset ENV_LOADER_INITIALIZED
unset EDITOR VISUAL PAGER TERM COLORTERM NODE_VERSION PYTHON_VERSION GO_VERSION GIT_DEFAULT_BRANCH
unset TEST_SHELL HISTSIZE SAVEHIST HISTFILE CONFIG_DIR TEST_PLATFORM
unset DOCUMENTS_DIR TEST_QUOTED GOOD_PATH WELCOME_MESSAGE EMOJI_STATUS
unset DOCKER_HOST DATABASE_URL API_KEY

load_env_file "ABSOLUTE_ENV_PATH" 2>/dev/null

# Output test results
print "SHELL:$current_shell"
print "EDITOR:${EDITOR:-UNSET}"
print "TEST_SHELL:${TEST_SHELL:-UNSET}"
print "HISTSIZE:${HISTSIZE:-UNSET}"
print "SAVEHIST:${SAVEHIST:-UNSET}"
print "HISTFILE:${HISTFILE:-UNSET}"
print "CONFIG_DIR:${CONFIG_DIR:-UNSET}"
print "DOCUMENTS_DIR:${DOCUMENTS_DIR:-UNSET}"
print "WELCOME_MESSAGE:${WELCOME_MESSAGE:-UNSET}"
EOF
}

# Main test execution
main() {
    echo -e "${BLUE}Running Isolated Bash/Zsh Compatible Tests${NC}"
    echo "=============================================="
    
    # Create temporary test scripts
    local bash_test_script=$(mktemp)
    local zsh_test_script=$(mktemp)
    
    # Get absolute paths (resolve them properly)
    local loader_path="$(cd "$SCRIPT_DIR/../../src/shells/bzsh" && pwd)/loader.sh"
    local env_path="$(cd "$SCRIPT_DIR/../.." && pwd)/.env"

    create_bash_test_script "$bash_test_script"
    create_zsh_test_script "$zsh_test_script"

    # Replace placeholders with absolute paths
    sed -i "s|ABSOLUTE_LOADER_PATH|$loader_path|g" "$bash_test_script"
    sed -i "s|ABSOLUTE_ENV_PATH|$env_path|g" "$bash_test_script"
    sed -i "s|ABSOLUTE_LOADER_PATH|$loader_path|g" "$zsh_test_script"
    sed -i "s|ABSOLUTE_ENV_PATH|$env_path|g" "$zsh_test_script"
    
    chmod +x "$bash_test_script" "$zsh_test_script"
    
    local total_tests=0
    local passed_tests=0
    
    # Test Bash
    echo -e "\n${YELLOW}Testing Bash Mode:${NC}"
    if command -v bash >/dev/null 2>&1; then
        local bash_output
        bash_output=$(run_shell_tests bash "$bash_test_script")
        local bash_exit_code=$?
        
        if [ $bash_exit_code -eq 0 ]; then
            # Parse output and verify results
            local shell=$(echo "$bash_output" | grep "^SHELL:" | cut -d: -f2)
            local editor=$(echo "$bash_output" | grep "^EDITOR:" | cut -d: -f2)
            local test_shell=$(echo "$bash_output" | grep "^TEST_SHELL:" | cut -d: -f2)
            local histsize=$(echo "$bash_output" | grep "^HISTSIZE:" | cut -d: -f2)
            local config_dir=$(echo "$bash_output" | grep "^CONFIG_DIR:" | cut -d: -f2)
            local documents_dir=$(echo "$bash_output" | grep "^DOCUMENTS_DIR:" | cut -d: -f2)
            local welcome_msg=$(echo "$bash_output" | grep "^WELCOME_MESSAGE:" | cut -d: -f2-)
            
            # Verify results
            verify_test_result "BASH" "$shell" "Shell detection" && ((passed_tests++))
            verify_test_result "vim" "$editor" "EDITOR variable" && ((passed_tests++))
            verify_test_result "bash_detected" "$test_shell" "TEST_SHELL precedence" && ((passed_tests++))
            verify_test_result "10000" "$histsize" "HISTSIZE_BASH precedence" && ((passed_tests++))
            verify_test_result "~/.config/linux" "$config_dir" "CONFIG_DIR_LINUX precedence" && ((passed_tests++))
            verify_test_result "/home/user/Documents" "$documents_dir" "DOCUMENTS_DIR with quotes" && ((passed_tests++))
            verify_test_result "欢迎 Welcome Bienvenido" "$welcome_msg" "Unicode support" && ((passed_tests++))
            
            total_tests=$((total_tests + 7))
        else
            echo -e "${RED}❌ Bash test script failed to execute${NC}"
            total_tests=$((total_tests + 1))
        fi
    else
        echo "⚠️  Bash not available, skipping bash tests"
    fi
    
    # Test Zsh
    echo -e "\n${YELLOW}Testing Zsh Mode:${NC}"
    if command -v zsh >/dev/null 2>&1; then
        local zsh_output
        zsh_output=$(run_shell_tests zsh "$zsh_test_script")
        local zsh_exit_code=$?
        
        if [ $zsh_exit_code -eq 0 ]; then
            # Parse output and verify results
            local shell=$(echo "$zsh_output" | grep "^SHELL:" | cut -d: -f2)
            local editor=$(echo "$zsh_output" | grep "^EDITOR:" | cut -d: -f2)
            local test_shell=$(echo "$zsh_output" | grep "^TEST_SHELL:" | cut -d: -f2)
            local histsize=$(echo "$zsh_output" | grep "^HISTSIZE:" | cut -d: -f2)
            local savehist=$(echo "$zsh_output" | grep "^SAVEHIST:" | cut -d: -f2)
            local histfile=$(echo "$zsh_output" | grep "^HISTFILE:" | cut -d: -f2)
            local config_dir=$(echo "$zsh_output" | grep "^CONFIG_DIR:" | cut -d: -f2)
            local documents_dir=$(echo "$zsh_output" | grep "^DOCUMENTS_DIR:" | cut -d: -f2)
            local welcome_msg=$(echo "$zsh_output" | grep "^WELCOME_MESSAGE:" | cut -d: -f2-)
            
            # Verify results
            verify_test_result "ZSH" "$shell" "Shell detection" && ((passed_tests++))
            verify_test_result "vim" "$editor" "EDITOR variable" && ((passed_tests++))
            verify_test_result "zsh_detected" "$test_shell" "TEST_SHELL precedence" && ((passed_tests++))
            verify_test_result "50000" "$histsize" "HISTSIZE_ZSH precedence" && ((passed_tests++))
            verify_test_result "50000" "$savehist" "SAVEHIST_ZSH precedence" && ((passed_tests++))
            verify_test_result "~/.zsh_history" "$histfile" "HISTFILE_ZSH precedence" && ((passed_tests++))
            verify_test_result "~/.config/linux" "$config_dir" "CONFIG_DIR_LINUX precedence" && ((passed_tests++))
            verify_test_result "/home/user/Documents" "$documents_dir" "DOCUMENTS_DIR with quotes" && ((passed_tests++))
            verify_test_result "欢迎 Welcome Bienvenido" "$welcome_msg" "Unicode support" && ((passed_tests++))
            
            total_tests=$((total_tests + 9))
        else
            echo -e "${RED}❌ Zsh test script failed to execute${NC}"
            total_tests=$((total_tests + 1))
        fi
    else
        echo "⚠️  Zsh not available, skipping zsh tests"
    fi
    
    # Cleanup
    rm -f "$bash_test_script" "$zsh_test_script"
    
    # Summary
    echo -e "\n${BLUE}Test Summary:${NC}"
    echo "============="
    echo -e "Total tests: $total_tests"
    echo -e "${GREEN}Passed: $passed_tests${NC}"
    echo -e "${RED}Failed: $((total_tests - passed_tests))${NC}"
    
    if [ $passed_tests -eq $total_tests ]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}💥 Some tests failed.${NC}"
        exit 1
    fi
}

# Run main function
main "$@"
