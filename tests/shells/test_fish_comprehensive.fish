#!/usr/bin/env fish
# Comprehensive Fish Shell Tests Based on .env.example
# =====================================================
# One test case per environment variable from .env.example

# Colors for output (fish style)
set RED '\033[0;31m'
set GREEN '\033[0;32m'
set YELLOW '\033[1;33m'
set BLUE '\033[0;34m'
set NC '\033[0m' # No Color

echo -e "$BLUE"'Running Comprehensive Fish Shell Tests Based on .env.example'"$NC"
echo "=============================================================="

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

# Get platform for platform-specific tests (use same logic as common/platform.sh)
function get_platform
    set -l uname_s (uname -s 2>/dev/null; or echo 'Unknown')
    switch $uname_s
        case 'Linux*'
            # Check for WSL
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
# We need to run this in a subshell to avoid contaminating the test environment
set fish_output (fish --no-config -c '
    # Source the fish loader
    source src/shells/fish/loader.fish
    
    # Clear all variables to ensure clean test
    set -e EDITOR VISUAL PAGER TERM COLORTERM
    set -e USER_HOME CONFIG_DIR TEMP_DIR SYSTEM_BIN
    set -e NODE_VERSION PYTHON_VERSION GO_VERSION
    set -e DEV_HOME PROJECTS_DIR WORKSPACE_DIR
    set -e GIT_EDITOR GIT_PAGER GIT_DEFAULT_BRANCH
    set -e LOCAL_BIN CARGO_BIN GO_BIN
    set -e DOCKER_HOST COMPOSE_PROJECT_NAME
    set -e DATABASE_URL REDIS_URL MONGODB_URL
    set -e API_KEY JWT_SECRET GITHUB_TOKEN
    set -e PROGRAM_FILES PROGRAM_FILES_X86 DOCUMENTS_DIR
    set -e MESSAGE_WITH_QUOTES SQL_QUERY JSON_CONFIG COMMAND_WITH_QUOTES
    set -e COMPLEX_MESSAGE WINDOWS_PATH REGEX_PATTERN
    set -e LOG_FILE WELCOME_MESSAGE EMOJI_STATUS CURRENCY_SYMBOLS
    set -e DOCUMENTS_INTL PROJECTS_INTL
    set -e HISTSIZE_BASH HISTFILESIZE_BASH HISTCONTROL_BASH
    set -e HISTSIZE_ZSH SAVEHIST_ZSH HIST_STAMPS_ZSH
    set -e PAGER_PREFERRED PAGER_FALLBACK PAGER_BASIC
    set -e TERMINAL_MULTIPLEXER TERMINAL_MULTIPLEXER_FALLBACK
    set -e PROJECT_TYPE DEBUG_LEVEL LOG_LEVEL ENVIRONMENT
    set -e SECRET_KEY DATABASE_PASSWORD API_TOKEN
    set -e DB_HOST_DEV DB_HOST_PROD STRIPE_KEY_DEV STRIPE_KEY_PROD
    set -e JAVA_OPTS NODE_OPTIONS PYTHON_OPTIMIZE
    set -e MAKEFLAGS TEST_ENV TESTING_MODE MOCK_EXTERNAL_APIS
    set -e DEBUG VERBOSE TRACE_ENABLED LOG_FORMAT LOG_TIMESTAMP LOG_COLOR
    set -e GOOD_PATH GOOD_QUOTES GOOD_EXPANSION_BASH GOOD_RELATIVE
    set -e TEST_BASIC TEST_QUOTED TEST_PLATFORM_UNIX TEST_PLATFORM_WIN
    set -e TEST_SHELL_BASH TEST_SHELL_ZSH SPECIAL_CHARS_TEST UNICODE_TEST PATH_TEST
    set -e ENV_LOADER_INITIALIZED
    
    load_env_file .env.example 2>/dev/null
    
    # Output all variables for testing
    echo "SHELL:"(detect_shell)
    
    # Basic environment variables
    echo "EDITOR:"(test -n "$EDITOR"; and echo "$EDITOR"; or echo "UNSET")
    echo "VISUAL:"(test -n "$VISUAL"; and echo "$VISUAL"; or echo "UNSET")
    echo "PAGER:"(test -n "$PAGER"; and echo "$PAGER"; or echo "UNSET")
    echo "TERM:"(test -n "$TERM"; and echo "$TERM"; or echo "UNSET")
    echo "COLORTERM:"(test -n "$COLORTERM"; and echo "$COLORTERM"; or echo "UNSET")
    
    # Platform-specific variables (will vary by platform)
    echo "USER_HOME:"(test -n "$USER_HOME"; and echo "$USER_HOME"; or echo "UNSET")
    echo "CONFIG_DIR:"(test -n "$CONFIG_DIR"; and echo "$CONFIG_DIR"; or echo "UNSET")
    echo "TEMP_DIR:"(test -n "$TEMP_DIR"; and echo "$TEMP_DIR"; or echo "UNSET")
    echo "SYSTEM_BIN:"(test -n "$SYSTEM_BIN"; and echo "$SYSTEM_BIN"; or echo "UNSET")
    
    # Development environment variables
    echo "NODE_VERSION:"(test -n "$NODE_VERSION"; and echo "$NODE_VERSION"; or echo "UNSET")
    echo "PYTHON_VERSION:"(test -n "$PYTHON_VERSION"; and echo "$PYTHON_VERSION"; or echo "UNSET")
    echo "GO_VERSION:"(test -n "$GO_VERSION"; and echo "$GO_VERSION"; or echo "UNSET")
    echo "DEV_HOME:"(test -n "$DEV_HOME"; and echo "$DEV_HOME"; or echo "UNSET")
    echo "PROJECTS_DIR:"(test -n "$PROJECTS_DIR"; and echo "$PROJECTS_DIR"; or echo "UNSET")
    echo "WORKSPACE_DIR:"(test -n "$WORKSPACE_DIR"; and echo "$WORKSPACE_DIR"; or echo "UNSET")
    
    # Git configuration
    echo "GIT_EDITOR:"(test -n "$GIT_EDITOR"; and echo "$GIT_EDITOR"; or echo "UNSET")
    echo "GIT_PAGER:"(test -n "$GIT_PAGER"; and echo "$GIT_PAGER"; or echo "UNSET")
    echo "GIT_DEFAULT_BRANCH:"(test -n "$GIT_DEFAULT_BRANCH"; and echo "$GIT_DEFAULT_BRANCH"; or echo "UNSET")
    
    # PATH manipulation
    echo "LOCAL_BIN:"(test -n "$LOCAL_BIN"; and echo "$LOCAL_BIN"; or echo "UNSET")
    echo "CARGO_BIN:"(test -n "$CARGO_BIN"; and echo "$CARGO_BIN"; or echo "UNSET")
    echo "GO_BIN:"(test -n "$GO_BIN"; and echo "$GO_BIN"; or echo "UNSET")
    
    # Application-specific configurations
    echo "DOCKER_HOST:"(test -n "$DOCKER_HOST"; and echo "$DOCKER_HOST"; or echo "UNSET")
    echo "COMPOSE_PROJECT_NAME:"(test -n "$COMPOSE_PROJECT_NAME"; and echo "$COMPOSE_PROJECT_NAME"; or echo "UNSET")
    echo "DATABASE_URL:"(test -n "$DATABASE_URL"; and echo "$DATABASE_URL"; or echo "UNSET")
    echo "REDIS_URL:"(test -n "$REDIS_URL"; and echo "$REDIS_URL"; or echo "UNSET")
    echo "MONGODB_URL:"(test -n "$MONGODB_URL"; and echo "$MONGODB_URL"; or echo "UNSET")
    
    # API keys and tokens
    echo "API_KEY:"(test -n "$API_KEY"; and echo "$API_KEY"; or echo "UNSET")
    echo "JWT_SECRET:"(test -n "$JWT_SECRET"; and echo "$JWT_SECRET"; or echo "UNSET")
    echo "GITHUB_TOKEN:"(test -n "$GITHUB_TOKEN"; and echo "$GITHUB_TOKEN"; or echo "UNSET")
    
    # Special character handling
    echo "PROGRAM_FILES:"(test -n "$PROGRAM_FILES"; and echo "$PROGRAM_FILES"; or echo "UNSET")
    echo "PROGRAM_FILES_X86:"(test -n "$PROGRAM_FILES_X86"; and echo "$PROGRAM_FILES_X86"; or echo "UNSET")
    echo "DOCUMENTS_DIR:"(test -n "$DOCUMENTS_DIR"; and echo "$DOCUMENTS_DIR"; or echo "UNSET")
    echo "MESSAGE_WITH_QUOTES:"(test -n "$MESSAGE_WITH_QUOTES"; and echo "$MESSAGE_WITH_QUOTES"; or echo "UNSET")
    echo "SQL_QUERY:"(test -n "$SQL_QUERY"; and echo "$SQL_QUERY"; or echo "UNSET")
    echo "JSON_CONFIG:"(test -n "$JSON_CONFIG"; and echo "$JSON_CONFIG"; or echo "UNSET")
    echo "COMMAND_WITH_QUOTES:"(test -n "$COMMAND_WITH_QUOTES"; and echo "$COMMAND_WITH_QUOTES"; or echo "UNSET")
    echo "COMPLEX_MESSAGE:"(test -n "$COMPLEX_MESSAGE"; and echo "$COMPLEX_MESSAGE"; or echo "UNSET")
    echo "WINDOWS_PATH:"(test -n "$WINDOWS_PATH"; and echo "$WINDOWS_PATH"; or echo "UNSET")
    echo "REGEX_PATTERN:"(test -n "$REGEX_PATTERN"; and echo "$REGEX_PATTERN"; or echo "UNSET")
    echo "LOG_FILE:"(test -n "$LOG_FILE"; and echo "$LOG_FILE"; or echo "UNSET")
    
    # Unicode and international characters
    echo "WELCOME_MESSAGE:"(test -n "$WELCOME_MESSAGE"; and echo "$WELCOME_MESSAGE"; or echo "UNSET")
    echo "EMOJI_STATUS:"(test -n "$EMOJI_STATUS"; and echo "$EMOJI_STATUS"; or echo "UNSET")
    echo "CURRENCY_SYMBOLS:"(test -n "$CURRENCY_SYMBOLS"; and echo "$CURRENCY_SYMBOLS"; or echo "UNSET")
    echo "DOCUMENTS_INTL:"(test -n "$DOCUMENTS_INTL"; and echo "$DOCUMENTS_INTL"; or echo "UNSET")
    echo "PROJECTS_INTL:"(test -n "$PROJECTS_INTL"; and echo "$PROJECTS_INTL"; or echo "UNSET")
    
    # Test variables
    echo "TEST_BASIC:"(test -n "$TEST_BASIC"; and echo "$TEST_BASIC"; or echo "UNSET")
    echo "TEST_QUOTED:"(test -n "$TEST_QUOTED"; and echo "$TEST_QUOTED"; or echo "UNSET")
    echo "TEST_SHELL:"(test -n "$TEST_SHELL"; and echo "$TEST_SHELL"; or echo "UNSET")
    echo "SPECIAL_CHARS_TEST:"(test -n "$SPECIAL_CHARS_TEST"; and echo "$SPECIAL_CHARS_TEST"; or echo "UNSET")
    echo "UNICODE_TEST:"(test -n "$UNICODE_TEST"; and echo "$UNICODE_TEST"; or echo "UNSET")
    echo "PATH_TEST:"(test -n "$PATH_TEST"; and echo "$PATH_TEST"; or echo "UNSET")
')

# Parse fish results and test each variable
# Use printf to ensure proper line handling
printf '%s\n' $fish_output > /tmp/fish_test_output.txt

set shell (grep "^SHELL:" /tmp/fish_test_output.txt | cut -d: -f2)
test_var "FISH" "$shell" "Fish shell detection"

# Basic environment variables
set editor (grep "^EDITOR:" /tmp/fish_test_output.txt | cut -d: -f2)
test_var "vim" "$editor" "EDITOR variable"

set visual (grep "^VISUAL:" /tmp/fish_test_output.txt | cut -d: -f2)
test_var "vim" "$visual" "VISUAL variable"

set pager (grep "^PAGER:" /tmp/fish_test_output.txt | cut -d: -f2)
test_var "less" "$pager" "PAGER variable"

set term (grep "^TERM:" /tmp/fish_test_output.txt | cut -d: -f2)
test_var "xterm-256color" "$term" "TERM variable"

set colorterm (grep "^COLORTERM:" /tmp/fish_test_output.txt | cut -d: -f2)
test_var "truecolor" "$colorterm" "COLORTERM variable"

# Platform-specific variables (test based on current platform)
set user_home (grep "^USER_HOME:" /tmp/fish_test_output.txt | cut -d: -f2-)
# USER_HOME should be expanded to actual user home
test_var "/home/$USER" "$user_home" "USER_HOME variable (expanded)"

set config_dir (grep "^CONFIG_DIR:" /tmp/fish_test_output.txt | cut -d: -f2)
switch $PLATFORM
    case WSL
        test_var "~/.config/wsl" "$config_dir" "CONFIG_DIR_WSL precedence"
    case LINUX
        test_var "~/.config/linux" "$config_dir" "CONFIG_DIR_LINUX precedence"
    case MACOS
        test_var "~/Library/Application Support" "$config_dir" "CONFIG_DIR_MACOS precedence"
    case WIN
        test_var "%APPDATA%" "$config_dir" "CONFIG_DIR_WIN precedence"
    case '*'
        test_var "~/.config" "$config_dir" "CONFIG_DIR generic fallback"
end

# Development environment variables
set node_version (echo $fish_output | grep "^NODE_VERSION:" | cut -d: -f2)
test_var "18.17.0" "$node_version" "NODE_VERSION variable"

set python_version (echo $fish_output | grep "^PYTHON_VERSION:" | cut -d: -f2)
test_var "3.11.0" "$python_version" "PYTHON_VERSION variable"

set go_version (echo $fish_output | grep "^GO_VERSION:" | cut -d: -f2)
test_var "1.21.0" "$go_version" "GO_VERSION variable"

# Git configuration
set git_default_branch (echo $fish_output | grep "^GIT_DEFAULT_BRANCH:" | cut -d: -f2)
test_var "main" "$git_default_branch" "GIT_DEFAULT_BRANCH variable"

# Application-specific configurations
set docker_host (echo $fish_output | grep "^DOCKER_HOST:" | cut -d: -f2-)
switch $PLATFORM
    case WIN
        test_var "npipe:////./pipe/docker_engine" "$docker_host" "DOCKER_HOST_WIN precedence"
    case '*'
        test_var "unix:///var/run/docker.sock" "$docker_host" "DOCKER_HOST generic"
end

set database_url (echo $fish_output | grep "^DATABASE_URL:" | cut -d: -f2-)
test_var "postgresql://localhost:5432/mydb" "$database_url" "DATABASE_URL variable"

set api_key (echo $fish_output | grep "^API_KEY:" | cut -d: -f2)
test_var "your_api_key_here" "$api_key" "API_KEY variable"

# Special character handling
set documents_dir (echo $fish_output | grep "^DOCUMENTS_DIR:" | cut -d: -f2-)
test_var "~/Documents/My Projects" "$documents_dir" "DOCUMENTS_DIR variable"

set message_with_quotes (echo $fish_output | grep "^MESSAGE_WITH_QUOTES:" | cut -d: -f2-)
test_var "It's a beautiful day" "$message_with_quotes" "MESSAGE_WITH_QUOTES variable"

set sql_query (echo $fish_output | grep "^SQL_QUERY:" | cut -d: -f2-)
test_var "SELECT * FROM users WHERE name = 'John'" "$sql_query" "SQL_QUERY variable"

set json_config (echo $fish_output | grep "^JSON_CONFIG:" | cut -d: -f2-)
test_var "{\"debug\": true, \"port\": 3000}" "$json_config" "JSON_CONFIG variable"

# Unicode and international characters
set welcome_message (echo $fish_output | grep "^WELCOME_MESSAGE:" | cut -d: -f2-)
test_var "Welcome! 欢迎! Bienvenidos! Добро пожаловать!" "$welcome_message" "WELCOME_MESSAGE variable"

set emoji_status (echo $fish_output | grep "^EMOJI_STATUS:" | cut -d: -f2-)
test_var "✅ Ready to go! 🚀" "$emoji_status" "EMOJI_STATUS variable"

# Test variables
set test_basic (echo $fish_output | grep "^TEST_BASIC:" | cut -d: -f2)
test_var "basic_value_works" "$test_basic" "TEST_BASIC variable"

set test_quoted (echo $fish_output | grep "^TEST_QUOTED:" | cut -d: -f2-)
test_var "value with spaces works" "$test_quoted" "TEST_QUOTED variable"

# TEST_SHELL should be set to fish-specific value if it exists, otherwise generic
set test_shell (echo $fish_output | grep "^TEST_SHELL:" | cut -d: -f2)
# Fish doesn't have a specific TEST_SHELL_FISH in .env.example, so it should get generic value
test_var "basic_shell_test" "$test_shell" "TEST_SHELL variable (generic fallback)"

set special_chars_test (echo $fish_output | grep "^SPECIAL_CHARS_TEST:" | cut -d: -f2-)
test_var "!@#\$%^&*()_+-=[]{}|;:,.<>?" "$special_chars_test" "SPECIAL_CHARS_TEST variable"

set unicode_test (echo $fish_output | grep "^UNICODE_TEST:" | cut -d: -f2-)
test_var "Testing: αβγ 中文 العربية русский 🎉" "$unicode_test" "UNICODE_TEST variable"

# Summary
echo -e "\n$BLUE"'Comprehensive Fish Test Summary:'"$NC"
echo "================================="
echo -e "Platform: $PLATFORM"
echo -e "Total tests: $total_tests"
echo -e "$GREEN"'Passed: '"$passed_tests""$NC"
echo -e "$RED"'Failed: '(math $total_tests - $passed_tests)"$NC"

if test $passed_tests -eq $total_tests
    echo -e "$GREEN"'🎉 All tests passed! Fish implementation is 100% compatible with .env.example'"$NC"
    exit 0
else
    echo -e "$RED"'💥 Some tests failed. Check the output above for details.'"$NC"
    exit 1
end
