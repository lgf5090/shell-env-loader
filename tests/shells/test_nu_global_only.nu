# Nushell Global Variables Only Test
# ====================================
# Test using only global variable assignments (no load-env)

print "Nushell Global Variables Only Test"
print "=================================="

# Source the Nushell loader
source "/home/lgf/Desktop/code/augment/shell-env-loader/src/shells/nu/loader.nu"

# Clear any existing test variables to ensure clean test
if 'TEST_BASIC' in $env { $env.TEST_BASIC = "" }
if 'TEST_SHELL' in $env { $env.TEST_SHELL = "" }
if 'PATH_ADDITION' in $env { $env.PATH_ADDITION = "" }

# Show original state
print "\n🔍 BEFORE loading .env.example:"
print $"PATH entries: ($env.PATH | length)"
print $"EDITOR: ($env.EDITOR? | default 'NOT_SET')"
print $"TEST_BASIC: ($env.TEST_BASIC? | default 'NOT_SET')"
print $"TEST_SHELL: ($env.TEST_SHELL? | default 'NOT_SET')"
print $"PATH_ADDITION: ($env.PATH_ADDITION? | default 'NOT_SET')"

print "\nOriginal PATH (last 5 entries):"
$env.PATH | last 5 | enumerate | each { |item| 
    print $"  ($item.index + ($env.PATH | length) - 5): ($item.item)" 
}

# Load environment variables with debug
print "\n📥 Loading .env.example with global variables only..."
$env.ENV_LOADER_DEBUG = "true"
load_env_file "/home/lgf/Desktop/code/augment/shell-env-loader/.env.example"

print "\n🔍 AFTER loading .env.example:"
print $"PATH entries: ($env.PATH | length)"
print $"EDITOR: ($env.EDITOR? | default 'NOT_SET')"
print $"VISUAL: ($env.VISUAL? | default 'NOT_SET')"
print $"PAGER: ($env.PAGER? | default 'NOT_SET')"
print $"NODE_VERSION: ($env.NODE_VERSION? | default 'NOT_SET')"
print $"TEST_BASIC: ($env.TEST_BASIC? | default 'NOT_SET')"
print $"TEST_SHELL: ($env.TEST_SHELL? | default 'NOT_SET')"
print $"PATH_ADDITION: ($env.PATH_ADDITION? | default 'NOT_SET')"
print $"PATH_EXPORT: ($env.PATH_EXPORT? | default 'NOT_SET')"

print "\nNew PATH (last 8 entries):"
$env.PATH | last 8 | enumerate | each { |item| 
    print $"  ($item.index + ($env.PATH | length) - 8): ($item.item)" 
}

# Test specific variables
let tests = [
    {name: "EDITOR", expected: "vim", actual: ($env.EDITOR? | default "UNSET")}
    {name: "VISUAL", expected: "vim", actual: ($env.VISUAL? | default "UNSET")}
    {name: "PAGER", expected: "less", actual: ($env.PAGER? | default "UNSET")}
    {name: "NODE_VERSION", expected: "18.17.0", actual: ($env.NODE_VERSION? | default "UNSET")}
    {name: "TEST_BASIC", expected: "basic_value_works", actual: ($env.TEST_BASIC? | default "UNSET")}
    {name: "TEST_SHELL", expected: "nushell_detected", actual: ($env.TEST_SHELL? | default "UNSET")}
    {name: "PATH_ADDITION", expected: "/usr/local/bin:/snap/bin:/tmp/test_linux_path", actual: ($env.PATH_ADDITION? | default "UNSET")}
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
    print "🎉 SUCCESS: Global variables only approach working perfectly!"
    exit 0
} else {
    print "❌ FAILURE: Global variables only approach needs more work"
    exit 1
}
