# Nushell Debug Test
# ==================
# Simple test to debug global variable assignment

print "Nushell Debug Test"
print "=================="

# Test basic global variable assignment
print "\n🔧 Testing basic global variable assignment:"
$env.TEST_VAR = "test_value"
print $"TEST_VAR after assignment: ($env.TEST_VAR)"

# Test PATH modification
print "\n🔧 Testing PATH modification:"
print $"Original PATH length: ($env.PATH | length)"
let original_path = $env.PATH
$env.PATH = ($env.PATH | append ["/test/path1", "/test/path2"])
print $"New PATH length: ($env.PATH | length)"
print $"PATH was modified: {($env.PATH | length) != ($original_path | length)}"

# Test load-env
print "\n🔧 Testing load-env:"
load-env {TEST_LOAD_ENV: "load_env_value"}
print $"TEST_LOAD_ENV: ($env.TEST_LOAD_ENV? | default 'NOT_SET')"

# Source the loader and test a simple case
print "\n🔧 Testing loader with simple case:"
source "/home/lgf/Desktop/code/augment/shell-env-loader/src/shells/nu/loader.nu"

# Create a simple test env file
let test_content = [
    "TEST_SIMPLE=simple_value"
    "PATH_ADDITION_LINUX=/test/linux/path"
]
$test_content | save -f "/tmp/test.env"

print "Loading test env file..."
$env.ENV_LOADER_DEBUG = "true"
load_env_file "/tmp/test.env"

print $"\nAfter loading test env:"
print $"TEST_SIMPLE: ($env.TEST_SIMPLE? | default 'NOT_SET')"
print $"PATH_ADDITION: ($env.PATH_ADDITION? | default 'NOT_SET')"
print $"PATH length: ($env.PATH | length)"

# Clean up
rm "/tmp/test.env"
