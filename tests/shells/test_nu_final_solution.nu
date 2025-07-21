# Nushell Final Solution Test
# ===========================
# Test using direct variable assignment outside functions

print "Nushell Final Solution Test"
print "==========================="

# Source the Nushell loader
source "/home/lgf/Desktop/code/augment/shell-env-loader/src/shells/nu/loader.nu"

# Show original state
print "\n🔍 BEFORE loading .env.example:"
print $"PATH entries: ($env.PATH | length)"

# Get the environment variables to set
print "\n📥 Getting environment variables to set..."
let env_vars_to_set = (get_env_vars_to_set "/home/lgf/Desktop/code/augment/shell-env-loader/.env.example")
print $"Variables to set: ($env_vars_to_set | columns | length)"

# Apply the environment variables directly
print "\n🔧 Applying environment variables directly..."
load-env $env_vars_to_set

print "\n🔍 AFTER applying environment variables:"
print $"PATH entries: ($env.PATH | length)"
print $"EDITOR: ($env.EDITOR? | default 'NOT_SET')"
print $"TEST_BASIC: ($env.TEST_BASIC? | default 'NOT_SET')"
print $"TEST_SHELL: ($env.TEST_SHELL? | default 'NOT_SET')"
print $"PATH_ADDITION: ($env.PATH_ADDITION? | default 'NOT_SET')"

# Check PATH additions
let expected_additions = ["/usr/local/bin", "/snap/bin", "/tmp/test_linux_path"]
print "\n✅ PATH Addition Tests:"
let path_tests_passed = ($expected_additions | each { |addition|
    let found = ($env.PATH | any { |path| $path == $addition })
    if $found {
        print $"  ✅ Found: ($addition)"
    } else {
        print $"  ❌ Missing: ($addition)"
    }
    $found
} | where $it | length)

# Test specific variables
let tests = [
    {name: "EDITOR", expected: "vim", actual: ($env.EDITOR? | default "UNSET")}
    {name: "NODE_VERSION", expected: "18.17.0", actual: ($env.NODE_VERSION? | default "UNSET")}
    {name: "TEST_BASIC", expected: "basic_value_works", actual: ($env.TEST_BASIC? | default "UNSET")}
    {name: "TEST_SHELL", expected: "nushell_detected", actual: ($env.TEST_SHELL? | default "UNSET")}
]

print "\n✅ Variable Tests:"
let passed_tests = ($tests | each { |test|
    let passed = ($test.expected == $test.actual)
    if $passed {
        print $"  ✅ ($test.name): ($test.actual)"
    } else {
        print $"  ❌ ($test.name): expected '($test.expected)', got '($test.actual)'"
    }
    $passed
} | where $it | length)

# Summary
let total_tests = ($tests | length)
let path_changed = ($env.PATH | length) > 15
let all_vars_set = ($env.EDITOR? | default "") != "" and ($env.TEST_BASIC? | default "") != ""

print "\n📊 Final Summary:"
print $"Variable tests passed: ($passed_tests)/($total_tests)"
print $"PATH tests passed: ($path_tests_passed)/($expected_additions | length)"
print $"PATH was modified: ($path_changed)"
print $"All key variables set: ($all_vars_set)"
print $"Final PATH length: ($env.PATH | length)"

if $passed_tests == $total_tests and $path_changed and $all_vars_set {
    print "🎉 SUCCESS: Final solution working perfectly!"
    exit 0
} else {
    print "❌ FAILURE: Final solution needs more work"
    exit 1
}
