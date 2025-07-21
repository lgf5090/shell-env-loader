# Comprehensive Nushell Implementation Tests
# ===========================================
# Test suite for every variable in .env.example with proper precedence handling
# Following the same structure as test_bash_comprehensive.sh

print "Comprehensive Nushell Implementation Tests"
print "=========================================="

# Test framework setup - using environment variables for counters
$env.TEST_COUNT = "0"
$env.PASS_COUNT = "0"
$env.FAIL_COUNT = "0"

# Colors for output (Nushell style)
let red = "\u{001b}[31m"
let green = "\u{001b}[32m"
let yellow = "\u{001b}[33m"
let blue = "\u{001b}[34m"
let reset = "\u{001b}[0m"

# Get platform for platform-specific tests
def get_test_platform [] {
    let os_info = (sys host)
    let os_name = $os_info.name
    
    if ($os_name | str contains "Linux") {
        if ("/proc/version" | path exists) {
            let version = (open "/proc/version" | str contains "Microsoft")
            if $version { "WSL" } else { "LINUX" }
        } else { "LINUX" }
    } else if ($os_name | str contains "Darwin") {
        "MACOS"
    } else if ($os_name | str contains "Windows") {
        "WIN"
    } else {
        "UNIX"
    }
}

# Test helper function
def assert_env_var_set [var_name: string, expected_value: string, test_name: string] {
    $env.TEST_COUNT = (($env.TEST_COUNT | into int) + 1 | into string)
    
    let actual_value = match $var_name {
        "EDITOR" => ($env.EDITOR? | default "")
        "VISUAL" => ($env.VISUAL? | default "")
        "PAGER" => ($env.PAGER? | default "")
        "TERM" => ($env.TERM? | default "")
        "COLORTERM" => ($env.COLORTERM? | default "")
        "NODE_VERSION" => ($env.NODE_VERSION? | default "")
        "PYTHON_VERSION" => ($env.PYTHON_VERSION? | default "")
        "GO_VERSION" => ($env.GO_VERSION? | default "")
        "GIT_DEFAULT_BRANCH" => ($env.GIT_DEFAULT_BRANCH? | default "")
        "TEST_SHELL" => ($env.TEST_SHELL? | default "")
        "TEST_BASIC" => ($env.TEST_BASIC? | default "")
        "TEST_QUOTED" => ($env.TEST_QUOTED? | default "")
        "TEST_PLATFORM" => ($env.TEST_PLATFORM? | default "")
        "CONFIG_DIR" => ($env.CONFIG_DIR? | default "")
        "TEMP_DIR" => ($env.TEMP_DIR? | default "")
        "SYSTEM_BIN" => ($env.SYSTEM_BIN? | default "")
        "USER_HOME" => ($env.USER_HOME? | default "")
        "DEV_HOME" => ($env.DEV_HOME? | default "")
        "PROJECTS_DIR" => ($env.PROJECTS_DIR? | default "")
        "WORKSPACE_DIR" => ($env.WORKSPACE_DIR? | default "")
        "GIT_EDITOR" => ($env.GIT_EDITOR? | default "")
        "GIT_PAGER" => ($env.GIT_PAGER? | default "")
        "LOCAL_BIN" => ($env.LOCAL_BIN? | default "")
        "CARGO_BIN" => ($env.CARGO_BIN? | default "")
        "GO_BIN" => ($env.GO_BIN? | default "")
        "PATH_ADDITION" => ($env.PATH_ADDITION? | default "")
        "PATH_EXPORT" => ($env.PATH_EXPORT? | default "")
        "DOCKER_HOST" => ($env.DOCKER_HOST? | default "")
        "COMPOSE_PROJECT_NAME" => ($env.COMPOSE_PROJECT_NAME? | default "")
        "DATABASE_URL" => ($env.DATABASE_URL? | default "")
        "REDIS_URL" => ($env.REDIS_URL? | default "")
        "MONGODB_URL" => ($env.MONGODB_URL? | default "")
        "API_KEY" => ($env.API_KEY? | default "")
        "JWT_SECRET" => ($env.JWT_SECRET? | default "")
        "GITHUB_TOKEN" => ($env.GITHUB_TOKEN? | default "")
        "PROGRAM_FILES" => ($env.PROGRAM_FILES? | default "")
        "PROGRAM_FILES_X86" => ($env.PROGRAM_FILES_X86? | default "")
        "DOCUMENTS_DIR" => ($env.DOCUMENTS_DIR? | default "")
        "MESSAGE_WITH_QUOTES" => ($env.MESSAGE_WITH_QUOTES? | default "")
        "SQL_QUERY" => ($env.SQL_QUERY? | default "")
        "JSON_CONFIG" => ($env.JSON_CONFIG? | default "")
        "COMMAND_WITH_QUOTES" => ($env.COMMAND_WITH_QUOTES? | default "")
        "COMPLEX_MESSAGE" => ($env.COMPLEX_MESSAGE? | default "")
        "WINDOWS_PATH" => ($env.WINDOWS_PATH? | default "")
        "REGEX_PATTERN" => ($env.REGEX_PATTERN? | default "")
        "LOG_FILE" => ($env.LOG_FILE? | default "")
        "WELCOME_MESSAGE" => ($env.WELCOME_MESSAGE? | default "")
        "EMOJI_STATUS" => ($env.EMOJI_STATUS? | default "")
        "CURRENCY_SYMBOLS" => ($env.CURRENCY_SYMBOLS? | default "")
        "DOCUMENTS_INTL" => ($env.DOCUMENTS_INTL? | default "")
        "PROJECTS_INTL" => ($env.PROJECTS_INTL? | default "")
        "UNICODE_TEST" => ($env.UNICODE_TEST? | default "")
        "HISTSIZE" => ($env.HISTSIZE? | default "")
        "HISTFILESIZE" => ($env.HISTFILESIZE? | default "")
        "HISTCONTROL" => ($env.HISTCONTROL? | default "")
        "SAVEHIST" => ($env.SAVEHIST? | default "")
        "HIST_STAMPS" => ($env.HIST_STAMPS? | default "")
        "FISH_GREETING" => ($env.FISH_GREETING? | default "")
        "FISH_TERM24BIT" => ($env.FISH_TERM24BIT? | default "")
        "NU_CONFIG_DIR" => ($env.NU_CONFIG_DIR? | default "")
        "NU_PLUGIN_DIRS" => ($env.NU_PLUGIN_DIRS? | default "")
        "POWERSHELL_TELEMETRY_OPTOUT" => ($env.POWERSHELL_TELEMETRY_OPTOUT? | default "")
        "DOTNET_CLI_TELEMETRY_OPTOUT" => ($env.DOTNET_CLI_TELEMETRY_OPTOUT? | default "")
        "PAGER_PREFERRED" => ($env.PAGER_PREFERRED? | default "")
        "PAGER_FALLBACK" => ($env.PAGER_FALLBACK? | default "")
        "PAGER_BASIC" => ($env.PAGER_BASIC? | default "")
        "TERMINAL_MULTIPLEXER" => ($env.TERMINAL_MULTIPLEXER? | default "")
        "TERMINAL_MULTIPLEXER_FALLBACK" => ($env.TERMINAL_MULTIPLEXER_FALLBACK? | default "")
        "PROJECT_TYPE" => ($env.PROJECT_TYPE? | default "")
        "DEBUG_LEVEL" => ($env.DEBUG_LEVEL? | default "")
        "LOG_LEVEL" => ($env.LOG_LEVEL? | default "")
        "ENVIRONMENT" => ($env.ENVIRONMENT? | default "")
        "SECRET_KEY" => ($env.SECRET_KEY? | default "")
        "DATABASE_PASSWORD" => ($env.DATABASE_PASSWORD? | default "")
        "API_TOKEN" => ($env.API_TOKEN? | default "")
        "DB_HOST_DEV" => ($env.DB_HOST_DEV? | default "")
        "DB_HOST_PROD" => ($env.DB_HOST_PROD? | default "")
        "STRIPE_KEY_DEV" => ($env.STRIPE_KEY_DEV? | default "")
        "STRIPE_KEY_PROD" => ($env.STRIPE_KEY_PROD? | default "")
        "JAVA_OPTS" => ($env.JAVA_OPTS? | default "")
        "NODE_OPTIONS" => ($env.NODE_OPTIONS? | default "")
        "PYTHON_OPTIMIZE" => ($env.PYTHON_OPTIMIZE? | default "")
        "MAKEFLAGS" => ($env.MAKEFLAGS? | default "")
        "TEST_ENV" => ($env.TEST_ENV? | default "")
        "TESTING_MODE" => ($env.TESTING_MODE? | default "")
        "MOCK_EXTERNAL_APIS" => ($env.MOCK_EXTERNAL_APIS? | default "")
        "DEBUG" => ($env.DEBUG? | default "")
        "VERBOSE" => ($env.VERBOSE? | default "")
        "TRACE_ENABLED" => ($env.TRACE_ENABLED? | default "")
        "LOG_FORMAT" => ($env.LOG_FORMAT? | default "")
        "LOG_TIMESTAMP" => ($env.LOG_TIMESTAMP? | default "")
        "LOG_COLOR" => ($env.LOG_COLOR? | default "")
        "GOOD_PATH" => ($env.GOOD_PATH? | default "")
        "GOOD_QUOTES" => ($env.GOOD_QUOTES? | default "")
        "GOOD_EXPANSION" => ($env.GOOD_EXPANSION? | default "")
        "GOOD_RELATIVE" => ($env.GOOD_RELATIVE? | default "")
        "SPECIAL_CHARS_TEST" => ($env.SPECIAL_CHARS_TEST? | default "")
        "PATH_TEST" => ($env.PATH_TEST? | default "")
        _ => ""
    }
    
    if $actual_value == $expected_value {
        print $"($green)✅ PASS($reset): ($test_name)"
        $env.PASS_COUNT = (($env.PASS_COUNT | into int) + 1 | into string)
        return true
    } else {
        print $"($red)❌ FAIL($reset): ($test_name)"
        print $"   Variable: ($yellow)($var_name)($reset)"
        print $"   Expected: ($yellow)($expected_value)($reset)"
        print $"   Actual:   ($yellow)($actual_value)($reset)"
        $env.FAIL_COUNT = (($env.FAIL_COUNT | into int) + 1 | into string)
        return false
    }
}

# Test helper for PATH checking
def assert_path_contains [path_entry: string, test_name: string] {
    $env.TEST_COUNT = (($env.TEST_COUNT | into int) + 1 | into string)

    let found = ($env.PATH | any { |path| $path == $path_entry })
    if $found {
        print $"($green)✅ PASS($reset): ($test_name)"
        $env.PASS_COUNT = (($env.PASS_COUNT | into int) + 1 | into string)
        return true
    } else {
        print $"($red)❌ FAIL($reset): ($test_name)"
        print $"   Expected PATH to contain: ($yellow)($path_entry)($reset)"
        print $"   Current PATH: ($yellow)($env.PATH | str join ':')($reset)"
        $env.FAIL_COUNT = (($env.FAIL_COUNT | into int) + 1 | into string)
        return false
    }
}

# Test basic variables
def test_basic_variables [] {
    print "Testing basic variables..."

    assert_env_var_set "EDITOR" "vim" "EDITOR variable"
    assert_env_var_set "VISUAL" "vim" "VISUAL variable"
    assert_env_var_set "PAGER" "less" "PAGER variable"
    assert_env_var_set "TERM" "xterm-256color" "TERM variable"
    assert_env_var_set "COLORTERM" "truecolor" "COLORTERM variable"
    assert_env_var_set "NODE_VERSION" "18.17.0" "NODE_VERSION variable"
    assert_env_var_set "PYTHON_VERSION" "3.11.0" "PYTHON_VERSION variable"
    assert_env_var_set "GO_VERSION" "1.21.0" "GO_VERSION variable"
    assert_env_var_set "GIT_DEFAULT_BRANCH" "main" "GIT_DEFAULT_BRANCH variable"
}

# Test shell-specific variables (should only load NUSHELL variants)
def test_shell_specific_variables [] {
    print "Testing shell-specific variables..."

    # Should load NUSHELL-specific variables
    assert_env_var_set "TEST_SHELL" "nushell_detected" "TEST_SHELL_NU precedence"
    assert_env_var_set "HISTSIZE" "10000" "HISTSIZE variable"
    assert_env_var_set "SAVEHIST" "10000" "SAVEHIST variable"
    assert_env_var_set "HIST_STAMPS" "yyyy-mm-dd" "HIST_STAMPS variable"
    assert_env_var_set "NU_CONFIG_DIR" ($env.HOME + "/.config/nushell") "NU_CONFIG_DIR variable"
    assert_env_var_set "NU_PLUGIN_DIRS" ($env.HOME + "/.config/nushell/plugins") "NU_PLUGIN_DIRS variable"
}

# Test platform-specific variables
def test_platform_specific_variables [] {
    print "Testing platform-specific variables..."

    let platform = (get_test_platform)

    match $platform {
        "WSL" => {
            assert_env_var_set "CONFIG_DIR" ($env.HOME + "/.config/wsl") "CONFIG_DIR_WSL precedence on WSL"
            assert_env_var_set "TEST_PLATFORM" "unix_detected" "TEST_PLATFORM_UNIX on WSL"
        }
        "LINUX" => {
            assert_env_var_set "CONFIG_DIR" ($env.HOME + "/.config/linux") "CONFIG_DIR_LINUX precedence on Linux"
            assert_env_var_set "TEST_PLATFORM" "unix_detected" "TEST_PLATFORM_UNIX on Linux"
            assert_env_var_set "TEMP_DIR" "/tmp" "TEMP_DIR on Linux"
            assert_env_var_set "DOCKER_HOST" "unix:///var/run/docker.sock" "DOCKER_HOST on Linux"
        }
        "MACOS" => {
            assert_env_var_set "CONFIG_DIR" ($env.HOME + "/Library/Application Support") "CONFIG_DIR_MACOS precedence on macOS"
            assert_env_var_set "TEST_PLATFORM" "unix_detected" "TEST_PLATFORM_UNIX on macOS"
            assert_env_var_set "SYSTEM_BIN" "/opt/homebrew/bin" "SYSTEM_BIN_MACOS on macOS"
        }
        "WIN" => {
            assert_env_var_set "CONFIG_DIR" "%APPDATA%" "CONFIG_DIR_WIN precedence on Windows"
            assert_env_var_set "TEMP_DIR" "%TEMP%" "TEMP_DIR_WIN on Windows"
            assert_env_var_set "SYSTEM_BIN" "C:\\Program Files" "SYSTEM_BIN_WIN on Windows"
            assert_env_var_set "DOCKER_HOST" "npipe:////./pipe/docker_engine" "DOCKER_HOST_WIN on Windows"
        }
        _ => {
            assert_env_var_set "CONFIG_DIR" ($env.HOME + "/.config") "CONFIG_DIR generic fallback"
            assert_env_var_set "TEST_PLATFORM" "unix_detected" "TEST_PLATFORM_UNIX generic"
        }
    }
}

# Test PATH handling
def test_path_handling [] {
    print "Testing PATH handling..."

    let platform = (get_test_platform)

    # Test that PATH contains expected additions based on platform
    match $platform {
        "WSL" => {
            assert_path_contains "/usr/local/bin" "PATH contains /usr/local/bin on WSL"
            assert_path_contains "/snap/bin" "PATH contains /snap/bin on WSL"
            assert_path_contains "/tmp/test_wsl_path" "PATH contains WSL-specific path"
        }
        "LINUX" => {
            assert_path_contains "/usr/local/bin" "PATH contains /usr/local/bin on Linux"
            assert_path_contains "/snap/bin" "PATH contains /snap/bin on Linux"
            assert_path_contains "/tmp/test_linux_path" "PATH contains Linux-specific path"
        }
        "MACOS" => {
            assert_path_contains "/opt/homebrew/bin" "PATH contains Homebrew paths on macOS"
            assert_path_contains "/usr/local/bin" "PATH contains /usr/local/bin on macOS"
        }
        "WIN" => {
            # Windows PATH handling would be different
            print "Windows PATH testing not implemented yet"
        }
        _ => {
            assert_path_contains "/usr/local/bin" "PATH contains /usr/local/bin generic"
            assert_path_contains "/opt/bin" "PATH contains /opt/bin generic"
        }
    }

    # Test that common paths are in PATH
    assert_path_contains ($env.HOME + "/.local/bin") "PATH contains ~/.local/bin"
    assert_path_contains ($env.HOME + "/.cargo/bin") "PATH contains ~/.cargo/bin"
    assert_path_contains ($env.HOME + "/go/bin") "PATH contains ~/go/bin"
}

# Test special character handling
def test_special_characters [] {
    print "Testing special character handling..."

    assert_env_var_set "DOCUMENTS_DIR" ($env.HOME + "/Documents/My Projects") "DOCUMENTS_DIR with spaces"
    assert_env_var_set "TEST_QUOTED" "value with spaces works" "TEST_QUOTED with spaces"
    assert_env_var_set "GOOD_PATH" ($env.HOME + "/bin:/usr/local/bin") "GOOD_PATH with colons"
    assert_env_var_set "MESSAGE_WITH_QUOTES" "It's a beautiful day" "MESSAGE_WITH_QUOTES with apostrophe"
    assert_env_var_set "SQL_QUERY" "SELECT * FROM users WHERE name = 'John'" "SQL_QUERY with quotes"
    assert_env_var_set "JSON_CONFIG" "{\"debug\": true, \"port\": 3000}" "JSON_CONFIG with JSON"
    assert_env_var_set "COMMAND_WITH_QUOTES" "echo \"Hello World\"" "COMMAND_WITH_QUOTES with quotes"
    assert_env_var_set "COMPLEX_MESSAGE" "He said \"It's working!\" with excitement" "COMPLEX_MESSAGE complex quotes"
    assert_env_var_set "WINDOWS_PATH" "C:\\Users\\Developer\\AppData\\Local" "WINDOWS_PATH with backslashes"
    assert_env_var_set "REGEX_PATTERN" "\\d{4}-\\d{2}-\\d{2}" "REGEX_PATTERN with regex"
    assert_env_var_set "SPECIAL_CHARS_TEST" "!@#$%^&*()_+-=[]{}|;:,.<>?" "SPECIAL_CHARS_TEST special characters"
}

# Test Unicode and international characters
def test_unicode_characters [] {
    print "Testing Unicode and international characters..."

    assert_env_var_set "WELCOME_MESSAGE" "Welcome! 欢迎! Bienvenidos! Добро пожаловать!" "WELCOME_MESSAGE Unicode"
    assert_env_var_set "EMOJI_STATUS" "✅ Ready to go! 🚀" "EMOJI_STATUS emojis"
    assert_env_var_set "CURRENCY_SYMBOLS" "Supported: $ € £ ¥ ₹ ₽" "CURRENCY_SYMBOLS Unicode symbols"
    assert_env_var_set "DOCUMENTS_INTL" ($env.HOME + "/Documents/文档") "DOCUMENTS_INTL Unicode path"
    assert_env_var_set "PROJECTS_INTL" ($env.HOME + "/Projets/项目") "PROJECTS_INTL international path"
    assert_env_var_set "UNICODE_TEST" "Testing: αβγ 中文 العربية русский 🎉" "UNICODE_TEST various Unicode"
}

# Test application configurations
def test_application_configs [] {
    print "Testing application configurations..."

    assert_env_var_set "COMPOSE_PROJECT_NAME" "myproject" "COMPOSE_PROJECT_NAME variable"
    assert_env_var_set "DATABASE_URL" "postgresql://localhost:5432/myapp_dev" "DATABASE_URL variable"
    assert_env_var_set "REDIS_URL" "redis://localhost:6379" "REDIS_URL variable"
    assert_env_var_set "MONGODB_URL" "mongodb://localhost:27017/myapp_dev" "MONGODB_URL variable"
    assert_env_var_set "API_KEY" "your_api_key_here" "API_KEY variable"
    assert_env_var_set "JWT_SECRET" "your_jwt_secret_here" "JWT_SECRET variable"
    assert_env_var_set "GITHUB_TOKEN" "ghp_your_github_token_here" "GITHUB_TOKEN variable"
}

# Test development environment
def test_development_environment [] {
    print "Testing development environment..."

    assert_env_var_set "DEV_HOME" ($env.HOME + "/Development") "DEV_HOME variable"
    assert_env_var_set "PROJECTS_DIR" ($env.HOME + "/Projects") "PROJECTS_DIR variable"
    assert_env_var_set "WORKSPACE_DIR" ($env.HOME + "/workspace") "WORKSPACE_DIR variable"
    assert_env_var_set "GIT_EDITOR" "vim" "GIT_EDITOR variable"
    assert_env_var_set "GIT_PAGER" "less" "GIT_PAGER variable"
    assert_env_var_set "LOCAL_BIN" ($env.HOME + "/.local/bin") "LOCAL_BIN variable"
    assert_env_var_set "CARGO_BIN" ($env.HOME + "/.cargo/bin") "CARGO_BIN variable"
    assert_env_var_set "GO_BIN" ($env.HOME + "/go/bin") "GO_BIN variable"
}

# Test security and environment-specific variables
def test_security_variables [] {
    print "Testing security and environment-specific variables..."

    assert_env_var_set "SECRET_KEY" "your_secret_key_here" "SECRET_KEY variable"
    assert_env_var_set "DATABASE_PASSWORD" "your_db_password_here" "DATABASE_PASSWORD variable"
    assert_env_var_set "API_TOKEN" "your_api_token_here" "API_TOKEN variable"
    assert_env_var_set "DB_HOST_DEV" "localhost" "DB_HOST_DEV variable"
    assert_env_var_set "DB_HOST_PROD" "prod-db.example.com" "DB_HOST_PROD variable"
    assert_env_var_set "STRIPE_KEY_DEV" "sk_test_your_stripe_key" "STRIPE_KEY_DEV variable"
    assert_env_var_set "STRIPE_KEY_PROD" "sk_live_your_stripe_key" "STRIPE_KEY_PROD variable"
}

# Test performance and optimization variables
def test_performance_variables [] {
    print "Testing performance and optimization variables..."

    assert_env_var_set "JAVA_OPTS" "-Xmx2g -Xms1g" "JAVA_OPTS variable"
    assert_env_var_set "NODE_OPTIONS" "--max-old-space-size=4096" "NODE_OPTIONS variable"
    assert_env_var_set "PYTHON_OPTIMIZE" "1" "PYTHON_OPTIMIZE variable"
    assert_env_var_set "MAKEFLAGS" "-j4" "MAKEFLAGS variable"
}

# Test debugging and testing variables
def test_debugging_variables [] {
    print "Testing debugging and testing variables..."

    assert_env_var_set "TEST_ENV" "true" "TEST_ENV variable"
    assert_env_var_set "TESTING_MODE" "unit" "TESTING_MODE variable"
    assert_env_var_set "MOCK_EXTERNAL_APIS" "true" "MOCK_EXTERNAL_APIS variable"
    assert_env_var_set "DEBUG" "true" "DEBUG variable"
    assert_env_var_set "VERBOSE" "true" "VERBOSE variable"
    assert_env_var_set "TRACE_ENABLED" "false" "TRACE_ENABLED variable"
    assert_env_var_set "LOG_FORMAT" "json" "LOG_FORMAT variable"
    assert_env_var_set "LOG_TIMESTAMP" "true" "LOG_TIMESTAMP variable"
    assert_env_var_set "LOG_COLOR" "true" "LOG_COLOR variable"
}

# Test conditional and hierarchical variables
def test_conditional_variables [] {
    print "Testing conditional and hierarchical variables..."

    assert_env_var_set "PAGER_PREFERRED" "bat" "PAGER_PREFERRED variable"
    assert_env_var_set "PAGER_FALLBACK" "less" "PAGER_FALLBACK variable"
    assert_env_var_set "PAGER_BASIC" "more" "PAGER_BASIC variable"
    assert_env_var_set "TERMINAL_MULTIPLEXER" "tmux" "TERMINAL_MULTIPLEXER variable"
    assert_env_var_set "TERMINAL_MULTIPLEXER_FALLBACK" "screen" "TERMINAL_MULTIPLEXER_FALLBACK variable"
    assert_env_var_set "PROJECT_TYPE" "web" "PROJECT_TYPE variable"
    assert_env_var_set "DEBUG_LEVEL" "info" "DEBUG_LEVEL variable"
    assert_env_var_set "LOG_LEVEL" "warn" "LOG_LEVEL variable"
    assert_env_var_set "ENVIRONMENT" "development" "ENVIRONMENT variable"
}

# Test basic test variables
def test_basic_test_variables [] {
    print "Testing basic test variables..."

    assert_env_var_set "TEST_BASIC" "basic_value_works" "TEST_BASIC variable"
    assert_env_var_set "PATH_TEST" ($"/usr/local/bin:/opt/bin:($env.HOME)/.local/bin") "PATH_TEST variable"
}

# Main test runner
def run_all_tests [] {
    print $"($blue)Starting Comprehensive Nushell Tests($reset)"
    print "========================================"

    let platform = (get_test_platform)
    print $"Platform: ($platform)"
    print $"Shell: NUSHELL"
    print ""

    # Source the Nushell loader first
    print "Sourcing Nushell loader..."
    source "/home/lgf/Desktop/code/augment/shell-env-loader/src/shells/nu/loader.nu"

    # Load environment variables directly using the working load_env_file function
    print "Loading environment variables from .env.example..."
    load_env_file "/home/lgf/Desktop/code/augment/shell-env-loader/.env.example"
    print "Environment variables loaded successfully."
    print ""

    # Run test suites
    test_basic_variables
    print ""
    test_shell_specific_variables
    print ""
    test_platform_specific_variables
    print ""
    test_path_handling
    print ""
    test_special_characters
    print ""
    test_unicode_characters
    print ""
    test_application_configs
    print ""
    test_development_environment
    print ""
    test_security_variables
    print ""
    test_performance_variables
    print ""
    test_debugging_variables
    print ""
    test_conditional_variables
    print ""
    test_basic_test_variables
    print ""

    # Print summary
    print $"($blue)Test Summary:($reset)"
    print "============="
    print $"Total tests: ($env.TEST_COUNT)"
    print $"($green)Passed: ($env.PASS_COUNT)($reset)"
    print $"($red)Failed: ($env.FAIL_COUNT)($reset)"

    let fail_count = ($env.FAIL_COUNT | into int)
    if $fail_count == 0 {
        print $"($green)🎉 All tests passed! Nushell implementation is 100% compatible with .env.example($reset)"
        exit 0
    } else {
        print $"($red)💥 Some tests failed. Check the output above for details.($reset)"
        exit 1
    }
}

# Run tests
run_all_tests
