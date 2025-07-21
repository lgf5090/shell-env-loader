#!/usr/bin/env fish
# Comprehensive Fish Implementation Tests - Full Coverage
# =======================================================
# Complete test suite matching Bash/Zsh/Nushell coverage with 79+ test cases

# Colors for output
set RED '\033[0;31m'
set GREEN '\033[0;32m'
set YELLOW '\033[1;33m'
set BLUE '\033[0;34m'
set NC '\033[0m' # No Color

echo -e "$BLUE"'Comprehensive Fish Tests - Full Coverage'"$NC"
echo "========================================"

# Test counters
set total_tests 0
set passed_tests 0

# Test helper function
function test_var
    set -l expected $argv[1]
    set -l actual $argv[2]
    set -l test_name $argv[3]
    
    set total_tests (math $total_tests + 1)
    
    if test "$expected" = "$actual"
        echo -e "$GREEN"'✅ PASS'"$NC"': '"$test_name"
        set passed_tests (math $passed_tests + 1)
        return 0
    else
        echo -e "$RED"'❌ FAIL'"$NC"': '"$test_name"
        echo -e "   Expected: $YELLOW$expected$NC"
        echo -e "   Actual:   $YELLOW$actual$NC"
        return 1
    end
end

# PATH test helper
function test_path_contains
    set -l path_entry $argv[1]
    set -l test_name $argv[2]
    
    set total_tests (math $total_tests + 1)
    
    if contains $path_entry $PATH
        echo -e "$GREEN"'✅ PASS'"$NC"': '"$test_name"
        set passed_tests (math $passed_tests + 1)
        return 0
    else
        echo -e "$RED"'❌ FAIL'"$NC"': '"$test_name"
        echo -e "   Expected PATH to contain: $YELLOW$path_entry$NC"
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

# Setup clean test environment and load .env.example
echo "Setting up test environment..."

# Clear potentially conflicting variables
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

# Source the fish loader
source src/shells/fish/loader.fish

# Load environment variables from .env.example
echo "Loading environment variables from .env.example..."
load_env_file .env.example 2>/dev/null
echo "Environment variables loaded successfully."
echo ""

# Test 1-9: Basic environment variables
echo "Testing basic environment variables..."
test_var "vim" "$EDITOR" "EDITOR variable"
test_var "vim" "$VISUAL" "VISUAL variable"
test_var "less" "$PAGER" "PAGER variable"
test_var "xterm-256color" "$TERM" "TERM variable"
test_var "truecolor" "$COLORTERM" "COLORTERM variable"
test_var "18.17.0" "$NODE_VERSION" "NODE_VERSION variable"
test_var "3.11.0" "$PYTHON_VERSION" "PYTHON_VERSION variable"
test_var "1.21.0" "$GO_VERSION" "GO_VERSION variable"
test_var "main" "$GIT_DEFAULT_BRANCH" "GIT_DEFAULT_BRANCH variable"
echo ""

# Test 10-14: Shell-specific variables (should prefer FISH variants)
echo "Testing shell-specific variables..."
test_var "fish_detected" "$TEST_SHELL" "TEST_SHELL_FISH precedence"
test_var "10000" "$HISTSIZE" "HISTSIZE variable"
test_var "10000" "$SAVEHIST" "SAVEHIST variable"
test_var "yyyy-mm-dd" "$HIST_STAMPS" "HIST_STAMPS variable"
test_var "Welcome to Fish Shell!" "$FISH_GREETING" "FISH_GREETING variable"
echo ""

# Test 15-20: Platform-specific variables
echo "Testing platform-specific variables..."
switch $PLATFORM
    case WSL
        test_var "$HOME/.config/wsl" "$CONFIG_DIR" "CONFIG_DIR_WSL precedence on WSL"
        test_var "unix_detected" "$TEST_PLATFORM" "TEST_PLATFORM_UNIX on WSL"
        test_var "/tmp" "$TEMP_DIR" "TEMP_DIR on WSL"
        test_var "/usr/local/bin" "$SYSTEM_BIN" "SYSTEM_BIN on WSL"
        test_var "unix:///var/run/docker.sock" "$DOCKER_HOST" "DOCKER_HOST on WSL"
        test_var "$HOME" "$USER_HOME" "USER_HOME variable"
    case LINUX
        test_var "$HOME/.config/linux" "$CONFIG_DIR" "CONFIG_DIR_LINUX precedence on Linux"
        test_var "unix_detected" "$TEST_PLATFORM" "TEST_PLATFORM_UNIX on Linux"
        test_var "/tmp" "$TEMP_DIR" "TEMP_DIR on Linux"
        test_var "/usr/local/bin" "$SYSTEM_BIN" "SYSTEM_BIN on Linux"
        test_var "unix:///var/run/docker.sock" "$DOCKER_HOST" "DOCKER_HOST on Linux"
        test_var "$HOME" "$USER_HOME" "USER_HOME variable"
    case MACOS
        test_var "$HOME/Library/Application Support" "$CONFIG_DIR" "CONFIG_DIR_MACOS precedence on macOS"
        test_var "unix_detected" "$TEST_PLATFORM" "TEST_PLATFORM_UNIX on macOS"
        test_var "/tmp" "$TEMP_DIR" "TEMP_DIR on macOS"
        test_var "/opt/homebrew/bin" "$SYSTEM_BIN" "SYSTEM_BIN_MACOS on macOS"
        test_var "unix:///var/run/docker.sock" "$DOCKER_HOST" "DOCKER_HOST on macOS"
        test_var "$HOME" "$USER_HOME" "USER_HOME variable"
    case WIN
        test_var "%APPDATA%" "$CONFIG_DIR" "CONFIG_DIR_WIN precedence on Windows"
        test_var "win_detected" "$TEST_PLATFORM" "TEST_PLATFORM_WIN on Windows"
        test_var "%TEMP%" "$TEMP_DIR" "TEMP_DIR_WIN on Windows"
        test_var "C:\\Program Files" "$SYSTEM_BIN" "SYSTEM_BIN_WIN on Windows"
        test_var "npipe:////./pipe/docker_engine" "$DOCKER_HOST" "DOCKER_HOST_WIN on Windows"
        test_var "$HOME" "$USER_HOME" "USER_HOME variable"
    case '*'
        test_var "$HOME/.config" "$CONFIG_DIR" "CONFIG_DIR generic fallback"
        test_var "unix_detected" "$TEST_PLATFORM" "TEST_PLATFORM_UNIX generic"
        test_var "/tmp" "$TEMP_DIR" "TEMP_DIR generic"
        test_var "/usr/local/bin" "$SYSTEM_BIN" "SYSTEM_BIN generic"
        test_var "unix:///var/run/docker.sock" "$DOCKER_HOST" "DOCKER_HOST generic"
        test_var "$HOME" "$USER_HOME" "USER_HOME variable"
end
echo ""

# Test 21-26: PATH handling
echo "Testing PATH handling..."
test_path_contains "/usr/local/bin" "PATH contains /usr/local/bin"
test_path_contains "/snap/bin" "PATH contains /snap/bin"
test_path_contains "$HOME/.local/bin" "PATH contains ~/.local/bin"
test_path_contains "$HOME/.cargo/bin" "PATH contains ~/.cargo/bin"
test_path_contains "$HOME/go/bin" "PATH contains ~/go/bin"

# Platform-specific PATH tests
switch $PLATFORM
    case LINUX
        test_path_contains "/tmp/test_linux_path" "PATH contains Linux-specific path"
    case WSL
        test_path_contains "/tmp/test_wsl_path" "PATH contains WSL-specific path"
    case MACOS
        test_path_contains "/opt/homebrew/bin" "PATH contains macOS Homebrew path"
    case '*'
        test_path_contains "/tmp/test_unix_path" "PATH contains Unix-specific path"
end
echo ""

# Test 27-36: Development environment
echo "Testing development environment..."
test_var "$HOME/Development" "$DEV_HOME" "DEV_HOME variable"
test_var "$HOME/Projects" "$PROJECTS_DIR" "PROJECTS_DIR variable"
test_var "$HOME/workspace" "$WORKSPACE_DIR" "WORKSPACE_DIR variable"
test_var "vim" "$GIT_EDITOR" "GIT_EDITOR variable"
test_var "less" "$GIT_PAGER" "GIT_PAGER variable"
test_var "$HOME/.local/bin" "$LOCAL_BIN" "LOCAL_BIN variable"
test_var "$HOME/.cargo/bin" "$CARGO_BIN" "CARGO_BIN variable"
test_var "$HOME/go/bin" "$GO_BIN" "GO_BIN variable"
test_var "myproject" "$COMPOSE_PROJECT_NAME" "COMPOSE_PROJECT_NAME variable"
test_var "/usr/local/bin:/opt/bin:$HOME/.local/bin" "$PATH_TEST" "PATH_TEST variable"
echo ""

# Test 37-46: Application configurations
echo "Testing application configurations..."
test_var "postgresql://localhost:5432/mydb" "$DATABASE_URL" "DATABASE_URL variable"
test_var "redis://localhost:6379" "$REDIS_URL" "REDIS_URL variable"
test_var "mongodb://localhost:27017/mydb" "$MONGODB_URL" "MONGODB_URL variable"
test_var "your_api_key_here" "$API_KEY" "API_KEY variable"
test_var "your_jwt_secret_here" "$JWT_SECRET" "JWT_SECRET variable"
test_var "ghp_your_github_token_here" "$GITHUB_TOKEN" "GITHUB_TOKEN variable"
test_var "change_me_in_production" "$SECRET_KEY" "SECRET_KEY variable"
test_var "your_secure_password_here" "$DATABASE_PASSWORD" "DATABASE_PASSWORD variable"
test_var "replace_with_actual_token" "$API_TOKEN" "API_TOKEN variable"
test_var "localhost" "$DB_HOST_DEV" "DB_HOST_DEV variable"
echo ""

# Test 47-56: Special character handling
echo "Testing special character handling..."
test_var "$HOME/Documents/My Projects" "$DOCUMENTS_DIR" "DOCUMENTS_DIR with spaces"
test_var "value with spaces works" "$TEST_QUOTED" "TEST_QUOTED with spaces"
test_var "It's a beautiful day" "$MESSAGE_WITH_QUOTES" "MESSAGE_WITH_QUOTES with apostrophe"
test_var "SELECT * FROM users WHERE name = 'John'" "$SQL_QUERY" "SQL_QUERY with quotes"
test_var "{\"debug\": true, \"port\": 3000}" "$JSON_CONFIG" "JSON_CONFIG with JSON"
test_var "echo \"Hello World\"" "$COMMAND_WITH_QUOTES" "COMMAND_WITH_QUOTES with quotes"
test_var "He said \"It's working!\" with excitement" "$COMPLEX_MESSAGE" "COMPLEX_MESSAGE complex quotes"
test_var "C:\\Users\\Developer\\AppData\\Local" "$WINDOWS_PATH" "WINDOWS_PATH with backslashes"
test_var "\\d{4}-\\d{2}-\\d{2}" "$REGEX_PATTERN" "REGEX_PATTERN with regex"
test_var "!@#\$%^&*()_+-=[]{}|;:,.<>?" "$SPECIAL_CHARS_TEST" "SPECIAL_CHARS_TEST special characters"
echo ""

# Test 57-66: Unicode and international characters
echo "Testing Unicode and international characters..."
test_var "Welcome! 欢迎! Bienvenidos! Добро пожаловать!" "$WELCOME_MESSAGE" "WELCOME_MESSAGE Unicode"
test_var "✅ Ready to go! 🚀" "$EMOJI_STATUS" "EMOJI_STATUS emojis"
test_var "Supported: \$ € £ ¥ ₹ ₽" "$CURRENCY_SYMBOLS" "CURRENCY_SYMBOLS Unicode symbols"
test_var "$HOME/Documents/文档" "$DOCUMENTS_INTL" "DOCUMENTS_INTL Unicode path"
test_var "$HOME/Projets/项目" "$PROJECTS_INTL" "PROJECTS_INTL international path"
test_var "Testing: αβγ 中文 العربية русский 🎉" "$UNICODE_TEST" "UNICODE_TEST various Unicode"
test_var "basic_value_works" "$TEST_BASIC" "TEST_BASIC variable"
test_var "20000" "$HISTFILESIZE" "HISTFILESIZE variable"
test_var "ignoredups:erasedups" "$HISTCONTROL" "HISTCONTROL variable"
test_var "1" "$FISH_TERM24BIT" "FISH_TERM24BIT variable"
echo ""

# Test 67-76: Performance and optimization
echo "Testing performance and optimization..."
test_var "-Xmx2g -Xms1g" "$JAVA_OPTS" "JAVA_OPTS variable"
test_var "--max-old-space-size=4096" "$NODE_OPTIONS" "NODE_OPTIONS variable"
test_var "1" "$PYTHON_OPTIMIZE" "PYTHON_OPTIMIZE variable"
test_var "-j(nproc)" "$MAKEFLAGS" "MAKEFLAGS variable"
test_var "true" "$TEST_ENV" "TEST_ENV variable"
test_var "enabled" "$TESTING_MODE" "TESTING_MODE variable"
test_var "true" "$MOCK_EXTERNAL_APIS" "MOCK_EXTERNAL_APIS variable"
test_var "myapp:*" "$DEBUG" "DEBUG variable"
test_var "true" "$VERBOSE" "VERBOSE variable"
test_var "false" "$TRACE_ENABLED" "TRACE_ENABLED variable"
echo ""

# Test 77-79: Final variables
echo "Testing final variables..."
test_var "json" "$LOG_FORMAT" "LOG_FORMAT variable"
test_var "true" "$LOG_TIMESTAMP" "LOG_TIMESTAMP variable"
test_var "auto" "$LOG_COLOR" "LOG_COLOR variable"
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
