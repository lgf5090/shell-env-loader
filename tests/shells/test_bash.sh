#!/bin/bash
# Bash Implementation Tests
# =========================
# Test suite for Bash-specific environment loader implementation

# Test framework setup
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the bash loader
. "$SCRIPT_DIR/../../src/shells/bash/loader.sh"

# Test helper functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        echo -e "   Expected: ${YELLOW}$expected${NC}"
        echo -e "   Actual:   ${YELLOW}$actual${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

assert_not_empty() {
    local actual="$1"
    local test_name="$2"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if [ -n "$actual" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        echo -e "   Expected: ${YELLOW}non-empty string${NC}"
        echo -e "   Actual:   ${YELLOW}empty string${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

assert_env_var_set() {
    local var_name="$1"
    local expected_value="$2"
    local test_name="$3"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    # Get the variable value using indirect expansion
    local actual_value
    eval "actual_value=\${$var_name:-}"
    
    if [ "$actual_value" = "$expected_value" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        echo -e "   Variable: ${YELLOW}$var_name${NC}"
        echo -e "   Expected: ${YELLOW}$expected_value${NC}"
        echo -e "   Actual:   ${YELLOW}$actual_value${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

# Setup test environment
setup_test_env() {
    # Create temporary test directory
    TEST_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'bash_test')
    export TEST_DIR
    
    # Save original environment
    ORIGINAL_HOME="$HOME"
    ORIGINAL_PWD="$PWD"
    ORIGINAL_ENV_LOADER_DEBUG="$ENV_LOADER_DEBUG"
    
    # Set test environment
    export HOME="$TEST_DIR/home"
    mkdir -p "$HOME/.cfgs"
    cd "$TEST_DIR"
    
    # Enable debug mode for testing
    export ENV_LOADER_DEBUG=true
}

# Cleanup test environment
cleanup_test_env() {
    # Restore original environment
    export HOME="$ORIGINAL_HOME"
    cd "$ORIGINAL_PWD"
    export ENV_LOADER_DEBUG="$ORIGINAL_ENV_LOADER_DEBUG"
    
    # Remove test directory
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}

# Test functions
test_set_environment_variable() {
    echo "Testing set_environment_variable function..."
    
    # Test valid variable setting
    if set_environment_variable "TEST_VAR" "test_value"; then
        assert_equals "0" "0" "set_environment_variable succeeds with valid input"
        assert_env_var_set "TEST_VAR" "test_value" "set_environment_variable sets correct value"
    else
        assert_equals "0" "1" "set_environment_variable succeeds with valid input"
    fi
    
    # Test invalid variable name
    if set_environment_variable "123INVALID" "value" 2>/dev/null; then
        assert_equals "1" "0" "set_environment_variable rejects invalid variable name"
    else
        assert_equals "1" "1" "set_environment_variable rejects invalid variable name"
    fi
    
    # Clean up test variables
    unset TEST_VAR
}

test_expand_environment_variables() {
    echo "Testing expand_environment_variables function..."
    
    # Set up test environment variable
    export TEST_EXPAND_VAR="expanded_value"
    
    local result
    
    # Test basic expansion
    result=$(expand_environment_variables "\$TEST_EXPAND_VAR")
    assert_equals "expanded_value" "$result" "expand_environment_variables expands basic variable"
    
    # Test expansion with text (using proper bash syntax)
    result=$(expand_environment_variables "prefix_\${TEST_EXPAND_VAR}_suffix")
    assert_equals "prefix_expanded_value_suffix" "$result" "expand_environment_variables expands variable with surrounding text"
    
    # Test no expansion needed
    result=$(expand_environment_variables "no_expansion_needed")
    assert_equals "no_expansion_needed" "$result" "expand_environment_variables leaves non-expandable text unchanged"
    
    # Clean up
    unset TEST_EXPAND_VAR
}

test_load_env_file() {
    echo "Testing load_env_file function..."
    
    # Create test .env file
    local test_file="$TEST_DIR/test.env"
    cat > "$test_file" << 'EOF'
# Test environment file
BASIC_VAR=basic_value
QUOTED_VAR="quoted value"
BASH_SPECIFIC_VAR_BASH=bash_value
BASH_SPECIFIC_VAR_ZSH=zsh_value
PLATFORM_VAR_LINUX=linux_value
PLATFORM_VAR_WIN=windows_value
EOF
    
    # Load the file
    load_env_file "$test_file" 2>/dev/null
    
    # Check that variables were set
    assert_env_var_set "BASIC_VAR" "basic_value" "load_env_file sets basic variable"
    assert_env_var_set "QUOTED_VAR" "quoted value" "load_env_file handles quoted values"
    
    # Check shell-specific precedence (should prefer BASH over ZSH)
    assert_env_var_set "BASH_SPECIFIC_VAR" "bash_value" "load_env_file applies shell precedence"
    
    # Check platform-specific precedence
    local platform
    platform=$(detect_platform)
    case "$platform" in
        LINUX|WSL)
            assert_env_var_set "PLATFORM_VAR" "linux_value" "load_env_file applies platform precedence"
            ;;
        *)
            # For other platforms, just check that some value was set
            assert_not_empty "${PLATFORM_VAR:-}" "load_env_file sets platform variable"
            ;;
    esac
    
    # Clean up test variables
    unset BASIC_VAR QUOTED_VAR BASH_SPECIFIC_VAR PLATFORM_VAR
}

test_load_env_variables() {
    echo "Testing load_env_variables function..."
    
    # Create hierarchy of test files
    echo "GLOBAL_VAR=global_value" > "$HOME/.env"
    echo "USER_VAR=user_value" > "$HOME/.cfgs/.env"
    echo "PROJECT_VAR=project_value" > "$TEST_DIR/.env"
    
    # Test loading with default hierarchy
    load_env_variables 2>/dev/null
    
    # Check that variables from all levels were loaded
    assert_env_var_set "GLOBAL_VAR" "global_value" "load_env_variables loads global variables"
    assert_env_var_set "USER_VAR" "user_value" "load_env_variables loads user variables"
    assert_env_var_set "PROJECT_VAR" "project_value" "load_env_variables loads project variables"
    
    # Clean up test variables
    unset GLOBAL_VAR USER_VAR PROJECT_VAR
}

test_precedence_resolution() {
    echo "Testing precedence resolution..."
    
    # Create test file with precedence conflicts
    local test_file="$TEST_DIR/precedence_test.env"
    cat > "$test_file" << 'EOF'
# Test precedence resolution
PRECEDENCE_VAR=generic_value
PRECEDENCE_VAR_BASH=bash_value
PRECEDENCE_VAR_ZSH=zsh_value
PRECEDENCE_VAR_LINUX=linux_value
PRECEDENCE_VAR_WIN=windows_value
EOF
    
    # Load the file
    load_env_file "$test_file" 2>/dev/null
    
    # Should prefer bash-specific value
    assert_env_var_set "PRECEDENCE_VAR" "bash_value" "precedence resolution prefers shell-specific value"
    
    # Clean up
    unset PRECEDENCE_VAR
}

test_special_characters() {
    echo "Testing special character handling..."
    
    # Create test file with special characters
    local test_file="$TEST_DIR/special_chars.env"
    cat > "$test_file" << 'EOF'
# Test special characters
SPACES_VAR="value with spaces"
QUOTES_VAR="value with \"quotes\""
UNICODE_VAR="Testing: αβγ 中文 🎉"
PATH_VAR="/usr/local/bin:/opt/bin"
EOF
    
    # Load the file
    load_env_file "$test_file" 2>/dev/null
    
    # Check special character handling
    assert_env_var_set "SPACES_VAR" "value with spaces" "handles spaces in values"
    assert_env_var_set "QUOTES_VAR" "value with \"quotes\"" "handles escaped quotes"
    assert_env_var_set "UNICODE_VAR" "Testing: αβγ 中文 🎉" "handles Unicode characters"
    assert_env_var_set "PATH_VAR" "/usr/local/bin:/opt/bin" "handles path-like values"
    
    # Clean up
    unset SPACES_VAR QUOTES_VAR UNICODE_VAR PATH_VAR
}

test_integration_functions() {
    echo "Testing integration functions..."
    
    # Test that key functions are available
    if command -v show_env_status >/dev/null 2>&1; then
        assert_equals "0" "0" "show_env_status function is available"
    else
        assert_equals "0" "1" "show_env_status function is available"
    fi
    
    if command -v reload_env_variables >/dev/null 2>&1; then
        assert_equals "0" "0" "reload_env_variables function is available"
    else
        assert_equals "0" "1" "reload_env_variables function is available"
    fi
    
    if command -v env_loader_debug_on >/dev/null 2>&1; then
        assert_equals "0" "0" "env_loader_debug_on function is available"
    else
        assert_equals "0" "1" "env_loader_debug_on function is available"
    fi
}

# Run all tests
run_all_tests() {
    echo -e "${BLUE}Running Bash Implementation Tests...${NC}"
    echo "====================================="
    
    # Setup test environment
    setup_test_env
    
    test_set_environment_variable
    echo
    test_expand_environment_variables
    echo
    test_load_env_file
    echo
    test_load_env_variables
    echo
    test_precedence_resolution
    echo
    test_special_characters
    echo
    test_integration_functions
    echo
    
    # Cleanup test environment
    cleanup_test_env
    
    # Print summary
    echo "Test Summary:"
    echo "============="
    echo -e "Total tests: $TEST_COUNT"
    echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
    echo -e "${RED}Failed: $FAIL_COUNT${NC}"
    
    if [ $FAIL_COUNT -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        return 1
    fi
}

# Run tests if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_all_tests
fi
