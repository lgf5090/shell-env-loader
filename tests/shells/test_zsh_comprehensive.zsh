#!/bin/zsh
# Comprehensive Zsh Implementation Tests
# =======================================
# Test suite for every variable in .env file with proper precedence handling

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

# Source the zsh loader
source "$SCRIPT_DIR/../../src/shells/zsh/loader.zsh"

# Test helper functions
assert_env_var_set() {
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

assert_env_var_not_set() {
    local var_name="$1"
    local test_name="$2"
    
    ((TEST_COUNT++))
    
    # Get the variable value using zsh parameter expansion
    local actual_value="${(P)var_name}"
    
    if [[ -z "$actual_value" ]]; then
        print -P "${GREEN}✅ PASS${NC}: $test_name"
        ((PASS_COUNT++))
        return 0
    else
        print -P "${RED}❌ FAIL${NC}: $test_name"
        print -P "   Variable: ${YELLOW}$var_name${NC}"
        print -P "   Expected: ${YELLOW}not set${NC}"
        print -P "   Actual:   ${YELLOW}$actual_value${NC}"
        ((FAIL_COUNT++))
        return 1
    fi
}

# Test basic variables
test_basic_variables() {
    print "Testing basic variables..."
    
    assert_env_var_set "EDITOR" "vim" "EDITOR variable"
    assert_env_var_set "VISUAL" "vim" "VISUAL variable"
    assert_env_var_set "PAGER" "less" "PAGER variable"
    assert_env_var_set "TERM" "xterm-256color" "TERM variable"
    assert_env_var_set "COLORTERM" "truecolor" "COLORTERM variable"
    assert_env_var_set "NODE_VERSION" "18.17.0" "NODE_VERSION variable"
    assert_env_var_set "PYTHON_VERSION" "3.11.4" "PYTHON_VERSION variable"
    assert_env_var_set "GO_VERSION" "1.21.0" "GO_VERSION variable"
    assert_env_var_set "GIT_DEFAULT_BRANCH" "main" "GIT_DEFAULT_BRANCH variable"
}

# Test shell-specific variables (should only load ZSH variants)
test_shell_specific_variables() {
    print "Testing shell-specific variables..."
    
    # Should load ZSH-specific variables
    assert_env_var_set "TEST_SHELL" "zsh_detected" "TEST_SHELL_ZSH precedence"
    assert_env_var_set "HISTSIZE" "50000" "HISTSIZE_ZSH precedence"
    assert_env_var_set "SAVEHIST" "50000" "SAVEHIST_ZSH precedence"
    assert_env_var_set "HISTFILE" "~/.zsh_history" "HISTFILE_ZSH precedence"
}

# Test platform-specific variables
test_platform_specific_variables() {
    print "Testing platform-specific variables..."
    
    local platform
    platform=$(detect_platform)
    
    case "$platform" in
        WSL)
            assert_env_var_set "CONFIG_DIR" "~/.config/wsl" "CONFIG_DIR_WSL precedence on WSL"
            assert_env_var_not_set "CONFIG_DIR_LINUX" "CONFIG_DIR_LINUX filtered on WSL"
            assert_env_var_not_set "CONFIG_DIR_MACOS" "CONFIG_DIR_MACOS filtered on WSL"
            assert_env_var_not_set "CONFIG_DIR_WIN" "CONFIG_DIR_WIN filtered on WSL"
            ;;
        LINUX)
            assert_env_var_set "CONFIG_DIR" "~/.config/linux" "CONFIG_DIR_LINUX precedence on Linux"
            assert_env_var_set "TEST_PLATFORM" "unix_detected" "TEST_PLATFORM_UNIX on Linux"
            assert_env_var_not_set "CONFIG_DIR_WSL" "CONFIG_DIR_WSL filtered on Linux"
            assert_env_var_not_set "CONFIG_DIR_MACOS" "CONFIG_DIR_MACOS filtered on Linux"
            assert_env_var_not_set "CONFIG_DIR_WIN" "CONFIG_DIR_WIN filtered on Linux"
            ;;
        MACOS)
            assert_env_var_set "CONFIG_DIR" "~/Library/Application Support" "CONFIG_DIR_MACOS precedence on macOS"
            assert_env_var_not_set "CONFIG_DIR_LINUX" "CONFIG_DIR_LINUX filtered on macOS"
            assert_env_var_not_set "CONFIG_DIR_WSL" "CONFIG_DIR_WSL filtered on macOS"
            assert_env_var_not_set "CONFIG_DIR_WIN" "CONFIG_DIR_WIN filtered on macOS"
            ;;
        WIN)
            assert_env_var_set "CONFIG_DIR" "%APPDATA%" "CONFIG_DIR_WIN precedence on Windows"
            assert_env_var_not_set "CONFIG_DIR_LINUX" "CONFIG_DIR_LINUX filtered on Windows"
            assert_env_var_not_set "CONFIG_DIR_WSL" "CONFIG_DIR_WSL filtered on Windows"
            assert_env_var_not_set "CONFIG_DIR_MACOS" "CONFIG_DIR_MACOS filtered on Windows"
            ;;
        *)
            assert_env_var_set "CONFIG_DIR" "~/.config" "CONFIG_DIR generic fallback"
            ;;
    esac
}

# Test PATH handling
test_path_handling() {
    print "Testing PATH handling..."
    
    local platform
    platform=$(detect_platform)
    
    # Test that PATH contains expected additions
    case "$platform" in
        WSL)
            # Should contain WSL-specific paths
            if [[ "$PATH" == *"/mnt/c/Windows/System32"* ]]; then
                ((TEST_COUNT++))
                print -P "${GREEN}✅ PASS${NC}: PATH contains WSL-specific paths"
                ((PASS_COUNT++))
            else
                ((TEST_COUNT++))
                print -P "${RED}❌ FAIL${NC}: PATH contains WSL-specific paths"
                print -P "   PATH: ${YELLOW}$PATH${NC}"
                ((FAIL_COUNT++))
            fi
            ;;
        LINUX)
            # Should contain Linux-specific paths
            if [[ "$PATH" == *"/tmp/test_linux_path"* ]]; then
                ((TEST_COUNT++))
                print -P "${GREEN}✅ PASS${NC}: PATH contains Linux-specific test path"
                ((PASS_COUNT++))
            else
                ((TEST_COUNT++))
                print -P "${RED}❌ FAIL${NC}: PATH contains Linux-specific test path"
                print -P "   PATH: ${YELLOW}$PATH${NC}"
                ((FAIL_COUNT++))
            fi
            
            # Check that tildes are expanded (use original HOME, not test HOME)
            if [[ "$PATH" == *"$ORIGINAL_HOME/.local/bin"* ]]; then
                ((TEST_COUNT++))
                print -P "${GREEN}✅ PASS${NC}: PATH contains expanded tilde paths"
                ((PASS_COUNT++))
            else
                ((TEST_COUNT++))
                print -P "${RED}❌ FAIL${NC}: PATH contains expanded tilde paths"
                print -P "   PATH: ${YELLOW}$PATH${NC}"
                print -P "   Expected to contain: ${YELLOW}$ORIGINAL_HOME/.local/bin${NC}"
                ((FAIL_COUNT++))
            fi
            ;;
        MACOS)
            # Should contain macOS-specific paths
            if [[ "$PATH" == *"/opt/homebrew/bin"* ]]; then
                ((TEST_COUNT++))
                print -P "${GREEN}✅ PASS${NC}: PATH contains Homebrew paths"
                ((PASS_COUNT++))
            else
                ((TEST_COUNT++))
                print -P "${RED}❌ FAIL${NC}: PATH contains Homebrew paths"
                print -P "   PATH: ${YELLOW}$PATH${NC}"
                ((FAIL_COUNT++))
            fi
            ;;
    esac
}

# Test special character handling
test_special_characters() {
    print "Testing special character handling..."
    
    assert_env_var_set "DOCUMENTS_DIR" "/home/user/Documents" "DOCUMENTS_DIR with quotes"
    assert_env_var_set "TEST_QUOTED" "quoted value" "TEST_QUOTED with quotes"
    assert_env_var_set "GOOD_PATH" "/path/with spaces/file" "GOOD_PATH with spaces"
    assert_env_var_set "MESSAGE_WITH_QUOTES" 'Single quotes with "double" inside' "MESSAGE_WITH_QUOTES mixed quotes"
    assert_env_var_set "SQL_QUERY" "SELECT * FROM users WHERE name = 'John'" "SQL_QUERY with quotes"
    assert_env_var_set "SPECIAL_CHARS_TEST" "!@#\$%^&*()_+-=[]{}|;:,.<>?" "SPECIAL_CHARS_TEST special characters"
}

# Test Unicode and international characters
test_unicode_characters() {
    print "Testing Unicode and international characters..."
    
    assert_env_var_set "WELCOME_MESSAGE" "欢迎 Welcome Bienvenido" "WELCOME_MESSAGE Unicode"
    assert_env_var_set "EMOJI_STATUS" "✅ 🚀 💻" "EMOJI_STATUS emojis"
    assert_env_var_set "CURRENCY_SYMBOLS" "\$ € £ ¥ ₹" "CURRENCY_SYMBOLS Unicode symbols"
    assert_env_var_set "DOCUMENTS_INTL" "/home/用户/文档" "DOCUMENTS_INTL Unicode path"
    assert_env_var_set "PROJECTS_INTL" "/home/usuario/proyectos" "PROJECTS_INTL international path"
    assert_env_var_set "UNICODE_TEST" "αβγδε ñáéíóú çñü" "UNICODE_TEST various Unicode"
}

# Test application configurations
test_application_configs() {
    print "Testing application configurations..."
    
    assert_env_var_set "DOCKER_HOST" "unix:///var/run/docker.sock" "DOCKER_HOST variable"
    assert_env_var_set "COMPOSE_PROJECT_NAME" "myapp" "COMPOSE_PROJECT_NAME variable"
    assert_env_var_set "DATABASE_URL" "postgresql://localhost:5432/myapp_dev" "DATABASE_URL variable"
    assert_env_var_set "REDIS_URL" "redis://localhost:6379/0" "REDIS_URL variable"
    assert_env_var_set "MONGODB_URL" "mongodb://localhost:27017/myapp" "MONGODB_URL variable"
    assert_env_var_set "API_KEY" "sk-1234567890abcdef" "API_KEY variable"
    assert_env_var_set "JWT_SECRET" "super-secret-jwt-key-change-in-production" "JWT_SECRET variable"
    assert_env_var_set "GITHUB_TOKEN" "ghp_1234567890abcdef" "GITHUB_TOKEN variable"
}

# Run all tests
run_all_tests() {
    print -P "${BLUE}Running Comprehensive Zsh Implementation Tests...${NC}"
    print "================================================="
    
    # Save original environment
    ORIGINAL_HOME="$HOME"
    ORIGINAL_PWD="$PWD"
    ORIGINAL_PATH="$PATH"
    ORIGINAL_ENV_LOADER_DEBUG="$ENV_LOADER_DEBUG"
    
    # Enable debug mode for testing
    export ENV_LOADER_DEBUG=true
    
    # Clear the initialization flag to allow fresh loading
    unset ENV_LOADER_INITIALIZED

    # Clear any existing test variables that might interfere
    unset TEST_SHELL HISTSIZE SAVEHIST HISTFILE CONFIG_DIR

    # Load the .env file FIRST, before changing HOME
    print "Loading .env file..."
    # Load the specific .env file directly
    load_env_file "$SCRIPT_DIR/../../.env" 2>/dev/null
    
    # Run test suites
    test_basic_variables
    print
    test_shell_specific_variables
    print
    test_platform_specific_variables
    print
    test_path_handling
    print
    test_special_characters
    print
    test_unicode_characters
    print
    test_application_configs
    print
    
    # Restore original environment
    export HOME="$ORIGINAL_HOME"
    cd "$ORIGINAL_PWD"
    export PATH="$ORIGINAL_PATH"
    export ENV_LOADER_DEBUG="$ORIGINAL_ENV_LOADER_DEBUG"
    
    # Print summary
    print "Test Summary:"
    print "============="
    print -P "Total tests: $TEST_COUNT"
    print -P "${GREEN}Passed: $PASS_COUNT${NC}"
    print -P "${RED}Failed: $FAIL_COUNT${NC}"
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        print -P "${GREEN}All tests passed!${NC}"
        return 0
    else
        print -P "${RED}Some tests failed.${NC}"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${(%):-%x}" == "${(%):-%N}" ]]; then
    run_all_tests
fi
