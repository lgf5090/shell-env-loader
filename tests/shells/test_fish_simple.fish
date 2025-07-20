#!/usr/bin/env fish
# Simple Fish Shell Tests
# ========================
# Basic functionality test for Fish shell implementation

# Colors for output
set RED '\033[0;31m'
set GREEN '\033[0;32m'
set YELLOW '\033[1;33m'
set BLUE '\033[0;34m'
set NC '\033[0m' # No Color

echo -e "$BLUE"'Running Simple Fish Shell Tests'"$NC"
echo "================================="

# Test counters
set total_tests 0
set passed_tests 0

# Test function
function test_var
    set -l expected $argv[1]
    set -l actual $argv[2]
    set -l test_name $argv[3]
    
    set total_tests (math $total_tests + 1)
    
    if test "$expected" = "$actual"
        echo -e "$GREEN"'✅ '"$test_name"': PASS'"$NC"
        set passed_tests (math $passed_tests + 1)
    else
        echo -e "$RED"'❌ '"$test_name"': FAIL'"$NC"' (expected: '"'$expected'"', got: '"'$actual'"')'
    end
end

# Get platform for platform-specific tests
function get_platform
    set -l uname_s (uname -s 2>/dev/null; or echo 'Unknown')
    switch $uname_s
        case 'Linux*'
            if test -f /proc/version; and grep -qi microsoft /proc/version 2>/dev/null
                echo "WSL"
            else
                echo "LINUX"
            end
        case 'Darwin*'
            echo "MACOS"
        case 'CYGWIN*' 'MINGW*' 'MSYS*'
            echo "WIN"
        case '*'
            echo "UNIX"
    end
end

set PLATFORM (get_platform)

echo -e "\n$YELLOW"'Testing Fish Mode:'"$NC"

# Test fish in clean environment using .env.example
fish --no-config -c '
    # Source the simplified fish loader
    source src/shells/fish/loader_simple.fish
    
    # Clear variables
    set -e EDITOR VISUAL PAGER TERM COLORTERM TEST_SHELL CONFIG_DIR
    set -e NODE_VERSION GIT_DEFAULT_BRANCH API_KEY DATABASE_URL
    set -e DOCUMENTS_DIR WELCOME_MESSAGE TEST_BASIC TEST_QUOTED
    set -e SPECIAL_CHARS_TEST UNICODE_TEST
    
    load_env_file_simple .env.example 2>/dev/null
    
    # Output test results to a file for parsing
    echo "SHELL:"(detect_shell) > /tmp/fish_results.txt
    echo "EDITOR:"(test -n "$EDITOR"; and echo "$EDITOR"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "VISUAL:"(test -n "$VISUAL"; and echo "$VISUAL"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "PAGER:"(test -n "$PAGER"; and echo "$PAGER"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "TERM:"(test -n "$TERM"; and echo "$TERM"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "COLORTERM:"(test -n "$COLORTERM"; and echo "$COLORTERM"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "CONFIG_DIR:"(test -n "$CONFIG_DIR"; and echo "$CONFIG_DIR"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "NODE_VERSION:"(test -n "$NODE_VERSION"; and echo "$NODE_VERSION"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "GIT_DEFAULT_BRANCH:"(test -n "$GIT_DEFAULT_BRANCH"; and echo "$GIT_DEFAULT_BRANCH"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "API_KEY:"(test -n "$API_KEY"; and echo "$API_KEY"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "DATABASE_URL:"(test -n "$DATABASE_URL"; and echo "$DATABASE_URL"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "DOCUMENTS_DIR:"(test -n "$DOCUMENTS_DIR"; and echo "$DOCUMENTS_DIR"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "WELCOME_MESSAGE:"(test -n "$WELCOME_MESSAGE"; and echo "$WELCOME_MESSAGE"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "TEST_BASIC:"(test -n "$TEST_BASIC"; and echo "$TEST_BASIC"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "TEST_QUOTED:"(test -n "$TEST_QUOTED"; and echo "$TEST_QUOTED"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "TEST_SHELL:"(test -n "$TEST_SHELL"; and echo "$TEST_SHELL"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "SPECIAL_CHARS_TEST:"(test -n "$SPECIAL_CHARS_TEST"; and echo "$SPECIAL_CHARS_TEST"; or echo "UNSET") >> /tmp/fish_results.txt
    echo "UNICODE_TEST:"(test -n "$UNICODE_TEST"; and echo "$UNICODE_TEST"; or echo "UNSET") >> /tmp/fish_results.txt
'

# Parse results and test
set shell (grep "^SHELL:" /tmp/fish_results.txt | cut -d: -f2)
test_var "FISH" "$shell" "Fish shell detection"

set editor (grep "^EDITOR:" /tmp/fish_results.txt | cut -d: -f2)
test_var "vim" "$editor" "EDITOR variable"

set visual (grep "^VISUAL:" /tmp/fish_results.txt | cut -d: -f2)
test_var "vim" "$visual" "VISUAL variable"

set pager (grep "^PAGER:" /tmp/fish_results.txt | cut -d: -f2)
test_var "less" "$pager" "PAGER variable"

set term (grep "^TERM:" /tmp/fish_results.txt | cut -d: -f2)
test_var "xterm-256color" "$term" "TERM variable"

set colorterm (grep "^COLORTERM:" /tmp/fish_results.txt | cut -d: -f2)
test_var "truecolor" "$colorterm" "COLORTERM variable"

# Platform-specific variables
set config_dir (grep "^CONFIG_DIR:" /tmp/fish_results.txt | cut -d: -f2)
switch $PLATFORM
    case LINUX
        test_var "/home/$USER/.config/linux" "$config_dir" "CONFIG_DIR_LINUX precedence (expanded)"
    case '*'
        test_var "/home/$USER/.config" "$config_dir" "CONFIG_DIR generic fallback (expanded)"
end

# Development environment
set node_version (grep "^NODE_VERSION:" /tmp/fish_results.txt | cut -d: -f2)
test_var "18.17.0" "$node_version" "NODE_VERSION variable"

set git_default_branch (grep "^GIT_DEFAULT_BRANCH:" /tmp/fish_results.txt | cut -d: -f2)
test_var "main" "$git_default_branch" "GIT_DEFAULT_BRANCH variable"

# Application configs
set api_key (grep "^API_KEY:" /tmp/fish_results.txt | cut -d: -f2)
test_var "your_api_key_here" "$api_key" "API_KEY variable"

set database_url (grep "^DATABASE_URL:" /tmp/fish_results.txt | cut -d: -f2-)
test_var "postgresql://localhost:5432/mydb" "$database_url" "DATABASE_URL variable"

# Special characters
set documents_dir (grep "^DOCUMENTS_DIR:" /tmp/fish_results.txt | cut -d: -f2-)
test_var "\"/home/$USER/Documents/My Projects\"" "$documents_dir" "DOCUMENTS_DIR variable (with quotes)"

set welcome_message (grep "^WELCOME_MESSAGE:" /tmp/fish_results.txt | cut -d: -f2-)
test_var "\"Welcome! 欢迎! Bienvenidos! Добро пожаловать!\"" "$welcome_message" "WELCOME_MESSAGE variable (with quotes)"

# Test variables
set test_basic (grep "^TEST_BASIC:" /tmp/fish_results.txt | cut -d: -f2)
test_var "basic_value_works" "$test_basic" "TEST_BASIC variable"

set test_quoted (grep "^TEST_QUOTED:" /tmp/fish_results.txt | cut -d: -f2-)
test_var "\"value with spaces works\"" "$test_quoted" "TEST_QUOTED variable (with quotes)"

set test_shell (grep "^TEST_SHELL:" /tmp/fish_results.txt | cut -d: -f2)
test_var "fish_detected" "$test_shell" "TEST_SHELL variable (fish precedence)"

set special_chars_test (grep "^SPECIAL_CHARS_TEST:" /tmp/fish_results.txt | cut -d: -f2-)
test_var "\"!@#\$%^&*()_+-=[]{}|;:,.<>?\"" "$special_chars_test" "SPECIAL_CHARS_TEST variable (with quotes)"

set unicode_test (grep "^UNICODE_TEST:" /tmp/fish_results.txt | cut -d: -f2-)
test_var "\"Testing: αβγ 中文 العربية русский 🎉\"" "$unicode_test" "UNICODE_TEST variable (with quotes)"

# Cleanup
rm -f /tmp/fish_results.txt

# Summary
echo -e "\n$BLUE"'Simple Fish Test Summary:'"$NC"
echo "========================="
echo -e "Platform: $PLATFORM"
echo -e "Total tests: $total_tests"
echo -e "$GREEN"'Passed: '"$passed_tests""$NC"
echo -e "$RED"'Failed: '(math $total_tests - $passed_tests)"$NC"

if test $passed_tests -eq $total_tests
    echo -e "$GREEN"'🎉 All tests passed! Fish implementation is working correctly'"$NC"
    exit 0
else
    echo -e "$RED"'💥 Some tests failed. Check the output above for details.'"$NC"
    exit 1
end
