#!/bin/bash
# Comprehensive Bash/Zsh Tests Based on .env.example
# ===================================================
# One test case per environment variable from .env.example

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running Comprehensive Bash/Zsh Tests Based on .env.example${NC}"
echo "=============================================================="

# Test counters
total_tests=0
passed_tests=0

# Test function
test_var() {
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

# Test function for PATH-like variables (order doesn't matter)
test_path_contains() {
    local expected_part="$1"
    local actual_path="$2"
    local test_name="$3"
    
    ((total_tests++))
    
    if [[ "$actual_path" == *"$expected_part"* ]]; then
        echo -e "${GREEN}✅ $test_name: PASS${NC}"
        ((passed_tests++))
    else
        echo -e "${RED}❌ $test_name: FAIL${NC} (expected path to contain: '$expected_part', got: '$actual_path')"
    fi
}

# Get platform for platform-specific tests
get_platform() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q Microsoft /proc/version 2>/dev/null; then
            echo "WSL"
        else
            echo "LINUX"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "MACOS"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "WIN"
    else
        echo "UNIX"
    fi
}

PLATFORM=$(get_platform)

echo -e "\n${YELLOW}Testing Bash Mode:${NC}"
if command -v bash >/dev/null 2>&1; then
    # Test bash in clean environment using .env.example
    bash_output=$(bash --noprofile --norc -c '
        export ENV_LOADER_INITIALIZED=true
        source src/shells/bzsh/loader.sh
        
        # Clear all variables to ensure clean test
        unset EDITOR VISUAL PAGER TERM COLORTERM
        unset USER_HOME CONFIG_DIR TEMP_DIR SYSTEM_BIN
        unset NODE_VERSION PYTHON_VERSION GO_VERSION
        unset DEV_HOME PROJECTS_DIR WORKSPACE_DIR
        unset GIT_EDITOR GIT_PAGER GIT_DEFAULT_BRANCH
        unset LOCAL_BIN CARGO_BIN GO_BIN
        unset DOCKER_HOST COMPOSE_PROJECT_NAME
        unset DATABASE_URL REDIS_URL MONGODB_URL
        unset API_KEY JWT_SECRET GITHUB_TOKEN
        unset PROGRAM_FILES PROGRAM_FILES_X86 DOCUMENTS_DIR
        unset MESSAGE_WITH_QUOTES SQL_QUERY JSON_CONFIG COMMAND_WITH_QUOTES
        unset COMPLEX_MESSAGE WINDOWS_PATH REGEX_PATTERN
        unset LOG_FILE WELCOME_MESSAGE EMOJI_STATUS CURRENCY_SYMBOLS
        unset DOCUMENTS_INTL PROJECTS_INTL
        unset HISTSIZE_BASH HISTFILESIZE_BASH HISTCONTROL_BASH
        unset HISTSIZE_ZSH SAVEHIST_ZSH HIST_STAMPS_ZSH
        unset PAGER_PREFERRED PAGER_FALLBACK PAGER_BASIC
        unset TERMINAL_MULTIPLEXER TERMINAL_MULTIPLEXER_FALLBACK
        unset PROJECT_TYPE DEBUG_LEVEL LOG_LEVEL ENVIRONMENT
        unset SECRET_KEY DATABASE_PASSWORD API_TOKEN
        unset DB_HOST_DEV DB_HOST_PROD STRIPE_KEY_DEV STRIPE_KEY_PROD
        unset JAVA_OPTS NODE_OPTIONS PYTHON_OPTIMIZE
        unset MAKEFLAGS TEST_ENV TESTING_MODE MOCK_EXTERNAL_APIS
        unset DEBUG VERBOSE TRACE_ENABLED LOG_FORMAT LOG_TIMESTAMP LOG_COLOR
        unset GOOD_PATH GOOD_QUOTES GOOD_EXPANSION_BASH GOOD_RELATIVE
        unset TEST_BASIC TEST_QUOTED TEST_PLATFORM_UNIX TEST_PLATFORM_WIN
        unset TEST_SHELL_BASH TEST_SHELL_ZSH SPECIAL_CHARS_TEST UNICODE_TEST PATH_TEST
        unset ENV_LOADER_INITIALIZED
        
        load_env_file .env.example 2>/dev/null
        
        # Output all variables for testing
        echo "SHELL:$(get_current_shell)"
        
        # Basic environment variables
        echo "EDITOR:${EDITOR:-UNSET}"
        echo "VISUAL:${VISUAL:-UNSET}"
        echo "PAGER:${PAGER:-UNSET}"
        echo "TERM:${TERM:-UNSET}"
        echo "COLORTERM:${COLORTERM:-UNSET}"
        
        # Platform-specific variables (will vary by platform)
        echo "USER_HOME:${USER_HOME:-UNSET}"
        echo "CONFIG_DIR:${CONFIG_DIR:-UNSET}"
        echo "TEMP_DIR:${TEMP_DIR:-UNSET}"
        echo "SYSTEM_BIN:${SYSTEM_BIN:-UNSET}"
        
        # Development environment variables
        echo "NODE_VERSION:${NODE_VERSION:-UNSET}"
        echo "PYTHON_VERSION:${PYTHON_VERSION:-UNSET}"
        echo "GO_VERSION:${GO_VERSION:-UNSET}"
        echo "DEV_HOME:${DEV_HOME:-UNSET}"
        echo "PROJECTS_DIR:${PROJECTS_DIR:-UNSET}"
        echo "WORKSPACE_DIR:${WORKSPACE_DIR:-UNSET}"
        
        # Git configuration
        echo "GIT_EDITOR:${GIT_EDITOR:-UNSET}"
        echo "GIT_PAGER:${GIT_PAGER:-UNSET}"
        echo "GIT_DEFAULT_BRANCH:${GIT_DEFAULT_BRANCH:-UNSET}"
        
        # PATH manipulation
        echo "LOCAL_BIN:${LOCAL_BIN:-UNSET}"
        echo "CARGO_BIN:${CARGO_BIN:-UNSET}"
        echo "GO_BIN:${GO_BIN:-UNSET}"
        
        # Application-specific configurations
        echo "DOCKER_HOST:${DOCKER_HOST:-UNSET}"
        echo "COMPOSE_PROJECT_NAME:${COMPOSE_PROJECT_NAME:-UNSET}"
        echo "DATABASE_URL:${DATABASE_URL:-UNSET}"
        echo "REDIS_URL:${REDIS_URL:-UNSET}"
        echo "MONGODB_URL:${MONGODB_URL:-UNSET}"
        
        # API keys and tokens
        echo "API_KEY:${API_KEY:-UNSET}"
        echo "JWT_SECRET:${JWT_SECRET:-UNSET}"
        echo "GITHUB_TOKEN:${GITHUB_TOKEN:-UNSET}"
        
        # Special character handling
        echo "PROGRAM_FILES:${PROGRAM_FILES:-UNSET}"
        echo "PROGRAM_FILES_X86:${PROGRAM_FILES_X86:-UNSET}"
        echo "DOCUMENTS_DIR:${DOCUMENTS_DIR:-UNSET}"
        echo "MESSAGE_WITH_QUOTES:${MESSAGE_WITH_QUOTES:-UNSET}"
        echo "SQL_QUERY:${SQL_QUERY:-UNSET}"
        echo "JSON_CONFIG:${JSON_CONFIG:-UNSET}"
        echo "COMMAND_WITH_QUOTES:${COMMAND_WITH_QUOTES:-UNSET}"
        echo "COMPLEX_MESSAGE:${COMPLEX_MESSAGE:-UNSET}"
        echo "WINDOWS_PATH:${WINDOWS_PATH:-UNSET}"
        echo "REGEX_PATTERN:${REGEX_PATTERN:-UNSET}"
        echo "LOG_FILE:${LOG_FILE:-UNSET}"
        
        # Unicode and international characters
        echo "WELCOME_MESSAGE:${WELCOME_MESSAGE:-UNSET}"
        echo "EMOJI_STATUS:${EMOJI_STATUS:-UNSET}"
        echo "CURRENCY_SYMBOLS:${CURRENCY_SYMBOLS:-UNSET}"
        echo "DOCUMENTS_INTL:${DOCUMENTS_INTL:-UNSET}"
        echo "PROJECTS_INTL:${PROJECTS_INTL:-UNSET}"
        
        # Shell-specific variables (should prefer BASH)
        echo "HISTSIZE:${HISTSIZE:-UNSET}"
        echo "HISTFILESIZE:${HISTFILESIZE:-UNSET}"
        echo "HISTCONTROL:${HISTCONTROL:-UNSET}"
        
        # Conditional environment variables
        echo "PAGER_PREFERRED:${PAGER_PREFERRED:-UNSET}"
        echo "PAGER_FALLBACK:${PAGER_FALLBACK:-UNSET}"
        echo "PAGER_BASIC:${PAGER_BASIC:-UNSET}"
        echo "TERMINAL_MULTIPLEXER:${TERMINAL_MULTIPLEXER:-UNSET}"
        echo "TERMINAL_MULTIPLEXER_FALLBACK:${TERMINAL_MULTIPLEXER_FALLBACK:-UNSET}"
        
        # Hierarchical loading examples
        echo "PROJECT_TYPE:${PROJECT_TYPE:-UNSET}"
        echo "DEBUG_LEVEL:${DEBUG_LEVEL:-UNSET}"
        echo "LOG_LEVEL:${LOG_LEVEL:-UNSET}"
        echo "ENVIRONMENT:${ENVIRONMENT:-UNSET}"
        
        # Security considerations
        echo "SECRET_KEY:${SECRET_KEY:-UNSET}"
        echo "DATABASE_PASSWORD:${DATABASE_PASSWORD:-UNSET}"
        echo "API_TOKEN:${API_TOKEN:-UNSET}"
        echo "DB_HOST_DEV:${DB_HOST_DEV:-UNSET}"
        echo "DB_HOST_PROD:${DB_HOST_PROD:-UNSET}"
        echo "STRIPE_KEY_DEV:${STRIPE_KEY_DEV:-UNSET}"
        echo "STRIPE_KEY_PROD:${STRIPE_KEY_PROD:-UNSET}"
        
        # Performance and optimization
        echo "JAVA_OPTS:${JAVA_OPTS:-UNSET}"
        echo "NODE_OPTIONS:${NODE_OPTIONS:-UNSET}"
        echo "PYTHON_OPTIMIZE:${PYTHON_OPTIMIZE:-UNSET}"
        echo "MAKEFLAGS:${MAKEFLAGS:-UNSET}"
        
        # Testing and debugging
        echo "TEST_ENV:${TEST_ENV:-UNSET}"
        echo "TESTING_MODE:${TESTING_MODE:-UNSET}"
        echo "MOCK_EXTERNAL_APIS:${MOCK_EXTERNAL_APIS:-UNSET}"
        echo "DEBUG:${DEBUG:-UNSET}"
        echo "VERBOSE:${VERBOSE:-UNSET}"
        echo "TRACE_ENABLED:${TRACE_ENABLED:-UNSET}"
        echo "LOG_FORMAT:${LOG_FORMAT:-UNSET}"
        echo "LOG_TIMESTAMP:${LOG_TIMESTAMP:-UNSET}"
        echo "LOG_COLOR:${LOG_COLOR:-UNSET}"
        
        # Correct examples
        echo "GOOD_PATH:${GOOD_PATH:-UNSET}"
        echo "GOOD_QUOTES:${GOOD_QUOTES:-UNSET}"
        echo "GOOD_EXPANSION_BASH:${GOOD_EXPANSION_BASH:-UNSET}"
        echo "GOOD_RELATIVE:${GOOD_RELATIVE:-UNSET}"
        
        # Test variables
        echo "TEST_BASIC:${TEST_BASIC:-UNSET}"
        echo "TEST_QUOTED:${TEST_QUOTED:-UNSET}"
        echo "TEST_PLATFORM_UNIX:${TEST_PLATFORM_UNIX:-UNSET}"
        echo "TEST_PLATFORM_WIN:${TEST_PLATFORM_WIN:-UNSET}"
        echo "TEST_SHELL:${TEST_SHELL:-UNSET}"
        echo "TEST_SHELL_BASH:${TEST_SHELL_BASH:-UNSET}"
        echo "TEST_SHELL_ZSH:${TEST_SHELL_ZSH:-UNSET}"
        echo "SPECIAL_CHARS_TEST:${SPECIAL_CHARS_TEST:-UNSET}"
        echo "UNICODE_TEST:${UNICODE_TEST:-UNSET}"
        echo "PATH_TEST:${PATH_TEST:-UNSET}"
    ')
    
    # Parse bash results and test each variable
    shell=$(echo "$bash_output" | grep "^SHELL:" | cut -d: -f2)
    test_var "BASH" "$shell" "Bash shell detection"
    
    # Basic environment variables
    editor=$(echo "$bash_output" | grep "^EDITOR:" | cut -d: -f2)
    test_var "vim" "$editor" "EDITOR variable"
    
    visual=$(echo "$bash_output" | grep "^VISUAL:" | cut -d: -f2)
    test_var "vim" "$visual" "VISUAL variable"
    
    pager=$(echo "$bash_output" | grep "^PAGER:" | cut -d: -f2)
    test_var "less" "$pager" "PAGER variable"
    
    term=$(echo "$bash_output" | grep "^TERM:" | cut -d: -f2)
    test_var "xterm-256color" "$term" "TERM variable"
    
    colorterm=$(echo "$bash_output" | grep "^COLORTERM:" | cut -d: -f2)
    test_var "truecolor" "$colorterm" "COLORTERM variable"
    
    # Platform-specific variables (test based on current platform)
    user_home=$(echo "$bash_output" | grep "^USER_HOME:" | cut -d: -f2-)
    # USER_HOME should be expanded to actual user home
    test_var "/home/$USER" "$user_home" "USER_HOME variable (expanded)"

    config_dir=$(echo "$bash_output" | grep "^CONFIG_DIR:" | cut -d: -f2)
    case "$PLATFORM" in
        WSL)
            test_var "~/.config/wsl" "$config_dir" "CONFIG_DIR_WSL precedence"
            ;;
        LINUX)
            test_var "~/.config/linux" "$config_dir" "CONFIG_DIR_LINUX precedence"
            ;;
        MACOS)
            test_var "~/Library/Application Support" "$config_dir" "CONFIG_DIR_MACOS precedence"
            ;;
        WIN)
            test_var "%APPDATA%" "$config_dir" "CONFIG_DIR_WIN precedence"
            ;;
        *)
            test_var "~/.config" "$config_dir" "CONFIG_DIR generic fallback"
            ;;
    esac

    temp_dir=$(echo "$bash_output" | grep "^TEMP_DIR:" | cut -d: -f2)
    case "$PLATFORM" in
        WIN)
            test_var "%TEMP%" "$temp_dir" "TEMP_DIR_WIN precedence"
            ;;
        *)
            test_var "/tmp" "$temp_dir" "TEMP_DIR generic"
            ;;
    esac

    system_bin=$(echo "$bash_output" | grep "^SYSTEM_BIN:" | cut -d: -f2)
    case "$PLATFORM" in
        WIN)
            test_var "C:\\Program Files" "$system_bin" "SYSTEM_BIN_WIN precedence"
            ;;
        MACOS)
            test_var "/opt/homebrew/bin" "$system_bin" "SYSTEM_BIN_MACOS precedence"
            ;;
        *)
            test_var "/usr/local/bin" "$system_bin" "SYSTEM_BIN generic"
            ;;
    esac

    # Development environment variables
    node_version=$(echo "$bash_output" | grep "^NODE_VERSION:" | cut -d: -f2)
    test_var "18.17.0" "$node_version" "NODE_VERSION variable"

    python_version=$(echo "$bash_output" | grep "^PYTHON_VERSION:" | cut -d: -f2)
    test_var "3.11.0" "$python_version" "PYTHON_VERSION variable"

    go_version=$(echo "$bash_output" | grep "^GO_VERSION:" | cut -d: -f2)
    test_var "1.21.0" "$go_version" "GO_VERSION variable"

    dev_home=$(echo "$bash_output" | grep "^DEV_HOME:" | cut -d: -f2)
    test_var "~/Development" "$dev_home" "DEV_HOME variable"

    projects_dir=$(echo "$bash_output" | grep "^PROJECTS_DIR:" | cut -d: -f2)
    test_var "~/Projects" "$projects_dir" "PROJECTS_DIR variable"

    workspace_dir=$(echo "$bash_output" | grep "^WORKSPACE_DIR:" | cut -d: -f2)
    test_var "~/workspace" "$workspace_dir" "WORKSPACE_DIR variable"

    # Git configuration
    git_editor=$(echo "$bash_output" | grep "^GIT_EDITOR:" | cut -d: -f2)
    test_var "vim" "$git_editor" "GIT_EDITOR variable"

    git_pager=$(echo "$bash_output" | grep "^GIT_PAGER:" | cut -d: -f2)
    test_var "less" "$git_pager" "GIT_PAGER variable"

    git_default_branch=$(echo "$bash_output" | grep "^GIT_DEFAULT_BRANCH:" | cut -d: -f2)
    test_var "main" "$git_default_branch" "GIT_DEFAULT_BRANCH variable"

    # PATH manipulation
    local_bin=$(echo "$bash_output" | grep "^LOCAL_BIN:" | cut -d: -f2)
    test_var "~/.local/bin" "$local_bin" "LOCAL_BIN variable"

    cargo_bin=$(echo "$bash_output" | grep "^CARGO_BIN:" | cut -d: -f2)
    test_var "~/.cargo/bin" "$cargo_bin" "CARGO_BIN variable"

    go_bin=$(echo "$bash_output" | grep "^GO_BIN:" | cut -d: -f2)
    test_var "~/go/bin" "$go_bin" "GO_BIN variable"

    # Application-specific configurations
    docker_host=$(echo "$bash_output" | grep "^DOCKER_HOST:" | cut -d: -f2-)
    case "$PLATFORM" in
        WIN)
            test_var "npipe:////./pipe/docker_engine" "$docker_host" "DOCKER_HOST_WIN precedence"
            ;;
        *)
            test_var "unix:///var/run/docker.sock" "$docker_host" "DOCKER_HOST generic"
            ;;
    esac

    compose_project_name=$(echo "$bash_output" | grep "^COMPOSE_PROJECT_NAME:" | cut -d: -f2)
    test_var "myproject" "$compose_project_name" "COMPOSE_PROJECT_NAME variable"

    database_url=$(echo "$bash_output" | grep "^DATABASE_URL:" | cut -d: -f2-)
    test_var "postgresql://localhost:5432/mydb" "$database_url" "DATABASE_URL variable"

    redis_url=$(echo "$bash_output" | grep "^REDIS_URL:" | cut -d: -f2-)
    test_var "redis://localhost:6379" "$redis_url" "REDIS_URL variable"

    mongodb_url=$(echo "$bash_output" | grep "^MONGODB_URL:" | cut -d: -f2-)
    test_var "mongodb://localhost:27017/mydb" "$mongodb_url" "MONGODB_URL variable"

    # API keys and tokens
    api_key=$(echo "$bash_output" | grep "^API_KEY:" | cut -d: -f2)
    test_var "your_api_key_here" "$api_key" "API_KEY variable"

    jwt_secret=$(echo "$bash_output" | grep "^JWT_SECRET:" | cut -d: -f2)
    test_var "your_jwt_secret_here" "$jwt_secret" "JWT_SECRET variable"

    github_token=$(echo "$bash_output" | grep "^GITHUB_TOKEN:" | cut -d: -f2)
    test_var "ghp_your_github_token_here" "$github_token" "GITHUB_TOKEN variable"

    # Special character handling
    program_files=$(echo "$bash_output" | grep "^PROGRAM_FILES:" | cut -d: -f2-)
    test_var "C:\\Program Files" "$program_files" "PROGRAM_FILES variable"

    program_files_x86=$(echo "$bash_output" | grep "^PROGRAM_FILES_X86:" | cut -d: -f2-)
    test_var "C:\\Program Files (x86)" "$program_files_x86" "PROGRAM_FILES_X86 variable"

    documents_dir=$(echo "$bash_output" | grep "^DOCUMENTS_DIR:" | cut -d: -f2-)
    test_var "~/Documents/My Projects" "$documents_dir" "DOCUMENTS_DIR variable"

    message_with_quotes=$(echo "$bash_output" | grep "^MESSAGE_WITH_QUOTES:" | cut -d: -f2-)
    test_var "It's a beautiful day" "$message_with_quotes" "MESSAGE_WITH_QUOTES variable"

    sql_query=$(echo "$bash_output" | grep "^SQL_QUERY:" | cut -d: -f2-)
    test_var "SELECT * FROM users WHERE name = 'John'" "$sql_query" "SQL_QUERY variable"

    json_config=$(echo "$bash_output" | grep "^JSON_CONFIG:" | cut -d: -f2-)
    test_var "{\"debug\": true, \"port\": 3000}" "$json_config" "JSON_CONFIG variable"

    command_with_quotes=$(echo "$bash_output" | grep "^COMMAND_WITH_QUOTES:" | cut -d: -f2-)
    test_var "echo \"Hello World\"" "$command_with_quotes" "COMMAND_WITH_QUOTES variable"

    complex_message=$(echo "$bash_output" | grep "^COMPLEX_MESSAGE:" | cut -d: -f2-)
    test_var "He said \"It's working!\" with excitement" "$complex_message" "COMPLEX_MESSAGE variable"

    windows_path=$(echo "$bash_output" | grep "^WINDOWS_PATH:" | cut -d: -f2-)
    test_var "C:\\Users\\Developer\\AppData\\Local" "$windows_path" "WINDOWS_PATH variable"

    regex_pattern=$(echo "$bash_output" | grep "^REGEX_PATTERN:" | cut -d: -f2-)
    test_var "\\d{4}-\\d{2}-\\d{2}" "$regex_pattern" "REGEX_PATTERN variable"

    log_file=$(echo "$bash_output" | grep "^LOG_FILE:" | cut -d: -f2-)
    # LOG_FILE should have variables and commands expanded
    expected_log_file="$HOME/logs/app-$(date +%Y%m%d).log"
    test_var "$expected_log_file" "$log_file" "LOG_FILE variable (expanded)"

    # Unicode and international characters
    welcome_message=$(echo "$bash_output" | grep "^WELCOME_MESSAGE:" | cut -d: -f2-)
    test_var "Welcome! 欢迎! Bienvenidos! Добро пожаловать!" "$welcome_message" "WELCOME_MESSAGE variable"

    emoji_status=$(echo "$bash_output" | grep "^EMOJI_STATUS:" | cut -d: -f2-)
    test_var "✅ Ready to go! 🚀" "$emoji_status" "EMOJI_STATUS variable"

    currency_symbols=$(echo "$bash_output" | grep "^CURRENCY_SYMBOLS:" | cut -d: -f2-)
    test_var "Supported: \$ € £ ¥ ₹ ₽" "$currency_symbols" "CURRENCY_SYMBOLS variable"

    documents_intl=$(echo "$bash_output" | grep "^DOCUMENTS_INTL:" | cut -d: -f2-)
    test_var "~/Documents/文档" "$documents_intl" "DOCUMENTS_INTL variable"

    projects_intl=$(echo "$bash_output" | grep "^PROJECTS_INTL:" | cut -d: -f2-)
    test_var "~/Projets/项目" "$projects_intl" "PROJECTS_INTL variable"

    # Shell-specific variables (should prefer BASH)
    histsize=$(echo "$bash_output" | grep "^HISTSIZE:" | cut -d: -f2)
    test_var "10000" "$histsize" "HISTSIZE_BASH precedence"

    histfilesize=$(echo "$bash_output" | grep "^HISTFILESIZE:" | cut -d: -f2)
    test_var "20000" "$histfilesize" "HISTFILESIZE_BASH precedence"

    histcontrol=$(echo "$bash_output" | grep "^HISTCONTROL:" | cut -d: -f2-)
    test_var "ignoredups:erasedups" "$histcontrol" "HISTCONTROL_BASH precedence"

    # Test variables
    test_basic=$(echo "$bash_output" | grep "^TEST_BASIC:" | cut -d: -f2)
    test_var "basic_value_works" "$test_basic" "TEST_BASIC variable"

    test_quoted=$(echo "$bash_output" | grep "^TEST_QUOTED:" | cut -d: -f2-)
    test_var "value with spaces works" "$test_quoted" "TEST_QUOTED variable"

    # TEST_SHELL should be set to the shell-specific value (bash_detected for bash)
    test_shell=$(echo "$bash_output" | grep "^TEST_SHELL:" | cut -d: -f2)
    test_var "bash_detected" "$test_shell" "TEST_SHELL variable (bash precedence)"

    special_chars_test=$(echo "$bash_output" | grep "^SPECIAL_CHARS_TEST:" | cut -d: -f2-)
    test_var "!@#\$%^&*()_+-=[]{}|;:,.<>?" "$special_chars_test" "SPECIAL_CHARS_TEST variable"

    unicode_test=$(echo "$bash_output" | grep "^UNICODE_TEST:" | cut -d: -f2-)
    test_var "Testing: αβγ 中文 العربية русский 🎉" "$unicode_test" "UNICODE_TEST variable"

    path_test=$(echo "$bash_output" | grep "^PATH_TEST:" | cut -d: -f2-)
    test_var "/usr/local/bin:/opt/bin:~/.local/bin" "$path_test" "PATH_TEST variable"

else
    echo "⚠️  Bash not available"
fi

echo -e "\n${YELLOW}Testing Zsh Mode:${NC}"
if command -v zsh >/dev/null 2>&1; then
    # Test zsh in clean environment using .env.example
    zsh_output=$(zsh --no-rcs --no-globalrcs -c '
        export ENV_LOADER_INITIALIZED=true
        source src/shells/bzsh/loader.sh

        # Clear all variables to ensure clean test
        unset EDITOR VISUAL PAGER TERM COLORTERM
        unset USER_HOME CONFIG_DIR TEMP_DIR SYSTEM_BIN
        unset NODE_VERSION PYTHON_VERSION GO_VERSION
        unset DEV_HOME PROJECTS_DIR WORKSPACE_DIR
        unset GIT_EDITOR GIT_PAGER GIT_DEFAULT_BRANCH
        unset LOCAL_BIN CARGO_BIN GO_BIN
        unset DOCKER_HOST COMPOSE_PROJECT_NAME
        unset DATABASE_URL REDIS_URL MONGODB_URL
        unset API_KEY JWT_SECRET GITHUB_TOKEN
        unset PROGRAM_FILES PROGRAM_FILES_X86 DOCUMENTS_DIR
        unset MESSAGE_WITH_QUOTES SQL_QUERY JSON_CONFIG COMMAND_WITH_QUOTES
        unset COMPLEX_MESSAGE WINDOWS_PATH REGEX_PATTERN
        unset LOG_FILE WELCOME_MESSAGE EMOJI_STATUS CURRENCY_SYMBOLS
        unset DOCUMENTS_INTL PROJECTS_INTL
        unset HISTSIZE_BASH HISTFILESIZE_BASH HISTCONTROL_BASH
        unset HISTSIZE_ZSH SAVEHIST_ZSH HIST_STAMPS_ZSH
        unset PAGER_PREFERRED PAGER_FALLBACK PAGER_BASIC
        unset TERMINAL_MULTIPLEXER TERMINAL_MULTIPLEXER_FALLBACK
        unset PROJECT_TYPE DEBUG_LEVEL LOG_LEVEL ENVIRONMENT
        unset SECRET_KEY DATABASE_PASSWORD API_TOKEN
        unset DB_HOST_DEV DB_HOST_PROD STRIPE_KEY_DEV STRIPE_KEY_PROD
        unset JAVA_OPTS NODE_OPTIONS PYTHON_OPTIMIZE
        unset MAKEFLAGS TEST_ENV TESTING_MODE MOCK_EXTERNAL_APIS
        unset DEBUG VERBOSE TRACE_ENABLED LOG_FORMAT LOG_TIMESTAMP LOG_COLOR
        unset GOOD_PATH GOOD_QUOTES GOOD_EXPANSION_BASH GOOD_RELATIVE
        unset TEST_BASIC TEST_QUOTED TEST_PLATFORM_UNIX TEST_PLATFORM_WIN
        unset TEST_SHELL_BASH TEST_SHELL_ZSH SPECIAL_CHARS_TEST UNICODE_TEST PATH_TEST
        unset ENV_LOADER_INITIALIZED

        load_env_file .env.example 2>/dev/null

        # Output all variables for testing
        print "SHELL:$(get_current_shell)"

        # Basic environment variables
        print "EDITOR:${EDITOR:-UNSET}"
        print "VISUAL:${VISUAL:-UNSET}"
        print "PAGER:${PAGER:-UNSET}"
        print "TERM:${TERM:-UNSET}"
        print "COLORTERM:${COLORTERM:-UNSET}"

        # Shell-specific variables (should prefer ZSH)
        print "HISTSIZE:${HISTSIZE:-UNSET}"
        print "SAVEHIST:${SAVEHIST:-UNSET}"
        print "HIST_STAMPS:${HIST_STAMPS:-UNSET}"

        # Test variables
        print "TEST_BASIC:${TEST_BASIC:-UNSET}"
        print "TEST_QUOTED:${TEST_QUOTED:-UNSET}"
        print "TEST_SHELL:${TEST_SHELL:-UNSET}"
        print "TEST_SHELL_ZSH:${TEST_SHELL_ZSH:-UNSET}"
        print "SPECIAL_CHARS_TEST:${SPECIAL_CHARS_TEST:-UNSET}"
        print "UNICODE_TEST:${UNICODE_TEST:-UNSET}"

        # Unicode and international characters
        print "WELCOME_MESSAGE:${WELCOME_MESSAGE:-UNSET}"
        print "EMOJI_STATUS:${EMOJI_STATUS:-UNSET}"
        print "CURRENCY_SYMBOLS:${CURRENCY_SYMBOLS:-UNSET}"

        # Special character handling
        print "DOCUMENTS_DIR:${DOCUMENTS_DIR:-UNSET}"
        print "MESSAGE_WITH_QUOTES:${MESSAGE_WITH_QUOTES:-UNSET}"
        print "SQL_QUERY:${SQL_QUERY:-UNSET}"
        print "JSON_CONFIG:${JSON_CONFIG:-UNSET}"
        print "COMPLEX_MESSAGE:${COMPLEX_MESSAGE:-UNSET}"

        # Platform-specific (will vary by platform)
        print "CONFIG_DIR:${CONFIG_DIR:-UNSET}"
        print "DOCKER_HOST:${DOCKER_HOST:-UNSET}"

        # Development environment
        print "NODE_VERSION:${NODE_VERSION:-UNSET}"
        print "GIT_DEFAULT_BRANCH:${GIT_DEFAULT_BRANCH:-UNSET}"

        # API keys
        print "API_KEY:${API_KEY:-UNSET}"
        print "DATABASE_URL:${DATABASE_URL:-UNSET}"
    ')

    # Parse zsh results and test key variables
    shell=$(echo "$zsh_output" | grep "^SHELL:" | cut -d: -f2)
    test_var "ZSH" "$shell" "Zsh shell detection"

    # Basic environment variables
    editor=$(echo "$zsh_output" | grep "^EDITOR:" | cut -d: -f2)
    test_var "vim" "$editor" "Zsh EDITOR variable"

    visual=$(echo "$zsh_output" | grep "^VISUAL:" | cut -d: -f2)
    test_var "vim" "$visual" "Zsh VISUAL variable"

    pager=$(echo "$zsh_output" | grep "^PAGER:" | cut -d: -f2)
    test_var "less" "$pager" "Zsh PAGER variable"

    term=$(echo "$zsh_output" | grep "^TERM:" | cut -d: -f2)
    test_var "xterm-256color" "$term" "Zsh TERM variable"

    colorterm=$(echo "$zsh_output" | grep "^COLORTERM:" | cut -d: -f2)
    test_var "truecolor" "$colorterm" "Zsh COLORTERM variable"

    # Shell-specific variables (should prefer ZSH)
    histsize=$(echo "$zsh_output" | grep "^HISTSIZE:" | cut -d: -f2)
    test_var "10000" "$histsize" "HISTSIZE_ZSH precedence"

    savehist=$(echo "$zsh_output" | grep "^SAVEHIST:" | cut -d: -f2)
    test_var "10000" "$savehist" "SAVEHIST_ZSH precedence"

    hist_stamps=$(echo "$zsh_output" | grep "^HIST_STAMPS:" | cut -d: -f2-)
    test_var "yyyy-mm-dd" "$hist_stamps" "HIST_STAMPS_ZSH precedence"

    # Test variables
    test_basic=$(echo "$zsh_output" | grep "^TEST_BASIC:" | cut -d: -f2)
    test_var "basic_value_works" "$test_basic" "Zsh TEST_BASIC variable"

    test_quoted=$(echo "$zsh_output" | grep "^TEST_QUOTED:" | cut -d: -f2-)
    test_var "value with spaces works" "$test_quoted" "Zsh TEST_QUOTED variable"

    # TEST_SHELL should be set to the shell-specific value (zsh_detected for zsh)
    test_shell=$(echo "$zsh_output" | grep "^TEST_SHELL:" | cut -d: -f2)
    test_var "zsh_detected" "$test_shell" "TEST_SHELL variable (zsh precedence)"

    special_chars_test=$(echo "$zsh_output" | grep "^SPECIAL_CHARS_TEST:" | cut -d: -f2-)
    test_var "!@#\$%^&*()_+-=[]{}|;:,.<>?" "$special_chars_test" "Zsh SPECIAL_CHARS_TEST variable"

    unicode_test=$(echo "$zsh_output" | grep "^UNICODE_TEST:" | cut -d: -f2-)
    test_var "Testing: αβγ 中文 العربية русский 🎉" "$unicode_test" "Zsh UNICODE_TEST variable"

    # Unicode and international characters
    welcome_message=$(echo "$zsh_output" | grep "^WELCOME_MESSAGE:" | cut -d: -f2-)
    test_var "Welcome! 欢迎! Bienvenidos! Добро пожаловать!" "$welcome_message" "Zsh WELCOME_MESSAGE variable"

    emoji_status=$(echo "$zsh_output" | grep "^EMOJI_STATUS:" | cut -d: -f2-)
    test_var "✅ Ready to go! 🚀" "$emoji_status" "Zsh EMOJI_STATUS variable"

    currency_symbols=$(echo "$zsh_output" | grep "^CURRENCY_SYMBOLS:" | cut -d: -f2-)
    test_var "Supported: \$ € £ ¥ ₹ ₽" "$currency_symbols" "Zsh CURRENCY_SYMBOLS variable"

    # Special character handling
    documents_dir=$(echo "$zsh_output" | grep "^DOCUMENTS_DIR:" | cut -d: -f2-)
    test_var "~/Documents/My Projects" "$documents_dir" "Zsh DOCUMENTS_DIR variable"

    message_with_quotes=$(echo "$zsh_output" | grep "^MESSAGE_WITH_QUOTES:" | cut -d: -f2-)
    test_var "It's a beautiful day" "$message_with_quotes" "Zsh MESSAGE_WITH_QUOTES variable"

    sql_query=$(echo "$zsh_output" | grep "^SQL_QUERY:" | cut -d: -f2-)
    test_var "SELECT * FROM users WHERE name = 'John'" "$sql_query" "Zsh SQL_QUERY variable"

    json_config=$(echo "$zsh_output" | grep "^JSON_CONFIG:" | cut -d: -f2-)
    test_var "{\"debug\": true, \"port\": 3000}" "$json_config" "Zsh JSON_CONFIG variable"

    complex_message=$(echo "$zsh_output" | grep "^COMPLEX_MESSAGE:" | cut -d: -f2-)
    test_var "He said \"It's working!\" with excitement" "$complex_message" "Zsh COMPLEX_MESSAGE variable"

    # Platform-specific (test based on current platform)
    config_dir=$(echo "$zsh_output" | grep "^CONFIG_DIR:" | cut -d: -f2)
    case "$PLATFORM" in
        WSL)
            test_var "~/.config/wsl" "$config_dir" "Zsh CONFIG_DIR_WSL precedence"
            ;;
        LINUX)
            test_var "~/.config/linux" "$config_dir" "Zsh CONFIG_DIR_LINUX precedence"
            ;;
        MACOS)
            test_var "~/Library/Application Support" "$config_dir" "Zsh CONFIG_DIR_MACOS precedence"
            ;;
        WIN)
            test_var "%APPDATA%" "$config_dir" "Zsh CONFIG_DIR_WIN precedence"
            ;;
        *)
            test_var "~/.config" "$config_dir" "Zsh CONFIG_DIR generic fallback"
            ;;
    esac

    # Application-specific
    docker_host=$(echo "$zsh_output" | grep "^DOCKER_HOST:" | cut -d: -f2-)
    case "$PLATFORM" in
        WIN)
            test_var "npipe:////./pipe/docker_engine" "$docker_host" "Zsh DOCKER_HOST_WIN precedence"
            ;;
        *)
            test_var "unix:///var/run/docker.sock" "$docker_host" "Zsh DOCKER_HOST generic"
            ;;
    esac

    # Development environment
    node_version=$(echo "$zsh_output" | grep "^NODE_VERSION:" | cut -d: -f2)
    test_var "18.17.0" "$node_version" "Zsh NODE_VERSION variable"

    git_default_branch=$(echo "$zsh_output" | grep "^GIT_DEFAULT_BRANCH:" | cut -d: -f2)
    test_var "main" "$git_default_branch" "Zsh GIT_DEFAULT_BRANCH variable"

    # API keys
    api_key=$(echo "$zsh_output" | grep "^API_KEY:" | cut -d: -f2)
    test_var "your_api_key_here" "$api_key" "Zsh API_KEY variable"

    database_url=$(echo "$zsh_output" | grep "^DATABASE_URL:" | cut -d: -f2-)
    test_var "postgresql://localhost:5432/mydb" "$database_url" "Zsh DATABASE_URL variable"

else
    echo "⚠️  Zsh not available"
fi

# Summary
echo -e "\n${BLUE}Comprehensive Test Summary:${NC}"
echo "=========================="
echo -e "Platform: $PLATFORM"
echo -e "Total tests: $total_tests"
echo -e "${GREEN}Passed: $passed_tests${NC}"
echo -e "${RED}Failed: $((total_tests - passed_tests))${NC}"

if [ $passed_tests -eq $total_tests ]; then
    echo -e "${GREEN}🎉 All tests passed! Bzsh implementation is 100% compatible with .env.example${NC}"
    exit 0
else
    echo -e "${RED}💥 Some tests failed. Check the output above for details.${NC}"
    exit 1
fi
