# Simple Nushell Check
# ====================
# Check if loader functions are available

print "Simple Nushell Check"
print "===================="

# Source the Nushell loader
print "Sourcing loader..."
source "/home/lgf/Desktop/code/augment/shell-env-loader/src/shells/nu/loader.nu"

# Check if functions are available
print "Checking functions..."

# Test detect_shell
try {
    let shell = (detect_shell)
    print $"detect_shell: ($shell)"
} catch {
    print "detect_shell: NOT AVAILABLE"
}

# Test detect_platform
try {
    let platform = (detect_platform)
    print $"detect_platform: ($platform)"
} catch {
    print "detect_platform: NOT AVAILABLE"
}

# Test get_env_vars_to_set
try {
    let env_vars = (get_env_vars_to_set "/home/lgf/Desktop/code/augment/shell-env-loader/.env.example")
    let var_count = ($env_vars | columns | length)
    print $"get_env_vars_to_set: SUCCESS \(($var_count) variables\)"
} catch {
    print "get_env_vars_to_set: NOT AVAILABLE"
}

# Test load_env_file
try {
    print "Testing load_env_file..."
    load_env_file "/home/lgf/Desktop/code/augment/shell-env-loader/.env.example"
    print $"load_env_file: SUCCESS"
    print $"EDITOR after load: ($env.EDITOR? | default 'NOT_SET')"
    print $"TEST_BASIC after load: ($env.TEST_BASIC? | default 'NOT_SET')"
} catch {
    print "load_env_file: NOT AVAILABLE"
}

print "Check complete."
