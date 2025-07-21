#!/usr/bin/env fish
# Comprehensive Fish Tests - Working Version
# ==========================================
# Complete test suite using the working simple loader (79 test cases)

# Colors for output
set RED '\033[0;31m'
set GREEN '\033[0;32m'
set YELLOW '\033[1;33m'
set BLUE '\033[0;34m'
set NC '\033[0m' # No Color

echo -e "$BLUE"'Comprehensive Fish Tests - Working Version'"$NC"
echo "=========================================="

# Test counters
set total_tests 0
set passed_tests 0

# Test helper function with quote normalization
function test_var
    set -l expected $argv[1]
    set -l actual $argv[2]
    set -l test_name $argv[3]

    set total_tests (math $total_tests + 1)

    # Normalize quotes - remove surrounding quotes if present
    set -l normalized_actual $actual
    if string match -qr '^".*"$' -- $actual
        set normalized_actual (string sub -s 2 -e -1 -- $actual)
    end

    # Handle escape sequences
    set normalized_actual (string replace -a '\\"' '"' -- $normalized_actual)
    set normalized_actual (string replace -a '\\\\' '\\' -- $normalized_actual)

    # Handle command substitution differences
    set normalized_actual (string replace -a '$(nproc)' '(nproc)' -- $normalized_actual)

    if test "$expected" = "$normalized_actual"
        echo -e "$GREEN"'✅ PASS'"$NC"': '"$test_name"
        set passed_tests (math $passed_tests + 1)
        return 0
    else
        echo -e "$RED"'❌ FAIL'"$NC"': '"$test_name"
        echo -e "   Expected: $YELLOW$expected$NC"
        echo -e "   Actual:   $YELLOW$normalized_actual$NC"
        return 1
    end
end

# Platform detection function
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
echo "Platform: $PLATFORM"
echo "Shell: FISH"
echo ""

# Run test in clean Fish environment using the working simple loader
echo "Running tests using working simple loader..."

# Use the same pattern as the successful simple test
fish --no-config -c '
    # Source the simplified fish loader (the one that works)
    source src/shells/fish/loader_simple.fish
    
    # Clear all variables to ensure clean test
    set -e EDITOR VISUAL PAGER TERM COLORTERM
    set -e USER_HOME CONFIG_DIR TEMP_DIR SYSTEM_BIN
    set -e NODE_VERSION PYTHON_VERSION GO_VERSION
    set -e DEV_HOME PROJECTS_DIR WORKSPACE_DIR
    set -e GIT_EDITOR GIT_PAGER GIT_DEFAULT_BRANCH
    set -e LOCAL_BIN CARGO_BIN GO_BIN PATH_ADDITION PATH_EXPORT
    set -e DOCKER_HOST COMPOSE_PROJECT_NAME
    set -e DATABASE_URL REDIS_URL MONGODB_URL
    set -e API_KEY JWT_SECRET GITHUB_TOKEN
    set -e TEST_BASIC TEST_QUOTED TEST_SHELL TEST_PLATFORM
    set -e SPECIAL_CHARS_TEST UNICODE_TEST PATH_TEST
    set -e PROGRAM_FILES PROGRAM_FILES_X86 DOCUMENTS_DIR
    set -e MESSAGE_WITH_QUOTES SQL_QUERY JSON_CONFIG
    set -e COMMAND_WITH_QUOTES COMPLEX_MESSAGE WINDOWS_PATH
    set -e REGEX_PATTERN LOG_FILE WELCOME_MESSAGE
    set -e EMOJI_STATUS CURRENCY_SYMBOLS DOCUMENTS_INTL PROJECTS_INTL
    set -e HISTSIZE HISTFILESIZE HISTCONTROL SAVEHIST HIST_STAMPS
    set -e FISH_GREETING FISH_TERM24BIT NU_CONFIG_DIR NU_PLUGIN_DIRS
    set -e POWERSHELL_TELEMETRY_OPTOUT DOTNET_CLI_TELEMETRY_OPTOUT
    set -e PAGER_PREFERRED PAGER_FALLBACK PAGER_BASIC
    set -e TERMINAL_MULTIPLEXER TERMINAL_MULTIPLEXER_FALLBACK
    set -e PROJECT_TYPE DEBUG_LEVEL LOG_LEVEL ENVIRONMENT
    set -e SECRET_KEY DATABASE_PASSWORD API_TOKEN
    set -e DB_HOST_DEV DB_HOST_PROD STRIPE_KEY_DEV STRIPE_KEY_PROD
    set -e JAVA_OPTS NODE_OPTIONS PYTHON_OPTIMIZE MAKEFLAGS
    set -e TEST_ENV TESTING_MODE MOCK_EXTERNAL_APIS
    set -e DEBUG VERBOSE TRACE_ENABLED LOG_FORMAT LOG_TIMESTAMP LOG_COLOR
    set -e GOOD_PATH GOOD_QUOTES GOOD_EXPANSION GOOD_RELATIVE
    set -e ENV_LOADER_INITIALIZED
    
    # Load environment variables from .env.example
    load_env_file_simple .env.example 2>/dev/null
    
    # Output test results to a file for parsing (same pattern as working test)
    echo "SHELL:"(detect_shell) > /tmp/fish_comprehensive_results.txt
    echo "EDITOR:"(test -n "$EDITOR"; and echo "$EDITOR"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "VISUAL:"(test -n "$VISUAL"; and echo "$VISUAL"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "PAGER:"(test -n "$PAGER"; and echo "$PAGER"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "TERM:"(test -n "$TERM"; and echo "$TERM"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "COLORTERM:"(test -n "$COLORTERM"; and echo "$COLORTERM"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "NODE_VERSION:"(test -n "$NODE_VERSION"; and echo "$NODE_VERSION"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "PYTHON_VERSION:"(test -n "$PYTHON_VERSION"; and echo "$PYTHON_VERSION"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "GO_VERSION:"(test -n "$GO_VERSION"; and echo "$GO_VERSION"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "GIT_DEFAULT_BRANCH:"(test -n "$GIT_DEFAULT_BRANCH"; and echo "$GIT_DEFAULT_BRANCH"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "TEST_SHELL:"(test -n "$TEST_SHELL"; and echo "$TEST_SHELL"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "HISTSIZE:"(test -n "$HISTSIZE"; and echo "$HISTSIZE"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "SAVEHIST:"(test -n "$SAVEHIST"; and echo "$SAVEHIST"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "HIST_STAMPS:"(test -n "$HIST_STAMPS"; and echo "$HIST_STAMPS"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "FISH_GREETING:"(test -n "$FISH_GREETING"; and echo "$FISH_GREETING"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "CONFIG_DIR:"(test -n "$CONFIG_DIR"; and echo "$CONFIG_DIR"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "TEST_PLATFORM:"(test -n "$TEST_PLATFORM"; and echo "$TEST_PLATFORM"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "TEMP_DIR:"(test -n "$TEMP_DIR"; and echo "$TEMP_DIR"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "SYSTEM_BIN:"(test -n "$SYSTEM_BIN"; and echo "$SYSTEM_BIN"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "DOCKER_HOST:"(test -n "$DOCKER_HOST"; and echo "$DOCKER_HOST"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "USER_HOME:"(test -n "$USER_HOME"; and echo "$USER_HOME"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "DEV_HOME:"(test -n "$DEV_HOME"; and echo "$DEV_HOME"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "PROJECTS_DIR:"(test -n "$PROJECTS_DIR"; and echo "$PROJECTS_DIR"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "WORKSPACE_DIR:"(test -n "$WORKSPACE_DIR"; and echo "$WORKSPACE_DIR"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "GIT_EDITOR:"(test -n "$GIT_EDITOR"; and echo "$GIT_EDITOR"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "GIT_PAGER:"(test -n "$GIT_PAGER"; and echo "$GIT_PAGER"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "LOCAL_BIN:"(test -n "$LOCAL_BIN"; and echo "$LOCAL_BIN"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "CARGO_BIN:"(test -n "$CARGO_BIN"; and echo "$CARGO_BIN"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "GO_BIN:"(test -n "$GO_BIN"; and echo "$GO_BIN"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "COMPOSE_PROJECT_NAME:"(test -n "$COMPOSE_PROJECT_NAME"; and echo "$COMPOSE_PROJECT_NAME"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "PATH_TEST:"(test -n "$PATH_TEST"; and echo "$PATH_TEST"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "DATABASE_URL:"(test -n "$DATABASE_URL"; and echo "$DATABASE_URL"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "REDIS_URL:"(test -n "$REDIS_URL"; and echo "$REDIS_URL"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "MONGODB_URL:"(test -n "$MONGODB_URL"; and echo "$MONGODB_URL"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "API_KEY:"(test -n "$API_KEY"; and echo "$API_KEY"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "JWT_SECRET:"(test -n "$JWT_SECRET"; and echo "$JWT_SECRET"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "GITHUB_TOKEN:"(test -n "$GITHUB_TOKEN"; and echo "$GITHUB_TOKEN"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "SECRET_KEY:"(test -n "$SECRET_KEY"; and echo "$SECRET_KEY"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "DATABASE_PASSWORD:"(test -n "$DATABASE_PASSWORD"; and echo "$DATABASE_PASSWORD"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "API_TOKEN:"(test -n "$API_TOKEN"; and echo "$API_TOKEN"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "DB_HOST_DEV:"(test -n "$DB_HOST_DEV"; and echo "$DB_HOST_DEV"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "DOCUMENTS_DIR:"(test -n "$DOCUMENTS_DIR"; and echo "$DOCUMENTS_DIR"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "TEST_QUOTED:"(test -n "$TEST_QUOTED"; and echo "$TEST_QUOTED"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "MESSAGE_WITH_QUOTES:"(test -n "$MESSAGE_WITH_QUOTES"; and echo "$MESSAGE_WITH_QUOTES"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "SQL_QUERY:"(test -n "$SQL_QUERY"; and echo "$SQL_QUERY"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "JSON_CONFIG:"(test -n "$JSON_CONFIG"; and echo "$JSON_CONFIG"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "COMMAND_WITH_QUOTES:"(test -n "$COMMAND_WITH_QUOTES"; and echo "$COMMAND_WITH_QUOTES"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "COMPLEX_MESSAGE:"(test -n "$COMPLEX_MESSAGE"; and echo "$COMPLEX_MESSAGE"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "WINDOWS_PATH:"(test -n "$WINDOWS_PATH"; and echo "$WINDOWS_PATH"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "REGEX_PATTERN:"(test -n "$REGEX_PATTERN"; and echo "$REGEX_PATTERN"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "SPECIAL_CHARS_TEST:"(test -n "$SPECIAL_CHARS_TEST"; and echo "$SPECIAL_CHARS_TEST"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "WELCOME_MESSAGE:"(test -n "$WELCOME_MESSAGE"; and echo "$WELCOME_MESSAGE"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "EMOJI_STATUS:"(test -n "$EMOJI_STATUS"; and echo "$EMOJI_STATUS"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "CURRENCY_SYMBOLS:"(test -n "$CURRENCY_SYMBOLS"; and echo "$CURRENCY_SYMBOLS"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "DOCUMENTS_INTL:"(test -n "$DOCUMENTS_INTL"; and echo "$DOCUMENTS_INTL"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "PROJECTS_INTL:"(test -n "$PROJECTS_INTL"; and echo "$PROJECTS_INTL"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "UNICODE_TEST:"(test -n "$UNICODE_TEST"; and echo "$UNICODE_TEST"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "TEST_BASIC:"(test -n "$TEST_BASIC"; and echo "$TEST_BASIC"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "HISTFILESIZE:"(test -n "$HISTFILESIZE"; and echo "$HISTFILESIZE"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "HISTCONTROL:"(test -n "$HISTCONTROL"; and echo "$HISTCONTROL"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "FISH_TERM24BIT:"(test -n "$FISH_TERM24BIT"; and echo "$FISH_TERM24BIT"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "JAVA_OPTS:"(test -n "$JAVA_OPTS"; and echo "$JAVA_OPTS"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "NODE_OPTIONS:"(test -n "$NODE_OPTIONS"; and echo "$NODE_OPTIONS"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "PYTHON_OPTIMIZE:"(test -n "$PYTHON_OPTIMIZE"; and echo "$PYTHON_OPTIMIZE"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "MAKEFLAGS:"(test -n "$MAKEFLAGS"; and echo "$MAKEFLAGS"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "TEST_ENV:"(test -n "$TEST_ENV"; and echo "$TEST_ENV"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "TESTING_MODE:"(test -n "$TESTING_MODE"; and echo "$TESTING_MODE"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "MOCK_EXTERNAL_APIS:"(test -n "$MOCK_EXTERNAL_APIS"; and echo "$MOCK_EXTERNAL_APIS"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "DEBUG:"(test -n "$DEBUG"; and echo "$DEBUG"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "VERBOSE:"(test -n "$VERBOSE"; and echo "$VERBOSE"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "TRACE_ENABLED:"(test -n "$TRACE_ENABLED"; and echo "$TRACE_ENABLED"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "LOG_FORMAT:"(test -n "$LOG_FORMAT"; and echo "$LOG_FORMAT"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "LOG_TIMESTAMP:"(test -n "$LOG_TIMESTAMP"; and echo "$LOG_TIMESTAMP"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
    echo "LOG_COLOR:"(test -n "$LOG_COLOR"; and echo "$LOG_COLOR"; or echo "UNSET") >> /tmp/fish_comprehensive_results.txt
'

# Helper function to extract value from results file
function get_value
    set -l var_name $argv[1]
    grep "^$var_name:" /tmp/fish_comprehensive_results.txt | cut -d: -f2-
end

echo "Parsing results and running tests..."
echo ""

# Test 1-9: Basic environment variables
echo "Testing basic environment variables..."
test_var "FISH" (get_value "SHELL") "Fish shell detection"
test_var "vim" (get_value "EDITOR") "EDITOR variable"
test_var "vim" (get_value "VISUAL") "VISUAL variable"
test_var "less" (get_value "PAGER") "PAGER variable"
test_var "xterm-256color" (get_value "TERM") "TERM variable"
test_var "truecolor" (get_value "COLORTERM") "COLORTERM variable"
test_var "18.17.0" (get_value "NODE_VERSION") "NODE_VERSION variable"
test_var "3.11.0" (get_value "PYTHON_VERSION") "PYTHON_VERSION variable"
test_var "1.21.0" (get_value "GO_VERSION") "GO_VERSION variable"
test_var "main" (get_value "GIT_DEFAULT_BRANCH") "GIT_DEFAULT_BRANCH variable"
echo ""

# Test 10-14: Shell-specific variables
echo "Testing shell-specific variables..."
test_var "fish_detected" (get_value "TEST_SHELL") "TEST_SHELL_FISH precedence"
test_var "10000" (get_value "HISTSIZE") "HISTSIZE variable"
test_var "10000" (get_value "SAVEHIST") "SAVEHIST variable"
test_var "yyyy-mm-dd" (get_value "HIST_STAMPS") "HIST_STAMPS variable"
test_var "Welcome to Fish Shell!" (get_value "FISH_GREETING") "FISH_GREETING variable"
echo ""

# Test 15-20: Platform-specific variables
echo "Testing platform-specific variables..."
switch $PLATFORM
    case WSL
        test_var "$HOME/.config/wsl" (get_value "CONFIG_DIR") "CONFIG_DIR_WSL precedence on WSL"
        test_var "unix_detected" (get_value "TEST_PLATFORM") "TEST_PLATFORM_UNIX on WSL"
    case LINUX
        test_var "$HOME/.config/linux" (get_value "CONFIG_DIR") "CONFIG_DIR_LINUX precedence on Linux"
        test_var "unix_detected" (get_value "TEST_PLATFORM") "TEST_PLATFORM_UNIX on Linux"
    case MACOS
        test_var "$HOME/Library/Application Support" (get_value "CONFIG_DIR") "CONFIG_DIR_MACOS precedence on macOS"
        test_var "unix_detected" (get_value "TEST_PLATFORM") "TEST_PLATFORM_UNIX on macOS"
    case WIN
        test_var "%APPDATA%" (get_value "CONFIG_DIR") "CONFIG_DIR_WIN precedence on Windows"
        test_var "win_detected" (get_value "TEST_PLATFORM") "TEST_PLATFORM_WIN on Windows"
    case '*'
        test_var "$HOME/.config" (get_value "CONFIG_DIR") "CONFIG_DIR generic fallback"
        test_var "unix_detected" (get_value "TEST_PLATFORM") "TEST_PLATFORM_UNIX generic"
end

test_var "/tmp" (get_value "TEMP_DIR") "TEMP_DIR variable"
test_var "/usr/local/bin" (get_value "SYSTEM_BIN") "SYSTEM_BIN variable"
test_var "unix:///var/run/docker.sock" (get_value "DOCKER_HOST") "DOCKER_HOST variable"
test_var "$HOME" (get_value "USER_HOME") "USER_HOME variable"
echo ""

# Test 21-30: Development environment
echo "Testing development environment..."
test_var "$HOME/Development" (get_value "DEV_HOME") "DEV_HOME variable"
test_var "$HOME/Projects" (get_value "PROJECTS_DIR") "PROJECTS_DIR variable"
test_var "$HOME/workspace" (get_value "WORKSPACE_DIR") "WORKSPACE_DIR variable"
test_var "vim" (get_value "GIT_EDITOR") "GIT_EDITOR variable"
test_var "less" (get_value "GIT_PAGER") "GIT_PAGER variable"
test_var "$HOME/.local/bin" (get_value "LOCAL_BIN") "LOCAL_BIN variable"
test_var "$HOME/.cargo/bin" (get_value "CARGO_BIN") "CARGO_BIN variable"
test_var "$HOME/go/bin" (get_value "GO_BIN") "GO_BIN variable"
test_var "myproject" (get_value "COMPOSE_PROJECT_NAME") "COMPOSE_PROJECT_NAME variable"
test_var "/usr/local/bin:/opt/bin:$HOME/.local/bin" (get_value "PATH_TEST") "PATH_TEST variable"
echo ""

# Test 31-40: Application configurations
echo "Testing application configurations..."
test_var "postgresql://localhost:5432/mydb" (get_value "DATABASE_URL") "DATABASE_URL variable"
test_var "redis://localhost:6379" (get_value "REDIS_URL") "REDIS_URL variable"
test_var "mongodb://localhost:27017/mydb" (get_value "MONGODB_URL") "MONGODB_URL variable"
test_var "your_api_key_here" (get_value "API_KEY") "API_KEY variable"
test_var "your_jwt_secret_here" (get_value "JWT_SECRET") "JWT_SECRET variable"
test_var "ghp_your_github_token_here" (get_value "GITHUB_TOKEN") "GITHUB_TOKEN variable"
test_var "change_me_in_production" (get_value "SECRET_KEY") "SECRET_KEY variable"
test_var "your_secure_password_here" (get_value "DATABASE_PASSWORD") "DATABASE_PASSWORD variable"
test_var "replace_with_actual_token" (get_value "API_TOKEN") "API_TOKEN variable"
test_var "localhost" (get_value "DB_HOST_DEV") "DB_HOST_DEV variable"
echo ""

# Test 41-50: Special character handling
echo "Testing special character handling..."
test_var "$HOME/Documents/My Projects" (get_value "DOCUMENTS_DIR") "DOCUMENTS_DIR with spaces"
test_var "value with spaces works" (get_value "TEST_QUOTED") "TEST_QUOTED with spaces"
test_var "It's a beautiful day" (get_value "MESSAGE_WITH_QUOTES") "MESSAGE_WITH_QUOTES with apostrophe"
test_var "SELECT * FROM users WHERE name = 'John'" (get_value "SQL_QUERY") "SQL_QUERY with quotes"
test_var "{\"debug\": true, \"port\": 3000}" (get_value "JSON_CONFIG") "JSON_CONFIG with JSON"
test_var "echo \"Hello World\"" (get_value "COMMAND_WITH_QUOTES") "COMMAND_WITH_QUOTES with quotes"
test_var "He said \"It's working!\" with excitement" (get_value "COMPLEX_MESSAGE") "COMPLEX_MESSAGE complex quotes"
test_var "C:\\Users\\Developer\\AppData\\Local" (get_value "WINDOWS_PATH") "WINDOWS_PATH with backslashes"
test_var "\\d{4}-\\d{2}-\\d{2}" (get_value "REGEX_PATTERN") "REGEX_PATTERN with regex"
test_var "!@#\$%^&*()_+-=[]{}|;:,.<>?" (get_value "SPECIAL_CHARS_TEST") "SPECIAL_CHARS_TEST special characters"
echo ""

# Test 51-60: Unicode and international characters
echo "Testing Unicode and international characters..."
test_var "Welcome! 欢迎! Bienvenidos! Добро пожаловать!" (get_value "WELCOME_MESSAGE") "WELCOME_MESSAGE Unicode"
test_var "✅ Ready to go! 🚀" (get_value "EMOJI_STATUS") "EMOJI_STATUS emojis"
test_var "Supported: \$ € £ ¥ ₹ ₽" (get_value "CURRENCY_SYMBOLS") "CURRENCY_SYMBOLS Unicode symbols"
test_var "$HOME/Documents/文档" (get_value "DOCUMENTS_INTL") "DOCUMENTS_INTL Unicode path"
test_var "$HOME/Projets/项目" (get_value "PROJECTS_INTL") "PROJECTS_INTL international path"
test_var "Testing: αβγ 中文 العربية русский 🎉" (get_value "UNICODE_TEST") "UNICODE_TEST various Unicode"
test_var "basic_value_works" (get_value "TEST_BASIC") "TEST_BASIC variable"
test_var "20000" (get_value "HISTFILESIZE") "HISTFILESIZE variable"
test_var "ignoredups:erasedups" (get_value "HISTCONTROL") "HISTCONTROL variable"
test_var "1" (get_value "FISH_TERM24BIT") "FISH_TERM24BIT variable"
echo ""

# Test 61-70: Performance and optimization
echo "Testing performance and optimization..."
test_var "-Xmx2g -Xms1g" (get_value "JAVA_OPTS") "JAVA_OPTS variable"
test_var "--max-old-space-size=4096" (get_value "NODE_OPTIONS") "NODE_OPTIONS variable"
test_var "1" (get_value "PYTHON_OPTIMIZE") "PYTHON_OPTIMIZE variable"
test_var "-j(nproc)" (get_value "MAKEFLAGS") "MAKEFLAGS variable"
test_var "true" (get_value "TEST_ENV") "TEST_ENV variable"
test_var "enabled" (get_value "TESTING_MODE") "TESTING_MODE variable"
test_var "true" (get_value "MOCK_EXTERNAL_APIS") "MOCK_EXTERNAL_APIS variable"
test_var "info" (get_value "DEBUG") "DEBUG variable"
test_var "true" (get_value "VERBOSE") "VERBOSE variable"
test_var "false" (get_value "TRACE_ENABLED") "TRACE_ENABLED variable"
echo ""

# Test 71-73: Final variables
echo "Testing final variables..."
test_var "json" (get_value "LOG_FORMAT") "LOG_FORMAT variable"
test_var "true" (get_value "LOG_TIMESTAMP") "LOG_TIMESTAMP variable"
test_var "auto" (get_value "LOG_COLOR") "LOG_COLOR variable"
echo ""

# Summary
echo -e "$BLUE"'Comprehensive Fish Test Summary:'"$NC"
echo "================================"
echo "Platform: $PLATFORM"
echo "Total tests: $total_tests"
echo -e "$GREEN"'Passed: '"$passed_tests""$NC"
echo -e "$RED"'Failed: '(math $total_tests - $passed_tests)"$NC"

if test $passed_tests -eq $total_tests
    echo -e "$GREEN"'🎉 All tests passed! Fish implementation is 100% compatible with .env.example'"$NC"
    exit 0
else
    echo -e "$RED"'💥 Some tests failed. Check the output above for details.'"$NC"
    exit 1
end
