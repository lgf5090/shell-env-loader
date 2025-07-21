# Debug SYSTEM_BIN Issue
# =======================

print "Debug SYSTEM_BIN Issue"
print "======================"

# Source loader
source "../../src/shells/nu/loader.nu"

print "Getting environment variables..."
let env_vars = (get_env_vars_to_set "../../.env.example")

print ""
print "Checking SYSTEM_BIN related variables in result:"
for key in ($env_vars | columns) {
    if ($key | str contains "SYSTEM_BIN") {
        let value = ($env_vars | get $key)
        print $"  ($key): ($value)"
    }
}

print ""
print "Checking DOCKER_HOST related variables in result:"
for key in ($env_vars | columns) {
    if ($key | str contains "DOCKER_HOST") {
        let value = ($env_vars | get $key)
        print $"  ($key): ($value)"
    }
}

print ""
print "Applying SYSTEM_BIN manually..."
if 'SYSTEM_BIN' in ($env_vars | columns) {
    let value = ($env_vars | get SYSTEM_BIN)
    $env.SYSTEM_BIN = $value
    print $"Set SYSTEM_BIN to: ($value)"
    print $"Current SYSTEM_BIN: ($env.SYSTEM_BIN)"
} else {
    print "SYSTEM_BIN not found in env_vars"
}

print ""
print "Applying DOCKER_HOST manually..."
if 'DOCKER_HOST' in ($env_vars | columns) {
    let value = ($env_vars | get DOCKER_HOST)
    $env.DOCKER_HOST = $value
    print $"Set DOCKER_HOST to: ($value)"
    print $"Current DOCKER_HOST: ($env.DOCKER_HOST)"
} else {
    print "DOCKER_HOST not found in env_vars"
}
