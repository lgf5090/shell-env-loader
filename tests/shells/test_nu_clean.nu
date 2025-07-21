# Clean Nushell Test for .env.example only
# =========================================
# Test only .env.example with clean environment

print "Clean Nushell Test for .env.example"
print "==================================="

# Clear potentially conflicting variables first
if 'PYTHON_VERSION' in $env { hide-env PYTHON_VERSION }
if 'API_KEY' in $env { hide-env API_KEY }
if 'TEST_SHELL' in $env { hide-env TEST_SHELL }
if 'CONFIG_DIR' in $env { hide-env CONFIG_DIR }
if 'TEST_BASIC' in $env { hide-env TEST_BASIC }

print "Cleared potentially conflicting variables."

# Source loader
print "Sourcing loader..."
source "../../src/shells/nu/loader.nu"

# Enable debug to see what's being loaded
$env.ENV_LOADER_DEBUG = "true"

print "Loading ONLY .env.example..."
load_env_file "../../.env.example"

print ""
print "Checking key variables after loading .env.example:"
print $"PYTHON_VERSION: ($env.PYTHON_VERSION? | default 'NOT_SET')"
print $"API_KEY: ($env.API_KEY? | default 'NOT_SET')"
print $"TEST_SHELL: ($env.TEST_SHELL? | default 'NOT_SET')"
print $"CONFIG_DIR: ($env.CONFIG_DIR? | default 'NOT_SET')"
print $"TEST_BASIC: ($env.TEST_BASIC? | default 'NOT_SET')"

print ""
print "Expected values from .env.example:"
print "PYTHON_VERSION: 3.11.0"
print "API_KEY: your_api_key_here"
print "TEST_SHELL: nushell_detected"
print "CONFIG_DIR: ~/.config/linux (on Linux)"
print "TEST_BASIC: basic_value_works"

print ""
print "Analysis:"
let python_correct = ($env.PYTHON_VERSION? | default "") == "3.11.0"
let api_correct = ($env.API_KEY? | default "") == "your_api_key_here"
let test_shell_correct = ($env.TEST_SHELL? | default "") == "nushell_detected"
let config_correct = ($env.CONFIG_DIR? | default "") == "~/.config/linux"
let test_basic_correct = ($env.TEST_BASIC? | default "") == "basic_value_works"

print $"PYTHON_VERSION correct: ($python_correct)"
print $"API_KEY correct: ($api_correct)"
print $"TEST_SHELL correct: ($test_shell_correct)"
print $"CONFIG_DIR correct: ($config_correct)"
print $"TEST_BASIC correct: ($test_basic_correct)"

let total_correct = [$python_correct, $api_correct, $test_shell_correct, $config_correct, $test_basic_correct] | where $it | length
print $"Total correct: ($total_correct)/5"

if $total_correct == 5 {
    print "🎉 All key variables are correct!"
} else {
    print "❌ Some variables are incorrect - check precedence logic"
}
