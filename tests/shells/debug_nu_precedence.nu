# Debug Nushell Precedence Issues
# ================================
# Check why wrong platform variables are selected

print "Debug Nushell Precedence Issues"
print "==============================="

# Source loader
source "../../src/shells/nu/loader.nu"

# Enable debug
$env.ENV_LOADER_DEBUG = "true"

print "Platform detection:"
let platform = (detect_platform)
print $"Detected platform: ($platform)"

print ""
print "Shell detection:"
let shell = (detect_shell)
print $"Detected shell: ($shell)"

print ""
print "Testing specific problematic variables..."

# Test SYSTEM_BIN precedence
print ""
print "=== SYSTEM_BIN precedence test ==="
let system_bin_vars = [
    "SYSTEM_BIN=/usr/local/bin"
    "SYSTEM_BIN_WIN=C:\\Program Files"
    "SYSTEM_BIN_MACOS=/opt/homebrew/bin"
]

print "Available SYSTEM_BIN variables:"
for var in $system_bin_vars {
    print $"  ($var)"
}

print ""
print "Testing precedence calculation:"
for var in $system_bin_vars {
    let var_name = ($var | split row "=" | first)
    let precedence = (get_variable_precedence $var_name)
    print $"  ($var_name): precedence = ($precedence)"
}

# Test DOCKER_HOST precedence
print ""
print "=== DOCKER_HOST precedence test ==="
let docker_vars = [
    "DOCKER_HOST=unix:///var/run/docker.sock"
    "DOCKER_HOST_WIN=npipe:////./pipe/docker_engine"
]

print "Available DOCKER_HOST variables:"
for var in $docker_vars {
    print $"  ($var)"
}

print ""
print "Testing precedence calculation:"
for var in $docker_vars {
    let var_name = ($var | split row "=" | first)
    let precedence = (get_variable_precedence $var_name)
    print $"  ($var_name): precedence = ($precedence)"
}

# Test USER_HOME precedence
print ""
print "=== USER_HOME precedence test ==="
let user_home_vars = [
    "USER_HOME=/home/$USER"
    "USER_HOME_MACOS=/Users/$USER"
    "USER_HOME_WIN=C:\\Users\\%USERNAME%"
]

print "Available USER_HOME variables:"
for var in $user_home_vars {
    print $"  ($var)"
}

print ""
print "Testing precedence calculation:"
for var in $user_home_vars {
    let var_name = ($var | split row "=" | first)
    let precedence = (get_variable_precedence $var_name)
    print $"  ($var_name): precedence = ($precedence)"
}

print ""
print "=== Loading actual .env.example and checking results ==="
let env_vars = (get_env_vars_to_set "../../.env.example")

print ""
print "Actual selected values:"
if 'SYSTEM_BIN' in ($env_vars | columns) {
    print $"SYSTEM_BIN: ($env_vars | get SYSTEM_BIN)"
} else {
    print "SYSTEM_BIN: NOT_FOUND"
}

if 'DOCKER_HOST' in ($env_vars | columns) {
    print $"DOCKER_HOST: ($env_vars | get DOCKER_HOST)"
} else {
    print "DOCKER_HOST: NOT_FOUND"
}

if 'USER_HOME' in ($env_vars | columns) {
    print $"USER_HOME: ($env_vars | get USER_HOME)"
} else {
    print "USER_HOME: NOT_FOUND"
}

print ""
print "Expected values for Linux platform:"
print "SYSTEM_BIN: /usr/local/bin"
print "DOCKER_HOST: unix:///var/run/docker.sock"
print "USER_HOME: /home/$USER (expanded)"
