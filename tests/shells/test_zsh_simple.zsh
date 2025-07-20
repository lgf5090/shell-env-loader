#!/bin/zsh
# Simple Zsh Test - Direct approach without complex framework
# ===========================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="${0:A:h}"

# Test counters
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Test function
test_var() {
    local var_name="$1"
    local expected="$2"
    local test_name="$3"
    
    ((TEST_COUNT++))
    
    # Get actual value
    local actual="${(P)var_name}"
    
    if [[ "$actual" == "$expected" ]]; then
        print -P "${GREEN}✅ PASS${NC}: $test_name"
        ((PASS_COUNT++))
    else
        print -P "${RED}❌ FAIL${NC}: $test_name"
        print -P "   Variable: ${YELLOW}$var_name${NC}"
        print -P "   Expected: ${YELLOW}$expected${NC}"
        print -P "   Actual:   ${YELLOW}$actual${NC}"
        ((FAIL_COUNT++))
    fi
}

# Main test
print -P "${BLUE}Running Simple Zsh Test...${NC}"
print "=========================="

# Source the loader
source "$SCRIPT_DIR/../../src/shells/zsh/loader.zsh"

# Clear variables
unset ENV_LOADER_INITIALIZED
unset TEST_SHELL HISTSIZE SAVEHIST HISTFILE CONFIG_DIR EDITOR VISUAL PAGER
unset TERM COLORTERM NODE_VERSION PYTHON_VERSION GO_VERSION GIT_DEFAULT_BRANCH

# Load .env file
print "Loading .env file..."
load_env_file "$SCRIPT_DIR/../../.env" 2>/dev/null

print "Running tests..."

# Test basic variables
test_var "EDITOR" "vim" "EDITOR variable"
test_var "VISUAL" "vim" "VISUAL variable"
test_var "PAGER" "less" "PAGER variable"
test_var "TERM" "xterm-256color" "TERM variable"
test_var "COLORTERM" "truecolor" "COLORTERM variable"

# Test shell-specific variables
test_var "TEST_SHELL" "zsh_detected" "TEST_SHELL_ZSH precedence"
test_var "HISTSIZE" "50000" "HISTSIZE_ZSH precedence"
test_var "SAVEHIST" "50000" "SAVEHIST_ZSH precedence"
test_var "HISTFILE" "~/.zsh_history" "HISTFILE_ZSH precedence"

# Test platform-specific variables
local platform
platform=$(detect_platform)
case "$platform" in
    LINUX)
        test_var "CONFIG_DIR" "~/.config/linux" "CONFIG_DIR_LINUX precedence"
        test_var "TEST_PLATFORM" "unix_detected" "TEST_PLATFORM_UNIX"
        ;;
    *)
        test_var "CONFIG_DIR" "~/.config" "CONFIG_DIR generic"
        ;;
esac

# Test a few more variables
test_var "NODE_VERSION" "18.17.0" "NODE_VERSION variable"
test_var "PYTHON_VERSION" "3.11.4" "PYTHON_VERSION variable"
test_var "GO_VERSION" "1.21.0" "GO_VERSION variable"
test_var "GIT_DEFAULT_BRANCH" "main" "GIT_DEFAULT_BRANCH variable"

# Test special characters
test_var "DOCUMENTS_DIR" "/home/user/Documents" "DOCUMENTS_DIR with quotes"
test_var "TEST_QUOTED" "quoted value" "TEST_QUOTED with quotes"

# Test Unicode
test_var "WELCOME_MESSAGE" "欢迎 Welcome Bienvenido" "WELCOME_MESSAGE Unicode"
test_var "EMOJI_STATUS" "✅ 🚀 💻" "EMOJI_STATUS emojis"

# Test application configs
test_var "DOCKER_HOST" "unix:///var/run/docker.sock" "DOCKER_HOST variable"
test_var "DATABASE_URL" "postgresql://localhost:5432/myapp_dev" "DATABASE_URL variable"

# Print summary
print
print "Test Summary:"
print "============="
print -P "Total tests: $TEST_COUNT"
print -P "${GREEN}Passed: $PASS_COUNT${NC}"
print -P "${RED}Failed: $FAIL_COUNT${NC}"

if [[ $FAIL_COUNT -eq 0 ]]; then
    print -P "${GREEN}All tests passed!${NC}"
    exit 0
else
    print -P "${RED}Some tests failed.${NC}"
    exit 1
fi
