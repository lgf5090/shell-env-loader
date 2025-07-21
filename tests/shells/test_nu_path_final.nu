# Final Nushell PATH Test with Manual PATH Handling
# ==================================================
# Test PATH manipulation with explicit PATH handling

print "Final Nushell PATH Test"
print "======================="

# Source the Nushell loader
source "/home/lgf/Desktop/code/augment/shell-env-loader/src/shells/nu/loader.nu"

# Show original PATH
print "\n🔍 BEFORE loading .env.example:"
print $"PATH entries: ($env.PATH | length)"
print "Last 5 PATH entries:"
$env.PATH | last 5 | enumerate | each { |item| print $"  ($item.index + ($env.PATH | length) - 5): ($item.item)" }

# Load environment variables
print "\n📥 Loading .env.example..."
$env.ENV_LOADER_DEBUG = "true"
load_env_file "/home/lgf/Desktop/code/augment/shell-env-loader/.env.example"

print "\n🔍 AFTER loading .env.example:"
print $"PATH entries: ($env.PATH | length)"
print "Last 5 PATH entries:"
$env.PATH | last 5 | enumerate | each { |item| print $"  ($item.index + ($env.PATH | length) - 5): ($item.item)" }

# Check PATH_ADDITION variable
print $"\nPATH_ADDITION variable: ($env.PATH_ADDITION? | default 'NOT_SET')"

# Manual PATH addition test
if ($env.PATH_ADDITION? | default "") != "" {
    print "\n🔧 Manually adding PATH_ADDITION to PATH..."
    let path_additions = ($env.PATH_ADDITION | split row ":")
    print $"PATH additions to add: ($path_additions)"
    
    # Add to PATH manually
    let original_path_length = ($env.PATH | length)
    $env.PATH = ($env.PATH | append $path_additions)
    let new_path_length = ($env.PATH | length)
    
    print $"PATH length changed from ($original_path_length) to ($new_path_length)"
    print "New last 5 PATH entries:"
    $env.PATH | last 5 | enumerate | each { |item| print $"  ($item.index + ($env.PATH | length) - 5): ($item.item)" }
    
    # Check for specific additions
    print "\n✅ Checking for PATH additions:"
    for addition in $path_additions {
        let found = ($env.PATH | any { |path| $path == $addition })
        if $found {
            print $"  ✅ Found: ($addition)"
        } else {
            print $"  ❌ Missing: ($addition)"
        }
    }
} else {
    print "\n❌ PATH_ADDITION variable not found"
}

print "\n📊 Final Summary:"
print $"PATH was successfully modified: {($env.PATH | length) > 15}"
print $"Final PATH length: ($env.PATH | length)"
