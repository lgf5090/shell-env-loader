# Final Working Nushell Test
# ===========================
# Comprehensive test using working approach

print "Final Working Nushell Test"
print "=========================="

# Test framework setup
$env.TEST_COUNT = "0"
$env.PASS_COUNT = "0"
$env.FAIL_COUNT = "0"

# Colors
let red = "\u{001b}[31m"
let green = "\u{001b}[32m"
let yellow = "\u{001b}[33m"
let blue = "\u{001b}[34m"
let reset = "\u{001b}[0m"

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
        "CONFIG_DIR" => ($env.CONFIG_DIR? | default "")
        "PATH_ADDITION" => ($env.PATH_ADDITION? | default "")
        "DATABASE_URL" => ($env.DATABASE_URL? | default "")
        "API_KEY" => ($env.API_KEY? | default "")
        "WELCOME_MESSAGE" => ($env.WELCOME_MESSAGE? | default "")
        "SPECIAL_CHARS_TEST" => ($env.SPECIAL_CHARS_TEST? | default "")
        "UNICODE_TEST" => ($env.UNICODE_TEST? | default "")
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

# PATH test helper
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
        $env.FAIL_COUNT = (($env.FAIL_COUNT | into int) + 1 | into string)
        return false
    }
}

# Get platform
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
print $"Platform: ($platform)"
print $"Shell: NUSHELL"
print ""

# Source loader and load environment
print "Sourcing loader and loading environment..."
source "../../src/shells/nu/loader.nu"
load_env_file "../../.env.example"
print "Environment loaded."
print ""

# Run comprehensive tests
print "Running comprehensive tests..."
print ""

# Basic variables
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
print ""

# Shell-specific variables
print "Testing shell-specific variables..."
assert_env_var_set "TEST_SHELL" "nushell_detected" "TEST_SHELL_NU precedence"
print ""

# Platform-specific variables
print "Testing platform-specific variables..."
match $platform {
    "LINUX" => {
        assert_env_var_set "CONFIG_DIR" ($env.HOME + "/.config/linux") "CONFIG_DIR_LINUX precedence on Linux"
    }
    "WSL" => {
        assert_env_var_set "CONFIG_DIR" ($env.HOME + "/.config/wsl") "CONFIG_DIR_WSL precedence on WSL"
    }
    "MACOS" => {
        assert_env_var_set "CONFIG_DIR" ($env.HOME + "/Library/Application Support") "CONFIG_DIR_MACOS precedence on macOS"
    }
    "WIN" => {
        assert_env_var_set "CONFIG_DIR" "%APPDATA%" "CONFIG_DIR_WIN precedence on Windows"
    }
    _ => {
        assert_env_var_set "CONFIG_DIR" ($env.HOME + "/.config") "CONFIG_DIR generic fallback"
    }
}
print ""

# PATH handling
print "Testing PATH handling..."
match $platform {
    "LINUX" => {
        assert_path_contains "/usr/local/bin" "PATH contains /usr/local/bin on Linux"
        assert_path_contains "/snap/bin" "PATH contains /snap/bin on Linux"
        assert_path_contains "/tmp/test_linux_path" "PATH contains Linux-specific path"
    }
    "WSL" => {
        assert_path_contains "/usr/local/bin" "PATH contains /usr/local/bin on WSL"
        assert_path_contains "/snap/bin" "PATH contains /snap/bin on WSL"
    }
    "MACOS" => {
        assert_path_contains "/opt/homebrew/bin" "PATH contains Homebrew paths on macOS"
    }
    _ => {
        assert_path_contains "/usr/local/bin" "PATH contains /usr/local/bin generic"
    }
}
assert_path_contains ($env.HOME + "/.local/bin") "PATH contains ~/.local/bin"
assert_path_contains ($env.HOME + "/.cargo/bin") "PATH contains ~/.cargo/bin"
assert_path_contains ($env.HOME + "/go/bin") "PATH contains ~/go/bin"
print ""

# Application configs
print "Testing application configurations..."
assert_env_var_set "DATABASE_URL" "postgresql://localhost:5432/myapp_dev" "DATABASE_URL variable"
assert_env_var_set "API_KEY" "your_api_key_here" "API_KEY variable"
print ""

# Special characters
print "Testing special character handling..."
assert_env_var_set "TEST_BASIC" "basic_value_works" "TEST_BASIC variable"
assert_env_var_set "TEST_QUOTED" "value with spaces works" "TEST_QUOTED variable"
assert_env_var_set "SPECIAL_CHARS_TEST" "!@#$%^&*()_+-=[]{}|;:,.<>?" "SPECIAL_CHARS_TEST variable"
print ""

# Unicode
print "Testing Unicode characters..."
assert_env_var_set "WELCOME_MESSAGE" "Welcome! 欢迎! Bienvenidos! Добро пожаловать!" "WELCOME_MESSAGE Unicode"
assert_env_var_set "UNICODE_TEST" "Testing: αβγ 中文 العربية русский 🎉" "UNICODE_TEST various Unicode"
print ""

# Summary
print $"($blue)Test Summary:($reset)"
print "============="
print $"Total tests: ($env.TEST_COUNT)"
print $"($green)Passed: ($env.PASS_COUNT)($reset)"
print $"($red)Failed: ($env.FAIL_COUNT)($reset)"

let fail_count = ($env.FAIL_COUNT | into int)
if $fail_count == 0 {
    print $"($green)🎉 All tests passed! Nushell implementation is working perfectly!($reset)"
    exit 0
} else {
    print $"($red)💥 Some tests failed. Check the output above for details.($reset)"
    exit 1
}
