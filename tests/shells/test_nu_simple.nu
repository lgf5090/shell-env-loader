# Simple Nushell Tests
# ====================
# Basic functionality test for Nushell implementation

# Colors for output (Nushell style)
let red = "\u{001b}[31m"
let green = "\u{001b}[32m"
let yellow = "\u{001b}[33m"
let blue = "\u{001b}[34m"
let reset = "\u{001b}[0m"

print $"($blue)Running Simple Nushell Tests($reset)"
print "================================="

# Test counters (using simple approach)
mut total_tests = 0
mut passed_tests = 0

# Test function
def test_var [expected: string, actual: string, test_name: string] {
    if $expected == $actual {
        print $"($green)✅ ($test_name): PASS($reset)"
        return "PASS"
    } else {
        print $"($red)❌ ($test_name): FAIL($reset) \(expected: '($expected)', got: '($actual)'\)"
        return "FAIL"
    }
}

# Get platform for platform-specific tests
def get_test_platform [] {
    let os_info = (sys host)
    let os_name = $os_info.name
    
    if ($os_name | str contains "Linux") {
        if ("/proc/version" | path exists) {
            let version = (open "/proc/version" | str contains "Microsoft")
            if $version {
                "WSL"
            } else {
                "LINUX"
            }
        } else {
            "LINUX"
        }
    } else if ($os_name | str contains "Darwin") {
        "MACOS"
    } else if ($os_name | str contains "Windows") {
        "WIN"
    } else {
        "UNIX"
    }
}

let platform = (get_test_platform)

print $"\n($yellow)Testing Nushell Mode:($reset)"

# Source the Nushell loader
source "/home/lgf/Desktop/code/augment/shell-env-loader/src/shells/nu/loader.nu"

# Load environment variables
load_env_file "/home/lgf/Desktop/code/augment/shell-env-loader/.env.example"

# Test results
let results = [
    (test_var "NUSHELL" (detect_shell) "Nushell shell detection")
    (test_var "vim" ($env.EDITOR? | default "UNSET") "EDITOR variable")
    (test_var "vim" ($env.VISUAL? | default "UNSET") "VISUAL variable")
    (test_var "less" ($env.PAGER? | default "UNSET") "PAGER variable")
    (test_var "xterm-256color" ($env.TERM? | default "UNSET") "TERM variable")
    (test_var "truecolor" ($env.COLORTERM? | default "UNSET") "COLORTERM variable")

# Platform-specific variables
match $platform {
    "LINUX" => {
        # CONFIG_DIR should be expanded to full path
        let expected_config_dir = $"($env.HOME)/.config/linux"
        test_var $expected_config_dir ($env.CONFIG_DIR? | default "UNSET") "CONFIG_DIR_LINUX precedence (expanded)"
    }
    _ => {
        let expected_config_dir = $"($env.HOME)/.config"
        test_var $expected_config_dir ($env.CONFIG_DIR? | default "UNSET") "CONFIG_DIR generic fallback (expanded)"
    }
}

# Development environment
test_var "18.17.0" ($env.NODE_VERSION? | default "UNSET") "NODE_VERSION variable"
test_var "main" ($env.GIT_DEFAULT_BRANCH? | default "UNSET") "GIT_DEFAULT_BRANCH variable"

# Application configs
test_var "your_api_key_here" ($env.API_KEY? | default "UNSET") "API_KEY variable"
test_var "postgresql://localhost:5432/myapp_dev" ($env.DATABASE_URL? | default "UNSET") "DATABASE_URL variable"

# Special characters (Nushell handles quotes differently)
let expected_documents_dir = $"($env.HOME)/Documents/My Projects"
test_var $expected_documents_dir ($env.DOCUMENTS_DIR? | default "UNSET") "DOCUMENTS_DIR variable (expanded)"

test_var "Welcome! 欢迎! Bienvenidos! Добро пожаловать!" ($env.WELCOME_MESSAGE? | default "UNSET") "WELCOME_MESSAGE variable"

# Test variables
test_var "basic_value_works" ($env.TEST_BASIC? | default "UNSET") "TEST_BASIC variable"
test_var "value with spaces works" ($env.TEST_QUOTED? | default "UNSET") "TEST_QUOTED variable"

# TEST_SHELL should prefer Nushell-specific value if available
# In .env.example, there's TEST_SHELL_NU=nushell_detected
test_var "nushell_detected" ($env.TEST_SHELL? | default "UNSET") "TEST_SHELL variable (Nushell precedence)"

test_var "!@#$%^&*()_+-=[]{}|;:,.<>?" ($env.SPECIAL_CHARS_TEST? | default "UNSET") "SPECIAL_CHARS_TEST variable"
test_var "Testing: αβγ 中文 العربية русский 🎉" ($env.UNICODE_TEST? | default "UNSET") "UNICODE_TEST variable"

# Summary
print $"\n($blue)Simple Nushell Test Summary:($reset)"
print "============================="
print $"Platform: ($platform)"
print $"Total tests: ($env.TOTAL_TESTS)"
print $"($green)Passed: ($env.PASSED_TESTS)($reset)"
let failed_count = (($env.TOTAL_TESTS | into int) - ($env.PASSED_TESTS | into int))
print $"($red)Failed: ($failed_count)($reset)"

if ($env.PASSED_TESTS | into int) == ($env.TOTAL_TESTS | into int) {
    print $"($green)🎉 All tests passed! Nushell implementation is working correctly($reset)"
    exit 0
} else {
    print $"($red)💥 Some tests failed. Check the output above for details.($reset)"
    exit 1
}
