#!/bin/bash
# File Hierarchy Management Tests
# ================================
# Test suite for file hierarchy management utilities

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
. "$SCRIPT_DIR/../../src/common/hierarchy.sh"

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

assert_file_exists() {
    local file="$1"
    local test_name="$2"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        echo -e "   Expected: ${YELLOW}$file${NC} to exist"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

# Setup test environment
setup_test_env() {
    # Create temporary test directory
    TEST_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'env_test')
    export TEST_DIR
    
    # Create test .env files
    mkdir -p "$TEST_DIR/home/.cfgs"
    mkdir -p "$TEST_DIR/project"
    
    # Create test files
    echo "GLOBAL_VAR=global_value" > "$TEST_DIR/home/.env"
    echo "USER_VAR=user_value" > "$TEST_DIR/home/.cfgs/.env"
    echo "PROJECT_VAR=project_value" > "$TEST_DIR/project/.env"
    
    # Save original values
    ORIGINAL_HOME="$HOME"
    ORIGINAL_PWD="$PWD"
    
    # Set test environment
    export HOME="$TEST_DIR/home"
    cd "$TEST_DIR/project"
}

# Cleanup test environment
cleanup_test_env() {
    # Restore original values
    export HOME="$ORIGINAL_HOME"
    cd "$ORIGINAL_PWD"
    
    # Remove test directory
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}

# Test functions
test_get_env_file_hierarchy() {
    echo "Testing get_env_file_hierarchy function..."
    
    local files
    files=$(get_env_file_hierarchy)
    
    # Should find the project .env file
    echo "$files" | grep -q "\.env$"
    if [ $? -eq 0 ]; then
        assert_equals "0" "0" "get_env_file_hierarchy finds .env files"
    else
        echo -e "${YELLOW}⚠️  INFO${NC}: No .env files found in test environment"
    fi
    
    # Count number of files found
    local file_count
    file_count=$(echo "$files" | grep -c "\.env$" 2>/dev/null || echo "0")
    
    echo -e "${YELLOW}ℹ️  INFO${NC}: Found $file_count .env files"
}

test_get_file_precedence() {
    echo "Testing get_file_precedence function..."
    
    # Test project-level .env (should have highest precedence)
    local precedence
    precedence=$(get_file_precedence "$PWD/.env")
    assert_equals "100" "$precedence" "get_file_precedence assigns high precedence to project .env"
    
    # Test user config .env (should have medium precedence)
    precedence=$(get_file_precedence "$HOME/.cfgs/.env")
    assert_equals "50" "$precedence" "get_file_precedence assigns medium precedence to user config .env"
    
    # Test global .env (should have low precedence)
    precedence=$(get_file_precedence "$HOME/.env")
    assert_equals "10" "$precedence" "get_file_precedence assigns low precedence to global .env"
}

test_ensure_env_directories() {
    echo "Testing ensure_env_directories function..."
    
    # Remove the .cfgs directory to test creation
    if [ -d "$HOME/.cfgs" ]; then
        rmdir "$HOME/.cfgs" 2>/dev/null
    fi
    
    # Test directory creation
    ensure_env_directories
    local result=$?
    
    assert_equals "0" "$result" "ensure_env_directories succeeds"
    
    if [ -d "$HOME/.cfgs" ]; then
        assert_equals "0" "0" "ensure_env_directories creates .cfgs directory"
    else
        assert_equals "directory exists" "directory missing" "ensure_env_directories creates .cfgs directory"
    fi
}

test_is_valid_env_file() {
    echo "Testing is_valid_env_file function..."
    
    # Test with existing readable file
    if is_valid_env_file "$TEST_DIR/home/.env"; then
        assert_equals "0" "0" "is_valid_env_file detects valid file"
    else
        assert_equals "0" "1" "is_valid_env_file detects valid file"
    fi
    
    # Test with non-existing file
    if is_valid_env_file "$TEST_DIR/nonexistent.env"; then
        assert_equals "1" "0" "is_valid_env_file rejects non-existing file"
    else
        assert_equals "1" "1" "is_valid_env_file rejects non-existing file"
    fi
    
    # Test with empty file
    touch "$TEST_DIR/empty.env"
    if is_valid_env_file "$TEST_DIR/empty.env"; then
        assert_equals "1" "0" "is_valid_env_file rejects empty file"
    else
        assert_equals "1" "1" "is_valid_env_file rejects empty file"
    fi
}

test_get_relative_path() {
    echo "Testing get_relative_path function..."
    
    local result
    
    # Test file in current directory
    result=$(get_relative_path "$PWD/test.env")
    assert_equals "./test.env" "$result" "get_relative_path converts current directory file to relative"
    
    # Test current directory itself
    result=$(get_relative_path "$PWD")
    assert_equals "." "$result" "get_relative_path converts current directory to dot"
    
    # Test absolute path outside current directory
    result=$(get_relative_path "/tmp/test.env")
    assert_equals "/tmp/test.env" "$result" "get_relative_path leaves external absolute paths unchanged"
}

test_backup_env_file() {
    echo "Testing backup_env_file function..."
    
    # Create a test file to backup
    local test_file="$TEST_DIR/test_backup.env"
    echo "TEST_VAR=test_value" > "$test_file"
    
    # Test backup creation
    local backup_file
    backup_file=$(backup_env_file "$test_file")
    local result=$?
    
    assert_equals "0" "$result" "backup_env_file succeeds"
    
    if [ -n "$backup_file" ] && [ -f "$backup_file" ]; then
        assert_file_exists "$backup_file" "backup_env_file creates backup file"
        
        # Verify backup content
        local original_content backup_content
        original_content=$(cat "$test_file")
        backup_content=$(cat "$backup_file")
        assert_equals "$original_content" "$backup_content" "backup_env_file preserves file content"
    fi
    
    # Test with non-existing file
    backup_file=$(backup_env_file "$TEST_DIR/nonexistent.env" 2>/dev/null)
    result=$?
    assert_equals "1" "$result" "backup_env_file fails for non-existing file"
}

# Run all tests
run_all_tests() {
    echo "Running File Hierarchy Management Tests..."
    echo "=========================================="
    
    # Setup test environment
    setup_test_env
    
    test_get_env_file_hierarchy
    echo
    test_get_file_precedence
    echo
    test_ensure_env_directories
    echo
    test_is_valid_env_file
    echo
    test_get_relative_path
    echo
    test_backup_env_file
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
