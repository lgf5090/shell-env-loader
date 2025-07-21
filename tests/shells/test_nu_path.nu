# Nushell PATH Testing
# ====================
# Test PATH manipulation functionality

print "Testing Nushell PATH Manipulation"
print "================================="

# Source the Nushell loader
source "/home/lgf/Desktop/code/augment/shell-env-loader/src/shells/nu/loader.nu"

# Show original PATH
print "Original PATH:"
print $"  PATH = ($env.PATH | str join ':')"
print $"  PATH entries count: ($env.PATH | length)"

# Clear PATH-related variables to ensure clean test
if 'PATH_ADDITION' in $env { hide-env PATH_ADDITION }
if 'PATH_EXPORT' in $env { hide-env PATH_EXPORT }

print "\nLoading .env.example..."

# Enable debug mode to see what's happening
$env.ENV_LOADER_DEBUG = "true"

# Load environment variables
load_env_file "/home/lgf/Desktop/code/augment/shell-env-loader/.env.example"

print "\nAfter loading .env.example:"
print $"  PATH = ($env.PATH | str join ':')"
print $"  PATH entries count: ($env.PATH | length)"

# Check if PATH_ADDITION and PATH_EXPORT variables exist
print "\nPATH-related variables from .env.example:"
print $"  PATH_ADDITION = ($env.PATH_ADDITION? | default 'NOT_SET')"
print $"  PATH_EXPORT = ($env.PATH_EXPORT? | default 'NOT_SET')"

# Show PATH entries as a list for easier comparison
print "\nPATH entries (as list):"
$env.PATH | each { |entry| print $"  - ($entry)" }

# Test if specific paths were added
let expected_additions = [
    ($env.HOME + "/.local/bin")
    ($env.HOME + "/.cargo/bin") 
    ($env.HOME + "/go/bin")
]

print "\nChecking for expected PATH additions:"
for addition in $expected_additions {
    let found = ($env.PATH | any { |path| $path == $addition })
    if $found {
        print $"  ✅ Found: ($addition)"
    } else {
        print $"  ❌ Missing: ($addition)"
    }
}

# Check what PATH variables exist in .env.example
print "\nChecking .env.example for PATH-related variables:"
let env_content = (open "/home/lgf/Desktop/code/augment/shell-env-loader/.env.example" | lines)
let path_vars = ($env_content | where ($it | str contains "PATH"))
for var in $path_vars {
    print $"  ($var)"
}
