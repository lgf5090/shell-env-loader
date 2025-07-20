#!/bin/bash
# Environment Variable Parser Tests
# ==================================
# Test suite for .env file parsing utilities

# Test framework setup
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Source the module under test
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../src/common/parser.sh"

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

assert_empty() {
    local actual="$1"
    local test_name="$2"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if [ -z "$actual" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        echo -e "   Expected: ${YELLOW}empty string${NC}"
        echo -e "   Actual:   ${YELLOW}$actual${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

# Setup test environment
setup_test_env() {
    # Create temporary test directory
    TEST_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'parser_test')
    export TEST_DIR
}

# Cleanup test environment
cleanup_test_env() {
    # Remove test directory
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}

# Test functions
test_is_valid_variable_name() {
    echo "Testing is_valid_variable_name function..."
    
    # Valid variable names
    if is_valid_variable_name "VALID_VAR"; then
        assert_equals "0" "0" "is_valid_variable_name accepts valid uppercase name"
    else
        assert_equals "0" "1" "is_valid_variable_name accepts valid uppercase name"
    fi
    
    if is_valid_variable_name "valid_var"; then
        assert_equals "0" "0" "is_valid_variable_name accepts valid lowercase name"
    else
        assert_equals "0" "1" "is_valid_variable_name accepts valid lowercase name"
    fi
    
    if is_valid_variable_name "_private_var"; then
        assert_equals "0" "0" "is_valid_variable_name accepts underscore prefix"
    else
        assert_equals "0" "1" "is_valid_variable_name accepts underscore prefix"
    fi
    
    if is_valid_variable_name "VAR123"; then
        assert_equals "0" "0" "is_valid_variable_name accepts numbers in name"
    else
        assert_equals "0" "1" "is_valid_variable_name accepts numbers in name"
    fi
    
    # Invalid variable names
    if is_valid_variable_name "123VAR"; then
        assert_equals "1" "0" "is_valid_variable_name rejects name starting with number"
    else
        assert_equals "1" "1" "is_valid_variable_name rejects name starting with number"
    fi
    
    if is_valid_variable_name "VAR-NAME"; then
        assert_equals "1" "0" "is_valid_variable_name rejects name with hyphen"
    else
        assert_equals "1" "1" "is_valid_variable_name rejects name with hyphen"
    fi
    
    if is_valid_variable_name ""; then
        assert_equals "1" "0" "is_valid_variable_name rejects empty name"
    else
        assert_equals "1" "1" "is_valid_variable_name rejects empty name"
    fi
}

test_process_env_value() {
    echo "Testing process_env_value function..."
    
    # Unquoted values
    local result
    result=$(process_env_value "simple_value")
    assert_equals "simple_value" "$result" "process_env_value handles unquoted value"
    
    result=$(process_env_value "  spaced_value  ")
    assert_equals "spaced_value" "$result" "process_env_value trims whitespace from unquoted value"
    
    # Double-quoted values
    result=$(process_env_value '"double_quoted"')
    assert_equals "double_quoted" "$result" "process_env_value handles double-quoted value"
    
    result=$(process_env_value '"value with spaces"')
    assert_equals "value with spaces" "$result" "process_env_value preserves spaces in double quotes"
    
    # Single-quoted values
    result=$(process_env_value "'single_quoted'")
    assert_equals "single_quoted" "$result" "process_env_value handles single-quoted value"
    
    result=$(process_env_value "'value with spaces'")
    assert_equals "value with spaces" "$result" "process_env_value preserves spaces in single quotes"
}

test_process_double_quoted_value() {
    echo "Testing process_double_quoted_value function..."
    
    local result
    
    # Basic escape sequences
    result=$(process_double_quoted_value 'simple value')
    assert_equals "simple value" "$result" "process_double_quoted_value handles simple value"
    
    result=$(process_double_quoted_value 'value with \\n newline')
    assert_equals "value with \n newline" "$result" "process_double_quoted_value handles \\n escape"
    
    result=$(process_double_quoted_value 'value with \\t tab')
    assert_equals "value with \t tab" "$result" "process_double_quoted_value handles \\t escape"
    
    result=$(process_double_quoted_value 'value with \\" quote')
    assert_equals 'value with " quote' "$result" "process_double_quoted_value handles \\\" escape"
    
    result=$(process_double_quoted_value 'value with \\\\ backslash')
    assert_equals 'value with \\ backslash' "$result" "process_double_quoted_value handles \\\\ escape"
}

test_parse_env_line() {
    echo "Testing parse_env_line function..."
    
    local result
    
    # Valid key-value pairs
    result=$(parse_env_line "KEY=value" 1 "test.env")
    assert_equals "KEY=value" "$result" "parse_env_line handles basic key-value pair"
    
    result=$(parse_env_line "QUOTED_VALUE=\"quoted value\"" 1 "test.env")
    assert_equals "QUOTED_VALUE=quoted value" "$result" "parse_env_line handles quoted value"
    
    result=$(parse_env_line "  SPACED_KEY=spaced_value  " 1 "test.env")
    assert_equals "SPACED_KEY=spaced_value" "$result" "parse_env_line trims whitespace"
    
    # Comments and empty lines
    result=$(parse_env_line "# This is a comment" 1 "test.env")
    assert_empty "$result" "parse_env_line ignores comments"
    
    result=$(parse_env_line "" 1 "test.env")
    assert_empty "$result" "parse_env_line ignores empty lines"
    
    result=$(parse_env_line "   " 1 "test.env")
    assert_empty "$result" "parse_env_line ignores whitespace-only lines"
}

test_parse_env_file() {
    echo "Testing parse_env_file function..."
    
    # Create test file
    local test_file="$TEST_DIR/test.env"
    cat > "$test_file" << 'EOF'
# Test environment file
BASIC_VAR=basic_value
QUOTED_VAR="quoted value"
SINGLE_QUOTED='single quoted'

# Another comment
EMPTY_VAR=
NUMBER_VAR=123
EOF
    
    local result
    result=$(parse_env_file "$test_file")
    
    # Check that we get expected variables
    echo "$result" | grep -q "BASIC_VAR=basic_value"
    if [ $? -eq 0 ]; then
        assert_equals "0" "0" "parse_env_file finds BASIC_VAR"
    else
        assert_equals "found" "not found" "parse_env_file finds BASIC_VAR"
    fi
    
    echo "$result" | grep -q "QUOTED_VAR=quoted value"
    if [ $? -eq 0 ]; then
        assert_equals "0" "0" "parse_env_file processes quoted values"
    else
        assert_equals "found" "not found" "parse_env_file processes quoted values"
    fi
    
    # Check that comments are ignored
    echo "$result" | grep -q "# Test environment file"
    if [ $? -eq 0 ]; then
        assert_equals "not found" "found" "parse_env_file ignores comments"
    else
        assert_equals "0" "0" "parse_env_file ignores comments"
    fi
}

test_get_variable_precedence() {
    echo "Testing get_variable_precedence function..."
    
    local score
    
    # Test shell-specific variables
    score=$(get_variable_precedence "EDITOR_BASH" "BASH" "LINUX")
    assert_equals "100" "$score" "get_variable_precedence gives high score to matching shell suffix"
    
    score=$(get_variable_precedence "EDITOR_ZSH" "BASH" "LINUX")
    assert_equals "0" "$score" "get_variable_precedence gives zero score to non-matching shell suffix"
    
    # Test platform-specific variables
    score=$(get_variable_precedence "PATH_LINUX" "BASH" "LINUX")
    assert_equals "50" "$score" "get_variable_precedence gives medium score to matching platform suffix"
    
    score=$(get_variable_precedence "PATH_WIN" "BASH" "LINUX")
    assert_equals "0" "$score" "get_variable_precedence gives zero score to non-matching platform suffix"
    
    # Test generic variables
    score=$(get_variable_precedence "EDITOR" "BASH" "LINUX")
    assert_equals "10" "$score" "get_variable_precedence gives low score to generic variables"
}

test_extract_base_names() {
    echo "Testing extract_base_names function..."
    
    local variables="EDITOR=vim
EDITOR_BASH=nano
EDITOR_ZSH=emacs
PATH_LINUX=/usr/bin
PATH_WIN=C:\\bin
DEBUG=true"
    
    local result
    result=$(extract_base_names "$variables")
    
    # Check that base names are extracted correctly
    echo "$result" | grep -q "EDITOR"
    if [ $? -eq 0 ]; then
        assert_equals "0" "0" "extract_base_names finds EDITOR base name"
    else
        assert_equals "found" "not found" "extract_base_names finds EDITOR base name"
    fi
    
    echo "$result" | grep -q "PATH"
    if [ $? -eq 0 ]; then
        assert_equals "0" "0" "extract_base_names finds PATH base name"
    else
        assert_equals "found" "not found" "extract_base_names finds PATH base name"
    fi
    
    echo "$result" | grep -q "DEBUG"
    if [ $? -eq 0 ]; then
        assert_equals "0" "0" "extract_base_names finds DEBUG base name"
    else
        assert_equals "found" "not found" "extract_base_names finds DEBUG base name"
    fi
}

# Run all tests
run_all_tests() {
    echo "Running Environment Variable Parser Tests..."
    echo "============================================"
    
    # Setup test environment
    setup_test_env
    
    test_is_valid_variable_name
    echo
    test_process_env_value
    echo
    test_process_double_quoted_value
    echo
    test_parse_env_line
    echo
    test_parse_env_file
    echo
    test_get_variable_precedence
    echo
    test_extract_base_names
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
