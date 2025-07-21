#!/bin/zsh
# Final ZSH Test - Test actual functionality with current .env files
# ==================================================================

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
SCRIPT_DIR="${0:A:h}"

# Test helper function
test_var() {
    local var_name="$1"
    local expected_value="$2"
    local test_name="$3"
    
    ((TEST_COUNT++))
    
    # Get the variable value using zsh parameter expansion
    local actual_value="${(P)var_name}"
    
    if [[ "$actual_value" == "$expected_value" ]]; then
        print -P "${GREEN}✅ PASS${NC}: $test_name"
        ((PASS_COUNT++))
        return 0
    else
        print -P "${RED}❌ FAIL${NC}: $test_name"
        print -P "   Variable: ${YELLOW}$var_name${NC}"
        print -P "   Expected: ${YELLOW}$expected_value${NC}"
        print -P "   Actual:   ${YELLOW}$actual_value${NC}"
        ((FAIL_COUNT++))
        return 1
    fi
}

test_var_exists() {
    local var_name="$1"
    local test_name="$2"
    
    ((TEST_COUNT++))
    
    # Get the variable value using zsh parameter expansion
    local actual_value="${(P)var_name}"
    
    if [[ -n "$actual_value" ]]; then
        print -P "${GREEN}✅ PASS${NC}: $test_name (value: $actual_value)"
        ((PASS_COUNT++))
        return 0
    else
        print -P "${RED}❌ FAIL${NC}: $test_name"
        print -P "   Variable: ${YELLOW}$var_name${NC} is not set"
        ((FAIL_COUNT++))
        return 1
    fi
}

test_path_contains() {
    local expected_path="$1"
    local test_name="$2"
    
    ((TEST_COUNT++))
    
    if [[ "$PATH" == *"$expected_path"* ]]; then
        print -P "${GREEN}✅ PASS${NC}: $test_name"
        ((PASS_COUNT++))
        return 0
    else
        print -P "${RED}❌ FAIL${NC}: $test_name"
        print -P "   Expected PATH to contain: ${YELLOW}$expected_path${NC}"
        ((FAIL_COUNT++))
        return 1
    fi
}

# Main test function
run_tests() {
    print -P "${BLUE}Running Final ZSH Tests - Testing actual functionality...${NC}"
    print "=========================================================="
    
    # Prevent auto-initialization
    export ENV_LOADER_INITIALIZED=true
    
    # Source the loader manually to avoid path issues
    COMMON_DIR="$SCRIPT_DIR/../../src/common"
    source "$COMMON_DIR/platform.sh"
    source "$COMMON_DIR/hierarchy.sh"
    source "$SCRIPT_DIR/../../src/shells/zsh/loader.zsh"
    
    # Clear the flag to allow loading
    unset ENV_LOADER_INITIALIZED
    
    # Load environment variables using the normal hierarchy
    load_env_variables
    
    # Get platform for platform-specific tests
    local platform=$(detect_platform)
    print "Detected platform: $platform"
    
    print
    print 'Testing basic environment variables...'
    test_var_exists 'EDITOR' 'EDITOR variable exists'
    test_var_exists 'VISUAL' 'VISUAL variable exists'
    test_var_exists 'TERM' 'TERM variable exists'
    test_var_exists 'COLORTERM' 'COLORTERM variable exists'
    
    print
    print 'Testing development environment variables...'
    test_var_exists 'NODE_VERSION' 'NODE_VERSION variable exists'
    test_var_exists 'PYTHON_VERSION' 'PYTHON_VERSION variable exists'
    test_var_exists 'GO_VERSION' 'GO_VERSION variable exists'
    test_var_exists 'DEV_HOME' 'DEV_HOME variable exists'
    test_var_exists 'PROJECTS_DIR' 'PROJECTS_DIR variable exists'
    test_var_exists 'WORKSPACE_DIR' 'WORKSPACE_DIR variable exists'
    
    print
    print 'Testing Git configuration...'
    test_var_exists 'GIT_EDITOR' 'GIT_EDITOR variable exists'
    test_var_exists 'GIT_PAGER' 'GIT_PAGER variable exists'
    test_var_exists 'GIT_DEFAULT_BRANCH' 'GIT_DEFAULT_BRANCH variable exists'
    
    print
    print 'Testing shell-specific variables (ZSH should be selected)...'
    test_var 'test_env_loader' 'zsh_env_loader' 'test_env_loader ZSH precedence'
    
    print
    print 'Testing platform-specific variables...'
    test_var_exists 'CONFIG_DIR' 'CONFIG_DIR variable exists'
    test_var_exists 'USER_HOME' 'USER_HOME variable exists'
    test_var_exists 'TEMP_DIR' 'TEMP_DIR variable exists'
    test_var_exists 'SYSTEM_BIN' 'SYSTEM_BIN variable exists'
    
    print
    print 'Testing PATH additions...'
    case "$platform" in
        WSL)
            test_path_contains '/mnt/c/Windows/System32' 'PATH contains WSL-specific paths'
            ;;
        LINUX)
            test_path_contains '/usr/local/bin' 'PATH contains Linux-specific paths'
            test_path_contains '/tmp/test_linux_path' 'PATH contains Linux test path'
            ;;
        MACOS)
            test_path_contains '/opt/homebrew/bin' 'PATH contains Homebrew paths'
            ;;
    esac
    
    print
    print 'Testing application configurations...'
    test_var_exists 'DOCKER_HOST' 'DOCKER_HOST variable exists'
    test_var_exists 'COMPOSE_PROJECT_NAME' 'COMPOSE_PROJECT_NAME variable exists'
    test_var_exists 'DATABASE_URL' 'DATABASE_URL variable exists'
    test_var_exists 'REDIS_URL' 'REDIS_URL variable exists'
    test_var_exists 'MONGODB_URL' 'MONGODB_URL variable exists'
    test_var_exists 'API_KEY' 'API_KEY variable exists'
    test_var_exists 'JWT_SECRET' 'JWT_SECRET variable exists'
    test_var_exists 'GITHUB_TOKEN' 'GITHUB_TOKEN variable exists'
    
    print
    print 'Testing special character handling...'
    test_var_exists 'PROGRAM_FILES' 'PROGRAM_FILES variable exists'
    test_var_exists 'PROGRAM_FILES_X86' 'PROGRAM_FILES_X86 variable exists'
    test_var_exists 'DOCUMENTS_DIR' 'DOCUMENTS_DIR variable exists'
    test_var_exists 'MESSAGE_WITH_QUOTES' 'MESSAGE_WITH_QUOTES variable exists'
    test_var_exists 'SQL_QUERY' 'SQL_QUERY variable exists'
    test_var_exists 'JSON_CONFIG' 'JSON_CONFIG variable exists'
    test_var_exists 'COMMAND_WITH_QUOTES' 'COMMAND_WITH_QUOTES variable exists'
    test_var_exists 'COMPLEX_MESSAGE' 'COMPLEX_MESSAGE variable exists'
    test_var_exists 'WINDOWS_PATH' 'WINDOWS_PATH variable exists'
    test_var_exists 'REGEX_PATTERN' 'REGEX_PATTERN variable exists'
    
    print
    print 'Testing Unicode and international characters...'
    test_var_exists 'WELCOME_MESSAGE' 'WELCOME_MESSAGE variable exists'
    test_var_exists 'EMOJI_STATUS' 'EMOJI_STATUS variable exists'
    test_var_exists 'CURRENCY_SYMBOLS' 'CURRENCY_SYMBOLS variable exists'
    test_var_exists 'DOCUMENTS_INTL' 'DOCUMENTS_INTL variable exists'
    test_var_exists 'PROJECTS_INTL' 'PROJECTS_INTL variable exists'
    test_var_exists 'UNICODE_TEST' 'UNICODE_TEST variable exists'
    
    print
    print 'Testing test variables...'
    test_var_exists 'TEST_BASIC' 'TEST_BASIC variable exists'
    test_var_exists 'TEST_QUOTED' 'TEST_QUOTED variable exists'
    test_var_exists 'TEST_PLATFORM' 'TEST_PLATFORM variable exists'
    test_var_exists 'SPECIAL_CHARS_TEST' 'SPECIAL_CHARS_TEST variable exists'
    test_var_exists 'PATH_TEST' 'PATH_TEST variable exists'
    
    print
    print 'Testing hierarchical loading examples...'
    test_var_exists 'PROJECT_TYPE' 'PROJECT_TYPE variable exists'
    test_var_exists 'DEBUG_LEVEL' 'DEBUG_LEVEL variable exists'
    test_var_exists 'LOG_LEVEL' 'LOG_LEVEL variable exists'
    test_var_exists 'ENVIRONMENT' 'ENVIRONMENT variable exists'
    test_var_exists 'HIERARCHY_TEST_GLOBAL' 'HIERARCHY_TEST_GLOBAL variable exists'
    
    print
    print 'Testing security considerations...'
    test_var_exists 'SECRET_KEY' 'SECRET_KEY variable exists'
    test_var_exists 'DATABASE_PASSWORD' 'DATABASE_PASSWORD variable exists'
    test_var_exists 'API_TOKEN' 'API_TOKEN variable exists'
    
    print
    print 'Testing performance and optimization settings...'
    test_var_exists 'JAVA_OPTS' 'JAVA_OPTS variable exists'
    test_var_exists 'PYTHON_OPTIMIZE' 'PYTHON_OPTIMIZE variable exists'
    
    print
    print 'Testing testing and debugging variables...'
    test_var_exists 'TEST_ENV' 'TEST_ENV variable exists'
    test_var_exists 'TESTING_MODE' 'TESTING_MODE variable exists'
    test_var_exists 'MOCK_EXTERNAL_APIS' 'MOCK_EXTERNAL_APIS variable exists'
    test_var_exists 'DEBUG' 'DEBUG variable exists'
    test_var_exists 'VERBOSE' 'VERBOSE variable exists'
    test_var_exists 'TRACE_ENABLED' 'TRACE_ENABLED variable exists'
    test_var_exists 'LOG_FORMAT' 'LOG_FORMAT variable exists'
    test_var_exists 'LOG_TIMESTAMP' 'LOG_TIMESTAMP variable exists'
    test_var_exists 'LOG_COLOR' 'LOG_COLOR variable exists'
    
    # Print summary
    print
    print '=========================================================='
    print 'Test Summary:'
    print '============='
    print -P "Total tests: $TEST_COUNT"
    print -P "${GREEN}Passed: $PASS_COUNT${NC}"
    print -P "${RED}Failed: $FAIL_COUNT${NC}"
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        print -P "${GREEN}🎉 ALL TESTS PASSED! ZSH loader is working correctly.${NC}"
        return 0
    else
        print -P "${RED}❌ Some tests failed. Please check the implementation.${NC}"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${(%):-%x}" == "${(%):-%N}" ]]; then
    run_tests
fi
