# Simple Nushell PATH Test
# =========================
# Test PATH manipulation functionality

print "Simple Nushell PATH Test"
print "========================"

# Source the Nushell loader
source "/home/lgf/Desktop/code/augment/shell-env-loader/src/shells/nu/loader.nu"

# Show original PATH
print "\n🔍 BEFORE loading .env.example:"
print $"PATH entries: ($env.PATH | length)"
print $"PATH_ADDITION: ($env.PATH_ADDITION? | default 'NOT_SET')"
print $"PATH_EXPORT: ($env.PATH_EXPORT? | default 'NOT_SET')"

# Show first few and last few PATH entries
print "\nFirst 3 PATH entries:"
$env.PATH | take 3 | each { |entry| print $"  - ($entry)" }
print "\nLast 3 PATH entries:"
$env.PATH | last 3 | each { |entry| print $"  - ($entry)" }

# Load environment variables with debug
print "\n📥 Loading .env.example with debug..."
$env.ENV_LOADER_DEBUG = "true"
load_env_file "/home/lgf/Desktop/code/augment/shell-env-loader/.env.example"

print "\n🔍 AFTER loading .env.example:"
print $"PATH entries: ($env.PATH | length)"
print $"PATH_ADDITION: ($env.PATH_ADDITION? | default 'NOT_SET')"
print $"PATH_EXPORT: ($env.PATH_EXPORT? | default 'NOT_SET')"

# Show first few and last few PATH entries
print "\nFirst 3 PATH entries:"
$env.PATH | take 3 | each { |entry| print $"  - ($entry)" }
print "\nLast 3 PATH entries:"
$env.PATH | last 3 | each { |entry| print $"  - ($entry)" }

# Check for specific additions
let expected_additions = ["/usr/local/bin", "/snap/bin", "/tmp/test_linux_path"]
print "\n✅ Checking for expected PATH additions:"
for addition in $expected_additions {
    let found = ($env.PATH | any { |path| $path == $addition })
    if $found {
        print $"  ✅ Found: ($addition)"
    } else {
        print $"  ❌ Missing: ($addition)"
    }
}

print "\n📊 Summary:"
print $"PATH was modified: {($env.PATH | length) != 15}"
