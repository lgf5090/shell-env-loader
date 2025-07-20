# Fixed Nushell Tests
# ===================
# Simplified test for Nushell implementation

print "Running Nushell Tests"
print "====================="

# Source the Nushell loader
source "/home/lgf/Desktop/code/augment/shell-env-loader/src/shells/nu/loader.nu"

# Load environment variables
load_env_file "/home/lgf/Desktop/code/augment/shell-env-loader/.env.example"

# Test results
let tests = [
    {name: "Shell detection", expected: "NUSHELL", actual: (detect_shell)}
    {name: "Platform detection", expected: "LINUX", actual: (detect_platform)}
    {name: "EDITOR variable", expected: "vim", actual: ($env.EDITOR? | default "UNSET")}
    {name: "VISUAL variable", expected: "vim", actual: ($env.VISUAL? | default "UNSET")}
    {name: "PAGER variable", expected: "less", actual: ($env.PAGER? | default "UNSET")}
    {name: "TERM variable", expected: "xterm-256color", actual: ($env.TERM? | default "UNSET")}
    {name: "COLORTERM variable", expected: "truecolor", actual: ($env.COLORTERM? | default "UNSET")}
    {name: "NODE_VERSION variable", expected: "18.17.0", actual: ($env.NODE_VERSION? | default "UNSET")}
    {name: "GIT_DEFAULT_BRANCH variable", expected: "main", actual: ($env.GIT_DEFAULT_BRANCH? | default "UNSET")}
    {name: "API_KEY variable", expected: "your_api_key_here", actual: ($env.API_KEY? | default "UNSET")}
    {name: "TEST_BASIC variable", expected: "basic_value_works", actual: ($env.TEST_BASIC? | default "UNSET")}
    {name: "TEST_SHELL variable", expected: "nushell_detected", actual: ($env.TEST_SHELL? | default "UNSET")}
]

# Run tests and collect results
let results = ($tests | each { |test|
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
print "Nushell Test Summary:"
print "===================="
print $"Total tests: ($total_tests)"
print $"Passed: ($passed_tests)"
print $"Failed: ($failed_tests)"

if $failed_tests == 0 {
    print "🎉 All tests passed! Nushell implementation is working correctly"
    exit 0
} else {
    print "💥 Some tests failed. Check the output above for details."
    exit 1
}
