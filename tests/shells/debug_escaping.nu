# Debug Escaping Issues
# ======================

print "Debug Escaping Issues"
print "===================="

# Source loader
source "../../src/shells/nu/loader.nu"

# Get environment variables
let env_vars = (get_env_vars_to_set "../../.env.example")

# Apply variables
for key in ($env_vars | columns) {
    let value = ($env_vars | get $key)
    match $key {
        "SQL_QUERY" => { $env.SQL_QUERY = $value }
        "JSON_CONFIG" => { $env.JSON_CONFIG = $value }
        "COMMAND_WITH_QUOTES" => { $env.COMMAND_WITH_QUOTES = $value }
        "COMPLEX_MESSAGE" => { $env.COMPLEX_MESSAGE = $value }
        "WINDOWS_PATH" => { $env.WINDOWS_PATH = $value }
        "REGEX_PATTERN" => { $env.REGEX_PATTERN = $value }
        "SPECIAL_CHARS_TEST" => { $env.SPECIAL_CHARS_TEST = $value }
        "NODE_OPTIONS" => { $env.NODE_OPTIONS = $value }
        _ => {}
    }
}

print ""
print "Problematic variables analysis:"
print ""

print "SQL_QUERY:"
print $"  Raw: ($env.SQL_QUERY? | default 'UNSET')"
print $"  Length: (($env.SQL_QUERY? | default '') | str length)"
print $"  Expected: SELECT * FROM users WHERE name = 'John'"

print ""
print "JSON_CONFIG:"
print $"  Raw: ($env.JSON_CONFIG? | default 'UNSET')"
print $"  Length: (($env.JSON_CONFIG? | default '') | str length)"
print $"  Expected: {\"debug\": true, \"port\": 3000}"

print ""
print "COMMAND_WITH_QUOTES:"
print $"  Raw: ($env.COMMAND_WITH_QUOTES? | default 'UNSET')"
print $"  Length: (($env.COMMAND_WITH_QUOTES? | default '') | str length)"
print $"  Expected: echo \"Hello World\""

print ""
print "COMPLEX_MESSAGE:"
print $"  Raw: ($env.COMPLEX_MESSAGE? | default 'UNSET')"
print $"  Length: (($env.COMPLEX_MESSAGE? | default '') | str length)"
print $"  Expected: He said \"It's working!\" with excitement"

print ""
print "WINDOWS_PATH:"
print $"  Raw: ($env.WINDOWS_PATH? | default 'UNSET')"
print $"  Length: (($env.WINDOWS_PATH? | default '') | str length)"
print $"  Expected: C:\\Users\\Developer\\AppData\\Local"

print ""
print "REGEX_PATTERN:"
print $"  Raw: ($env.REGEX_PATTERN? | default 'UNSET')"
print $"  Length: (($env.REGEX_PATTERN? | default '') | str length)"
print $"  Expected: \\d{4}-\\d{2}-\\d{2}"

print ""
print "SPECIAL_CHARS_TEST:"
print $"  Raw: ($env.SPECIAL_CHARS_TEST? | default 'UNSET')"
print $"  Length: (($env.SPECIAL_CHARS_TEST? | default '') | str length)"
print $"  Expected: !@#$%^&*()_+-=[]{}|;:,.<>?"

print ""
print "NODE_OPTIONS:"
print $"  Raw: ($env.NODE_OPTIONS? | default 'UNSET')"
print $"  Length: (($env.NODE_OPTIONS? | default '') | str length)"
print $"  Expected: --max-old-space-size=4096"
