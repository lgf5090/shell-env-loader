#!/bin/bash
# Platform Detection Tests
# =========================
# Test suite for platform detection utilities

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
. "$SCRIPT_DIR/../../src/common/platform.sh"

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

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    case "$haystack" in
        *"$needle"*)
            echo -e "${GREEN}✅ PASS${NC}: $test_name"
            PASS_COUNT=$((PASS_COUNT + 1))
            return 0
            ;;
        *)
            echo -e "${RED}❌ FAIL${NC}: $test_name"
            echo -e "   Expected: ${YELLOW}$haystack${NC} to contain ${YELLOW}$needle${NC}"
            FAIL_COUNT=$((FAIL_COUNT + 1))
            return 1
            ;;
    esac
}

# Test functions
test_detect_platform() {
    echo "Testing detect_platform function..."
    
    local platform
    platform=$(detect_platform)
    
    # Platform should be one of the expected values
    case "$platform" in
        LINUX|MACOS|WIN|UNIX|WSL)
            assert_not_empty "$platform" "detect_platform returns valid platform"
            ;;
        *)
            assert_equals "LINUX|MACOS|WIN|UNIX|WSL" "$platform" "detect_platform returns valid platform"
            ;;
    esac
}

test_detect_shell() {
    echo "Testing detect_shell function..."
    
    local shell
    shell=$(detect_shell)
    
    # Shell should be detected (may be UNKNOWN in some environments)
    assert_not_empty "$shell" "detect_shell returns non-empty result"
    
    # Should be one of the expected values
    case "$shell" in
        BASH|ZSH|FISH|NU|PS|UNKNOWN)
            assert_not_empty "$shell" "detect_shell returns valid shell type"
            ;;
        *)
            echo -e "${YELLOW}⚠️  WARNING${NC}: Unexpected shell type: $shell"
            ;;
    esac
}

test_get_platform_suffixes() {
    echo "Testing get_platform_suffixes function..."
    
    local suffixes
    suffixes=$(get_platform_suffixes)
    
    # Should return some suffixes for most platforms
    assert_not_empty "$suffixes" "get_platform_suffixes returns suffixes"
    
    # Should contain underscores (suffix format)
    case "$suffixes" in
        *"_"*)
            assert_contains "$suffixes" "_" "get_platform_suffixes returns underscore-prefixed suffixes"
            ;;
        "")
            # Empty is acceptable for unknown platforms
            echo -e "${YELLOW}⚠️  INFO${NC}: No platform suffixes (unknown platform)"
            ;;
        *)
            echo -e "${YELLOW}⚠️  WARNING${NC}: Unexpected suffix format: $suffixes"
            ;;
    esac
}

test_get_shell_suffix() {
    echo "Testing get_shell_suffix function..."
    
    local suffix
    suffix=$(get_shell_suffix)
    
    # Should return a suffix for known shells
    case "$(detect_shell)" in
        BASH|ZSH|FISH|NU|PS)
            assert_not_empty "$suffix" "get_shell_suffix returns suffix for known shell"
            assert_contains "$suffix" "_" "get_shell_suffix returns underscore-prefixed suffix"
            ;;
        UNKNOWN)
            # Empty suffix is acceptable for unknown shells
            echo -e "${YELLOW}⚠️  INFO${NC}: No shell suffix (unknown shell)"
            ;;
    esac
}

test_command_exists() {
    echo "Testing command_exists function..."
    
    # Test with a command that should exist
    if command_exists "echo"; then
        assert_equals "0" "0" "command_exists detects existing command (echo)"
    else
        assert_equals "0" "1" "command_exists detects existing command (echo)"
    fi
    
    # Test with a command that should not exist
    if command_exists "this_command_should_not_exist_12345"; then
        assert_equals "1" "0" "command_exists rejects non-existing command"
    else
        assert_equals "1" "1" "command_exists rejects non-existing command"
    fi
}

test_get_cpu_count() {
    echo "Testing get_cpu_count function..."
    
    local cpu_count
    cpu_count=$(get_cpu_count)
    
    # Should return a positive number
    assert_not_empty "$cpu_count" "get_cpu_count returns non-empty result"
    
    # Should be a number
    case "$cpu_count" in
        ''|*[!0-9]*)
            assert_equals "number" "$cpu_count" "get_cpu_count returns numeric value"
            ;;
        *)
            assert_not_empty "$cpu_count" "get_cpu_count returns numeric value"
            ;;
    esac
}

test_normalize_path() {
    echo "Testing normalize_path function..."
    
    local platform
    platform=$(detect_platform)
    
    case "$platform" in
        WIN)
            # On Windows, forward slashes should become backslashes
            local result
            result=$(normalize_path "path/to/file")
            assert_equals "path\\to\\file" "$result" "normalize_path converts forward slashes on Windows"
            ;;
        *)
            # On Unix-like systems, backslashes should become forward slashes
            local result
            result=$(normalize_path "path\\to\\file")
            assert_equals "path/to/file" "$result" "normalize_path converts backslashes on Unix-like systems"
            ;;
    esac
}

test_expand_tilde() {
    echo "Testing expand_tilde function..."
    
    # Test tilde expansion
    local result
    result=$(expand_tilde "~")
    assert_equals "$HOME" "$result" "expand_tilde expands ~ to HOME"
    
    result=$(expand_tilde "~/test")
    assert_equals "$HOME/test" "$result" "expand_tilde expands ~/path"
    
    result=$(expand_tilde "/absolute/path")
    assert_equals "/absolute/path" "$result" "expand_tilde leaves absolute paths unchanged"
    
    result=$(expand_tilde "relative/path")
    assert_equals "relative/path" "$result" "expand_tilde leaves relative paths unchanged"
}

# Run all tests
run_all_tests() {
    echo "Running Platform Detection Tests..."
    echo "=================================="
    
    test_detect_platform
    echo
    test_detect_shell
    echo
    test_get_platform_suffixes
    echo
    test_get_shell_suffix
    echo
    test_command_exists
    echo
    test_get_cpu_count
    echo
    test_normalize_path
    echo
    test_expand_tilde
    echo
    
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
