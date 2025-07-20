# Comprehensive Nushell Tests Based on .env.example
# ==================================================
# Complete test coverage for all environment variables from .env.example

print "Running Comprehensive Nushell Tests Based on .env.example"
print "=========================================================="

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

let platform = (get_test_platform)

# Source the Nushell loader
source "/home/lgf/Desktop/code/augment/shell-env-loader/src/shells/nu/loader.nu"

# Load environment variables
load_env_file "/home/lgf/Desktop/code/augment/shell-env-loader/.env.example"

# Comprehensive test cases covering all variables from .env.example
let tests = [
    # Shell and Platform Detection
    {name: "Nushell shell detection", expected: "NUSHELL", actual: (detect_shell)}
    {name: "Platform detection", expected: $platform, actual: (detect_platform)}
    
    # Basic environment variables
    {name: "EDITOR variable", expected: "vim", actual: ($env.EDITOR? | default "UNSET")}
    {name: "VISUAL variable", expected: "vim", actual: ($env.VISUAL? | default "UNSET")}
    {name: "PAGER variable", expected: "less", actual: ($env.PAGER? | default "UNSET")}
    {name: "TERM variable", expected: "xterm-256color", actual: ($env.TERM? | default "UNSET")}
    {name: "COLORTERM variable", expected: "truecolor", actual: ($env.COLORTERM? | default "UNSET")}
    
    # Platform-specific variables (test based on current platform)
    {name: "USER_HOME variable (expanded)", expected: $"/home/($env.USER)", actual: ($env.USER_HOME? | default "UNSET")}
    
    # Development environment variables
    {name: "NODE_VERSION variable", expected: "18.17.0", actual: ($env.NODE_VERSION? | default "UNSET")}
    {name: "PYTHON_VERSION variable", expected: "3.11.0", actual: ($env.PYTHON_VERSION? | default "UNSET")}
    {name: "GO_VERSION variable", expected: "1.21.0", actual: ($env.GO_VERSION? | default "UNSET")}
    {name: "DEV_HOME variable", expected: $"($env.HOME)/Development", actual: ($env.DEV_HOME? | default "UNSET")}
    {name: "PROJECTS_DIR variable", expected: $"($env.HOME)/Projects", actual: ($env.PROJECTS_DIR? | default "UNSET")}
    {name: "WORKSPACE_DIR variable", expected: $"($env.HOME)/workspace", actual: ($env.WORKSPACE_DIR? | default "UNSET")}
    
    # Git configuration
    {name: "GIT_EDITOR variable", expected: "vim", actual: ($env.GIT_EDITOR? | default "UNSET")}
    {name: "GIT_PAGER variable", expected: "less", actual: ($env.GIT_PAGER? | default "UNSET")}
    {name: "GIT_DEFAULT_BRANCH variable", expected: "main", actual: ($env.GIT_DEFAULT_BRANCH? | default "UNSET")}
    
    # PATH manipulation
    {name: "LOCAL_BIN variable", expected: $"($env.HOME)/.local/bin", actual: ($env.LOCAL_BIN? | default "UNSET")}
    {name: "CARGO_BIN variable", expected: $"($env.HOME)/.cargo/bin", actual: ($env.CARGO_BIN? | default "UNSET")}
    {name: "GO_BIN variable", expected: $"($env.HOME)/go/bin", actual: ($env.GO_BIN? | default "UNSET")}
    
    # Application-specific configurations
    {name: "COMPOSE_PROJECT_NAME variable", expected: "myproject", actual: ($env.COMPOSE_PROJECT_NAME? | default "UNSET")}
    {name: "DATABASE_URL variable", expected: "postgresql://localhost:5432/myapp_dev", actual: ($env.DATABASE_URL? | default "UNSET")}
    {name: "REDIS_URL variable", expected: "redis://localhost:6379", actual: ($env.REDIS_URL? | default "UNSET")}
    {name: "MONGODB_URL variable", expected: "mongodb://localhost:27017/myapp_dev", actual: ($env.MONGODB_URL? | default "UNSET")}
    
    # API keys and tokens
    {name: "API_KEY variable", expected: "your_api_key_here", actual: ($env.API_KEY? | default "UNSET")}
    {name: "JWT_SECRET variable", expected: "your_jwt_secret_here", actual: ($env.JWT_SECRET? | default "UNSET")}
    {name: "GITHUB_TOKEN variable", expected: "ghp_your_github_token_here", actual: ($env.GITHUB_TOKEN? | default "UNSET")}
    
    # Special character handling
    {name: "PROGRAM_FILES variable", expected: "C:\\Program Files", actual: ($env.PROGRAM_FILES? | default "UNSET")}
    {name: "PROGRAM_FILES_X86 variable", expected: "C:\\Program Files (x86)", actual: ($env.PROGRAM_FILES_X86? | default "UNSET")}
    {name: "DOCUMENTS_DIR variable", expected: $"($env.HOME)/Documents/My Projects", actual: ($env.DOCUMENTS_DIR? | default "UNSET")}
    {name: "MESSAGE_WITH_QUOTES variable", expected: "It's a beautiful day", actual: ($env.MESSAGE_WITH_QUOTES? | default "UNSET")}
    {name: "SQL_QUERY variable", expected: "SELECT * FROM users WHERE name = 'John'", actual: ($env.SQL_QUERY? | default "UNSET")}
    {name: "JSON_CONFIG variable", expected: "{\"debug\": true, \"port\": 3000}", actual: ($env.JSON_CONFIG? | default "UNSET")}
    {name: "COMMAND_WITH_QUOTES variable", expected: "echo \"Hello World\"", actual: ($env.COMMAND_WITH_QUOTES? | default "UNSET")}
    {name: "COMPLEX_MESSAGE variable", expected: "He said \"It's working!\" with excitement", actual: ($env.COMPLEX_MESSAGE? | default "UNSET")}
    {name: "WINDOWS_PATH variable", expected: "C:\\Users\\Developer\\AppData\\Local", actual: ($env.WINDOWS_PATH? | default "UNSET")}
    {name: "REGEX_PATTERN variable", expected: "\\d{4}-\\d{2}-\\d{2}", actual: ($env.REGEX_PATTERN? | default "UNSET")}
    
    # Unicode and international characters
    {name: "WELCOME_MESSAGE variable", expected: "Welcome! 欢迎! Bienvenidos! Добро пожаловать!", actual: ($env.WELCOME_MESSAGE? | default "UNSET")}
    {name: "EMOJI_STATUS variable", expected: "✅ Ready to go! 🚀", actual: ($env.EMOJI_STATUS? | default "UNSET")}
    {name: "CURRENCY_SYMBOLS variable", expected: "Supported: $ € £ ¥ ₹ ₽", actual: ($env.CURRENCY_SYMBOLS? | default "UNSET")}
    {name: "DOCUMENTS_INTL variable", expected: $"($env.HOME)/Documents/文档", actual: ($env.DOCUMENTS_INTL? | default "UNSET")}
    {name: "PROJECTS_INTL variable", expected: $"($env.HOME)/Projets/项目", actual: ($env.PROJECTS_INTL? | default "UNSET")}
    
    # Shell-specific variables (should prefer NUSHELL)
    {name: "HISTSIZE variable", expected: "10000", actual: ($env.HISTSIZE? | default "UNSET")}
    {name: "SAVEHIST variable", expected: "10000", actual: ($env.SAVEHIST? | default "UNSET")}
    {name: "HIST_STAMPS variable", expected: "yyyy-mm-dd", actual: ($env.HIST_STAMPS? | default "UNSET")}
    
    # Conditional environment variables
    {name: "PAGER_PREFERRED variable", expected: "bat", actual: ($env.PAGER_PREFERRED? | default "UNSET")}
    {name: "PAGER_FALLBACK variable", expected: "less", actual: ($env.PAGER_FALLBACK? | default "UNSET")}
    {name: "PAGER_BASIC variable", expected: "more", actual: ($env.PAGER_BASIC? | default "UNSET")}
    {name: "TERMINAL_MULTIPLEXER variable", expected: "tmux", actual: ($env.TERMINAL_MULTIPLEXER? | default "UNSET")}
    {name: "TERMINAL_MULTIPLEXER_FALLBACK variable", expected: "screen", actual: ($env.TERMINAL_MULTIPLEXER_FALLBACK? | default "UNSET")}
    
    # Hierarchical loading examples
    {name: "PROJECT_TYPE variable", expected: "web", actual: ($env.PROJECT_TYPE? | default "UNSET")}
    {name: "DEBUG_LEVEL variable", expected: "info", actual: ($env.DEBUG_LEVEL? | default "UNSET")}
    {name: "LOG_LEVEL variable", expected: "warn", actual: ($env.LOG_LEVEL? | default "UNSET")}
    {name: "ENVIRONMENT variable", expected: "development", actual: ($env.ENVIRONMENT? | default "UNSET")}
    
    # Security considerations
    {name: "SECRET_KEY variable", expected: "your_secret_key_here", actual: ($env.SECRET_KEY? | default "UNSET")}
    {name: "DATABASE_PASSWORD variable", expected: "your_db_password_here", actual: ($env.DATABASE_PASSWORD? | default "UNSET")}
    {name: "API_TOKEN variable", expected: "your_api_token_here", actual: ($env.API_TOKEN? | default "UNSET")}
    {name: "DB_HOST_DEV variable", expected: "localhost", actual: ($env.DB_HOST_DEV? | default "UNSET")}
    {name: "DB_HOST_PROD variable", expected: "prod-db.example.com", actual: ($env.DB_HOST_PROD? | default "UNSET")}
    {name: "STRIPE_KEY_DEV variable", expected: "sk_test_your_stripe_key", actual: ($env.STRIPE_KEY_DEV? | default "UNSET")}
    {name: "STRIPE_KEY_PROD variable", expected: "sk_live_your_stripe_key", actual: ($env.STRIPE_KEY_PROD? | default "UNSET")}
    
    # Performance and optimization
    {name: "JAVA_OPTS variable", expected: "-Xmx2g -Xms1g", actual: ($env.JAVA_OPTS? | default "UNSET")}
    {name: "NODE_OPTIONS variable", expected: "--max-old-space-size=4096", actual: ($env.NODE_OPTIONS? | default "UNSET")}
    {name: "PYTHON_OPTIMIZE variable", expected: "1", actual: ($env.PYTHON_OPTIMIZE? | default "UNSET")}
    {name: "MAKEFLAGS variable", expected: "-j4", actual: ($env.MAKEFLAGS? | default "UNSET")}
    
    # Testing and debugging
    {name: "TEST_ENV variable", expected: "true", actual: ($env.TEST_ENV? | default "UNSET")}
    {name: "TESTING_MODE variable", expected: "unit", actual: ($env.TESTING_MODE? | default "UNSET")}
    {name: "MOCK_EXTERNAL_APIS variable", expected: "true", actual: ($env.MOCK_EXTERNAL_APIS? | default "UNSET")}
    {name: "DEBUG variable", expected: "true", actual: ($env.DEBUG? | default "UNSET")}
    {name: "VERBOSE variable", expected: "true", actual: ($env.VERBOSE? | default "UNSET")}
    {name: "TRACE_ENABLED variable", expected: "false", actual: ($env.TRACE_ENABLED? | default "UNSET")}
    {name: "LOG_FORMAT variable", expected: "json", actual: ($env.LOG_FORMAT? | default "UNSET")}
    {name: "LOG_TIMESTAMP variable", expected: "true", actual: ($env.LOG_TIMESTAMP? | default "UNSET")}
    {name: "LOG_COLOR variable", expected: "true", actual: ($env.LOG_COLOR? | default "UNSET")}
    
    # Correct examples
    {name: "GOOD_PATH variable", expected: $"($env.HOME)/bin:/usr/local/bin", actual: ($env.GOOD_PATH? | default "UNSET")}
    {name: "GOOD_QUOTES variable", expected: "He said \"Hello\"", actual: ($env.GOOD_QUOTES? | default "UNSET")}
    {name: "GOOD_EXPANSION_BASH variable", expected: $"($env.HOME)/scripts", actual: ($env.GOOD_EXPANSION_BASH? | default "UNSET")}
    {name: "GOOD_RELATIVE variable", expected: "./config/app.conf", actual: ($env.GOOD_RELATIVE? | default "UNSET")}
    
    # Test variables
    {name: "TEST_BASIC variable", expected: "basic_value_works", actual: ($env.TEST_BASIC? | default "UNSET")}
    {name: "TEST_QUOTED variable", expected: "value with spaces works", actual: ($env.TEST_QUOTED? | default "UNSET")}
    {name: "TEST_SHELL variable (Nushell precedence)", expected: "nushell_detected", actual: ($env.TEST_SHELL? | default "UNSET")}
    {name: "SPECIAL_CHARS_TEST variable", expected: "!@#$%^&*()_+-=[]{}|;:,.<>?", actual: ($env.SPECIAL_CHARS_TEST? | default "UNSET")}
    {name: "UNICODE_TEST variable", expected: "Testing: αβγ 中文 العربية русский 🎉", actual: ($env.UNICODE_TEST? | default "UNSET")}
    {name: "PATH_TEST variable", expected: $"/usr/local/bin:/opt/bin:($env.HOME)/.local/bin", actual: ($env.PATH_TEST? | default "UNSET")}
]

# Add platform-specific tests
let platform_tests = match $platform {
    "LINUX" => [
        {name: "CONFIG_DIR_LINUX precedence", expected: $"($env.HOME)/.config/linux", actual: ($env.CONFIG_DIR? | default "UNSET")}
        {name: "TEMP_DIR generic", expected: "/tmp", actual: ($env.TEMP_DIR? | default "UNSET")}
        {name: "SYSTEM_BIN generic", expected: "/usr/local/bin", actual: ($env.SYSTEM_BIN? | default "UNSET")}
        {name: "DOCKER_HOST generic", expected: "unix:///var/run/docker.sock", actual: ($env.DOCKER_HOST? | default "UNSET")}
        {name: "TEST_PLATFORM_UNIX variable", expected: "unix_detected", actual: ($env.TEST_PLATFORM_UNIX? | default "UNSET")}
    ]
    "WSL" => [
        {name: "CONFIG_DIR_WSL precedence", expected: $"($env.HOME)/.config/wsl", actual: ($env.CONFIG_DIR? | default "UNSET")}
        {name: "TEMP_DIR generic", expected: "/tmp", actual: ($env.TEMP_DIR? | default "UNSET")}
        {name: "SYSTEM_BIN generic", expected: "/usr/local/bin", actual: ($env.SYSTEM_BIN? | default "UNSET")}
        {name: "DOCKER_HOST generic", expected: "unix:///var/run/docker.sock", actual: ($env.DOCKER_HOST? | default "UNSET")}
        {name: "TEST_PLATFORM_UNIX variable", expected: "unix_detected", actual: ($env.TEST_PLATFORM_UNIX? | default "UNSET")}
    ]
    "MACOS" => [
        {name: "CONFIG_DIR_MACOS precedence", expected: $"($env.HOME)/Library/Application Support", actual: ($env.CONFIG_DIR? | default "UNSET")}
        {name: "TEMP_DIR generic", expected: "/tmp", actual: ($env.TEMP_DIR? | default "UNSET")}
        {name: "SYSTEM_BIN_MACOS precedence", expected: "/opt/homebrew/bin", actual: ($env.SYSTEM_BIN? | default "UNSET")}
        {name: "DOCKER_HOST generic", expected: "unix:///var/run/docker.sock", actual: ($env.DOCKER_HOST? | default "UNSET")}
        {name: "TEST_PLATFORM_UNIX variable", expected: "unix_detected", actual: ($env.TEST_PLATFORM_UNIX? | default "UNSET")}
    ]
    "WIN" => [
        {name: "CONFIG_DIR_WIN precedence", expected: "%APPDATA%", actual: ($env.CONFIG_DIR? | default "UNSET")}
        {name: "TEMP_DIR_WIN precedence", expected: "%TEMP%", actual: ($env.TEMP_DIR? | default "UNSET")}
        {name: "SYSTEM_BIN_WIN precedence", expected: "C:\\Program Files", actual: ($env.SYSTEM_BIN? | default "UNSET")}
        {name: "DOCKER_HOST_WIN precedence", expected: "npipe:////./pipe/docker_engine", actual: ($env.DOCKER_HOST? | default "UNSET")}
        {name: "TEST_PLATFORM_WIN variable", expected: "win_detected", actual: ($env.TEST_PLATFORM_WIN? | default "UNSET")}
    ]
    _ => [
        {name: "CONFIG_DIR generic fallback", expected: $"($env.HOME)/.config", actual: ($env.CONFIG_DIR? | default "UNSET")}
        {name: "TEMP_DIR generic", expected: "/tmp", actual: ($env.TEMP_DIR? | default "UNSET")}
        {name: "SYSTEM_BIN generic", expected: "/usr/local/bin", actual: ($env.SYSTEM_BIN? | default "UNSET")}
        {name: "DOCKER_HOST generic", expected: "unix:///var/run/docker.sock", actual: ($env.DOCKER_HOST? | default "UNSET")}
        {name: "TEST_PLATFORM_UNIX variable", expected: "unix_detected", actual: ($env.TEST_PLATFORM_UNIX? | default "UNSET")}
    ]
}

# Combine all tests
let all_tests = ($tests | append $platform_tests)

# Add LOG_FILE test with dynamic date
let date_str = (date now | format date "%Y%m%d")
let log_file_test = {
    name: "LOG_FILE variable (expanded)",
    expected: $"($env.HOME)/logs/app-($date_str).log",
    actual: ($env.LOG_FILE? | default "UNSET")
}
let final_tests = ($all_tests | append [$log_file_test])

# Run tests and collect results
print "Running tests..."
let results = ($final_tests | each { |test|
    let passed = ($test.expected == $test.actual)
    if $passed {
        print $"✅ ($test.name): PASS"
    } else {
        print $"❌ ($test.name): FAIL (expected: '($test.expected)', got: '($test.actual)')"
    }
    {name: $test.name, passed: $passed}
})

# Calculate summary
let total_tests = ($results | length)
let passed_tests = ($results | where passed | length)
let failed_tests = ($total_tests - $passed_tests)

print ""
print "Comprehensive Nushell Test Summary:"
print "=================================="
print $"Platform: ($platform)"
print $"Total tests: ($total_tests)"
print $"Passed: ($passed_tests)"
print $"Failed: ($failed_tests)"

if $failed_tests == 0 {
    print "🎉 All tests passed! Nushell implementation is 100% compatible with .env.example"
    exit 0
} else {
    print "💥 Some tests failed. Check the output above for details."
    exit 1
}
