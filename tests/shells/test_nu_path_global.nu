# Nushell PATH Test with Global Variables
# ========================================
# Test PATH manipulation using global $env assignment

print "Nushell PATH Test with Global Variables"
print "======================================="

# Source the Nushell loader
source "/home/lgf/Desktop/code/augment/shell-env-loader/src/shells/nu/loader.nu"

# Show original PATH
print "\n🔍 BEFORE loading .env.example:"
print $"PATH entries: ($env.PATH | length)"
print $"PATH_ADDITION: ($env.PATH_ADDITION? | default 'NOT_SET')"
print $"PATH_EXPORT: ($env.PATH_EXPORT? | default 'NOT_SET')"

print "\nOriginal PATH (last 5 entries):"
$env.PATH | last 5 | enumerate | each { |item| 
    print $"  ($item.index + ($env.PATH | length) - 5): ($item.item)" 
}

# Load environment variables with debug
print "\n📥 Loading .env.example with global variable fix..."
$env.ENV_LOADER_DEBUG = "true"
load_env_file "/home/lgf/Desktop/code/augment/shell-env-loader/.env.example"

print "\n🔍 AFTER loading .env.example:"
print $"PATH entries: ($env.PATH | length)"
print $"PATH_ADDITION: ($env.PATH_ADDITION? | default 'NOT_SET')"
print $"PATH_EXPORT: ($env.PATH_EXPORT? | default 'NOT_SET')"

print "\nNew PATH (last 8 entries):"
$env.PATH | last 8 | enumerate | each { |item| 
    print $"  ($item.index + ($env.PATH | length) - 8): ($item.item)" 
}

# Check for expected PATH additions from PATH_ADDITION_LINUX
let expected_linux_additions = ["/usr/local/bin", "/snap/bin", "/tmp/test_linux_path"]
print "\n✅ Checking for expected LINUX PATH additions:"
for addition in $expected_linux_additions {
    let found = ($env.PATH | any { |path| $path == $addition })
    if $found {
        print $"  ✅ Found: ($addition)"
    } else {
        print $"  ❌ Missing: ($addition)"
    }
}

# Summary
let path_changed = ($env.PATH | length) > 15
let path_addition_set = ($env.PATH_ADDITION? | default "") != ""
let path_export_set = ($env.PATH_EXPORT? | default "") != ""

print "\n📊 Summary:"
print $"PATH was modified: ($path_changed)"
print $"PATH_ADDITION variable set: ($path_addition_set)"
print $"PATH_EXPORT variable set: ($path_export_set)"
print $"Final PATH length: ($env.PATH | length)"

if $path_changed and $path_addition_set {
    print "🎉 SUCCESS: PATH manipulation is working correctly!"
    exit 0
} else {
    print "❌ FAILURE: PATH manipulation needs more work"
    exit 1
}
