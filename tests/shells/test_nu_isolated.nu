# Isolated Nushell Test
# ======================
# Test with minimal isolated environment

print "Isolated Nushell Test"
print "===================="

# Clear any existing variables
if 'TEST_BASIC' in $env { hide-env TEST_BASIC }
if 'PATH_ADDITION' in $env { hide-env PATH_ADDITION }

print "\n🧹 After clearing variables:"
print $"TEST_BASIC: ($env.TEST_BASIC? | default 'NOT_SET')"
print $"PATH_ADDITION: ($env.PATH_ADDITION? | default 'NOT_SET')"
print $"PATH length: ($env.PATH | length)"

# Test direct global assignment
print "\n🔧 Testing direct global assignment:"
$env.TEST_DIRECT = "direct_value"
print $"TEST_DIRECT: ($env.TEST_DIRECT)"

# Test PATH direct assignment
print "\n🔧 Testing PATH direct assignment:"
let original_path_length = ($env.PATH | length)
$env.PATH = ($env.PATH | append ["/test/direct/path"])
print $"PATH length changed from ($original_path_length) to ($env.PATH | length)"

# Create minimal test file
let test_content = [
    "TEST_MINIMAL=minimal_works"
    "PATH_ADDITION_LINUX=/test/minimal/path"
]
$test_content | save -f "/tmp/minimal.env"

# Source loader and test
source "/home/lgf/Desktop/code/augment/shell-env-loader/src/shells/nu/loader.nu"

print "\n📥 Loading minimal test file..."
$env.ENV_LOADER_DEBUG = "true"
load_env_file "/tmp/minimal.env"

print "\n🔍 After loading minimal file:"
print $"TEST_MINIMAL: ($env.TEST_MINIMAL? | default 'NOT_SET')"
print $"PATH_ADDITION: ($env.PATH_ADDITION? | default 'NOT_SET')"
print $"PATH length: ($env.PATH | length)"

# Check if /test/minimal/path was added
let found_minimal_path = ($env.PATH | any { |path| $path == "/test/minimal/path" })
print $"Found /test/minimal/path in PATH: ($found_minimal_path)"

# Clean up
rm "/tmp/minimal.env"

print "\n📊 Summary:"
print $"Direct assignment works: {($env.TEST_DIRECT? | default '') == 'direct_value'}"
print $"PATH direct assignment works: {($env.PATH | length) > ($original_path_length)}"
print $"Loader assignment works: {($env.TEST_MINIMAL? | default '') == 'minimal_works'}"
print $"PATH loader assignment works: ($found_minimal_path)"
