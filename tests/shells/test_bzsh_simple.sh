#!/bin/bash
# Simple Bash/Zsh Compatible Tests
# =================================
# Direct testing using clean shell environments

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running Simple Bash/Zsh Compatible Tests${NC}"
echo "=========================================="

# Test counters
total_tests=0
passed_tests=0

# Test function
test_result() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((total_tests++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✅ $test_name: PASS${NC}"
        ((passed_tests++))
    else
        echo -e "${RED}❌ $test_name: FAIL${NC} (expected: '$expected', got: '$actual')"
    fi
}

echo -e "\n${YELLOW}Testing Bash Mode:${NC}"
if command -v bash >/dev/null 2>&1; then
    # Test bash in clean environment
    bash_output=$(bash --noprofile --norc -c '
        export ENV_LOADER_INITIALIZED=true
        source src/shells/bzsh/loader.sh
        unset ENV_LOADER_INITIALIZED TEST_SHELL HISTSIZE HISTFILESIZE CONFIG_DIR EDITOR DOCUMENTS_DIR WELCOME_MESSAGE
        load_env_file .env 2>/dev/null
        
        echo "SHELL:$(get_current_shell)"
        echo "EDITOR:${EDITOR:-UNSET}"
        echo "TEST_SHELL:${TEST_SHELL:-UNSET}"
        echo "HISTSIZE:${HISTSIZE:-UNSET}"
        echo "HISTFILESIZE:${HISTFILESIZE:-UNSET}"
        echo "CONFIG_DIR:${CONFIG_DIR:-UNSET}"
        echo "DOCUMENTS_DIR:${DOCUMENTS_DIR:-UNSET}"
        echo "WELCOME_MESSAGE:${WELCOME_MESSAGE:-UNSET}"
    ')
    
    # Parse results
    shell=$(echo "$bash_output" | grep "^SHELL:" | cut -d: -f2)
    editor=$(echo "$bash_output" | grep "^EDITOR:" | cut -d: -f2)
    test_shell=$(echo "$bash_output" | grep "^TEST_SHELL:" | cut -d: -f2)
    histsize=$(echo "$bash_output" | grep "^HISTSIZE:" | cut -d: -f2)
    histfilesize=$(echo "$bash_output" | grep "^HISTFILESIZE:" | cut -d: -f2)
    config_dir=$(echo "$bash_output" | grep "^CONFIG_DIR:" | cut -d: -f2)
    documents_dir=$(echo "$bash_output" | grep "^DOCUMENTS_DIR:" | cut -d: -f2)
    welcome_msg=$(echo "$bash_output" | grep "^WELCOME_MESSAGE:" | cut -d: -f2-)
    
    # Verify results
    test_result "BASH" "$shell" "Bash shell detection"
    test_result "vim" "$editor" "Bash EDITOR variable"
    test_result "bash_detected" "$test_shell" "Bash TEST_SHELL precedence"
    test_result "10000" "$histsize" "Bash HISTSIZE precedence"
    test_result "20000" "$histfilesize" "Bash HISTFILESIZE precedence"
    test_result "~/.config/linux" "$config_dir" "Bash CONFIG_DIR precedence"
    test_result "/home/user/Documents" "$documents_dir" "Bash DOCUMENTS_DIR"
    test_result "欢迎 Welcome Bienvenido" "$welcome_msg" "Bash Unicode support"
else
    echo "⚠️  Bash not available"
fi

echo -e "\n${YELLOW}Testing Zsh Mode:${NC}"
if command -v zsh >/dev/null 2>&1; then
    # Test zsh in clean environment
    zsh_output=$(zsh --no-rcs --no-globalrcs -c '
        export ENV_LOADER_INITIALIZED=true
        source src/shells/bzsh/loader.sh
        unset ENV_LOADER_INITIALIZED TEST_SHELL HISTSIZE SAVEHIST HISTFILE CONFIG_DIR EDITOR DOCUMENTS_DIR WELCOME_MESSAGE
        load_env_file .env 2>/dev/null
        
        print "SHELL:$(get_current_shell)"
        print "EDITOR:${EDITOR:-UNSET}"
        print "TEST_SHELL:${TEST_SHELL:-UNSET}"
        print "HISTSIZE:${HISTSIZE:-UNSET}"
        print "SAVEHIST:${SAVEHIST:-UNSET}"
        print "HISTFILE:${HISTFILE:-UNSET}"
        print "CONFIG_DIR:${CONFIG_DIR:-UNSET}"
        print "DOCUMENTS_DIR:${DOCUMENTS_DIR:-UNSET}"
        print "WELCOME_MESSAGE:${WELCOME_MESSAGE:-UNSET}"
    ')
    
    # Parse results
    shell=$(echo "$zsh_output" | grep "^SHELL:" | cut -d: -f2)
    editor=$(echo "$zsh_output" | grep "^EDITOR:" | cut -d: -f2)
    test_shell=$(echo "$zsh_output" | grep "^TEST_SHELL:" | cut -d: -f2)
    histsize=$(echo "$zsh_output" | grep "^HISTSIZE:" | cut -d: -f2)
    savehist=$(echo "$zsh_output" | grep "^SAVEHIST:" | cut -d: -f2)
    histfile=$(echo "$zsh_output" | grep "^HISTFILE:" | cut -d: -f2)
    config_dir=$(echo "$zsh_output" | grep "^CONFIG_DIR:" | cut -d: -f2)
    documents_dir=$(echo "$zsh_output" | grep "^DOCUMENTS_DIR:" | cut -d: -f2)
    welcome_msg=$(echo "$zsh_output" | grep "^WELCOME_MESSAGE:" | cut -d: -f2-)
    
    # Verify results
    test_result "ZSH" "$shell" "Zsh shell detection"
    test_result "vim" "$editor" "Zsh EDITOR variable"
    test_result "zsh_detected" "$test_shell" "Zsh TEST_SHELL precedence"
    test_result "50000" "$histsize" "Zsh HISTSIZE precedence"
    test_result "50000" "$savehist" "Zsh SAVEHIST precedence"
    test_result "~/.zsh_history" "$histfile" "Zsh HISTFILE precedence"
    test_result "~/.config/linux" "$config_dir" "Zsh CONFIG_DIR precedence"
    test_result "/home/user/Documents" "$documents_dir" "Zsh DOCUMENTS_DIR"
    test_result "欢迎 Welcome Bienvenido" "$welcome_msg" "Zsh Unicode support"
else
    echo "⚠️  Zsh not available"
fi

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
