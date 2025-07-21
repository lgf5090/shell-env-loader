# Nushell Environment Variable Loader
# ====================================
# Nushell-specific implementation of the cross-shell environment loader
# Uses Nushell's structured data and pipeline features

# Platform detection (Nushell version)
def detect_platform [] {
    let os_info = (sys host)
    let os_name = $os_info.name

    if ($os_name | str contains "Linux") {
        # Check for WSL
        if ("/proc/version" | path exists) {
            let version = (open "/proc/version" | str contains "Microsoft")
            if $version {
                "WSL"
            } else {
                "LINUX"
            }
        } else {
            "LINUX"
        }
    } else if ($os_name | str contains "Darwin") {
        "MACOS"
    } else if ($os_name | str contains "Windows") {
        "WIN"
    } else {
        "UNIX"
    }
}

# Shell detection (Nushell version)
def detect_shell [] {
    "NUSHELL"
}

# Get shell suffix (Nushell version)
def get_shell_suffix [] {
    "_NU"
}

# Get platform suffixes (Nushell version)
def get_platform_suffixes [] {
    let platform = (detect_platform)
    match $platform {
        "WSL" => ["_WSL", "_LINUX", "_UNIX"]
        "LINUX" => ["_LINUX", "_UNIX"]
        "MACOS" => ["_MACOS", "_UNIX"]
        "WIN" => ["_WIN"]
        _ => ["_UNIX"]
    }
}

# Parse environment file (Nushell native)
def parse_env_file [file_path: string] {
    if not ($file_path | path exists) {
        return []
    }
    
    let content = (open $file_path | lines)
    let variables = ($content 
        | where ($it | str trim | str length) > 0  # Remove empty lines
        | where not ($it | str trim | str starts-with "#")  # Remove comments
        | where ($it | str contains "=")  # Only lines with assignments
        | each { |line| $line | str trim }
    )
    
    return $variables
}

# Extract base names from parsed variables (Nushell native)
def extract_base_names [variables: list<string>] {
    let base_names = ($variables 
        | each { |var| 
            let var_name = ($var | split row "=" | first)
            let base_name = ($var_name 
                | str replace --regex '_NUSHELL$|_NU$|_FISH$|_ZSH$|_BASH$|_PS$' ''
                | str replace --regex '_WSL$|_LINUX$|_MACOS$|_WIN$|_UNIX$' ''
            )
            $base_name
        }
        | uniq
    )
    
    return $base_names
}

# Get variable precedence score (Nushell native)
def get_variable_precedence [var_name: string] {
    let shell = (detect_shell)
    let platform = (detect_platform)
    mut score = 0

    # Base variable bonus (no suffix gets highest priority among same category)
    # Check if this is a base variable (no recognized suffix)
    let has_shell_suffix = ($var_name | str ends-with "_NUSHELL") or ($var_name | str ends-with "_NU") or ($var_name | str ends-with "_FISH") or ($var_name | str ends-with "_ZSH") or ($var_name | str ends-with "_BASH") or ($var_name | str ends-with "_PS")
    let has_platform_suffix = ($var_name | str ends-with "_WSL") or ($var_name | str ends-with "_LINUX") or ($var_name | str ends-with "_MACOS") or ($var_name | str ends-with "_WIN") or ($var_name | str ends-with "_UNIX")
    let has_other_suffix = ($var_name | str contains "_") and (not $has_shell_suffix) and (not $has_platform_suffix)

    # Shell-specific bonus
    if ($var_name | str ends-with $"_($shell)") or ($var_name | str ends-with "_NU") {
        $score = ($score + 1000)
    }

    # Platform-specific bonus
    match $platform {
        "WSL" => {
            if ($var_name | str ends-with "_WSL") {
                $score = ($score + 100)
            } else if ($var_name | str ends-with "_LINUX") {
                $score = ($score + 50)
            } else if ($var_name | str ends-with "_UNIX") {
                $score = ($score + 10)
            }
        }
        "LINUX" => {
            if ($var_name | str ends-with "_LINUX") {
                $score = ($score + 100)
            } else if ($var_name | str ends-with "_UNIX") {
                $score = ($score + 10)
            }
        }
        "MACOS" => {
            if ($var_name | str ends-with "_MACOS") {
                $score = ($score + 100)
            } else if ($var_name | str ends-with "_UNIX") {
                $score = ($score + 10)
            }
        }
        "WIN" => {
            if ($var_name | str ends-with "_WIN") {
                $score = ($score + 100)
            }
        }
    }

    # Base variable gets priority over variables with other suffixes
    if (not $has_shell_suffix) and (not $has_platform_suffix) and (not $has_other_suffix) {
        $score = ($score + 500)  # Base variable bonus
    } else if $has_other_suffix {
        $score = ($score - 100)  # Penalty for other suffixes like _BASIC, _PREFERRED, etc.
    }

    return $score
}

# Resolve variable precedence (Nushell native)
def resolve_variable_precedence [base_name: string, candidates: list<string>] {
    let best_candidate = ($candidates 
        | each { |candidate|
            let parts = ($candidate | split row "=" | take 2)
            let var_name = ($parts | first)
            let var_value = (if (($parts | length) > 1) { $parts | last } else { "" })
            let score = (get_variable_precedence $var_name)
            
            {
                var_name: $var_name,
                var_value: $var_value,
                score: $score
            }
        }
        | sort-by score --reverse
        | first
    )
    
    return $best_candidate.var_value
}

# Expand environment variables in a value (Nushell native)
def expand_environment_variables [value: string] {
    mut expanded_value = $value
    
    # Remove surrounding quotes
    if ($expanded_value | str starts-with '"') and ($expanded_value | str ends-with '"') {
        $expanded_value = ($expanded_value | str substring 1..(-2))
    } else if ($expanded_value | str starts-with "'") and ($expanded_value | str ends-with "'") {
        $expanded_value = ($expanded_value | str substring 1..(-2))
    }
    
    # Basic variable expansion
    $expanded_value = ($expanded_value | str replace --all '$HOME' $env.HOME)
    $expanded_value = ($expanded_value | str replace --all '$USER' $env.USER)
    $expanded_value = ($expanded_value | str replace --all '~' $env.HOME)
    
    # Windows-style variables (if they exist)
    if 'USERPROFILE' in $env {
        $expanded_value = ($expanded_value | str replace --all '%USERPROFILE%' $env.USERPROFILE)
    }
    if 'USERNAME' in $env {
        $expanded_value = ($expanded_value | str replace --all '%USERNAME%' $env.USERNAME)
    }
    
    # Simple command substitution for date
    if ($expanded_value | str contains '$(date +%Y%m%d)') {
        let date_str = (date now | format date "%Y%m%d")
        $expanded_value = ($expanded_value | str replace --all '$(date +%Y%m%d)' $date_str)
    }
    
    return $expanded_value
}

# Set environment variable using Nushell global assignment
def set_environment_variable [key: string, value: string] {
    # Validate key
    if not ($key =~ '^[A-Za-z_][A-Za-z0-9_]*$') {
        print $"Warning: Invalid variable name: ($key)"
        return false
    }

    # Set the environment variable using global assignment
    # Note: We'll handle this in the caller since dynamic key assignment is complex
    return true
}

# Load environment variables from a single file (Nushell native)
def load_env_file [file_path: string] {
    if not ($file_path | path exists) {
        return  # Silently skip missing files
    }
    
    if ($env.ENV_LOADER_DEBUG? | default false) == "true" {
        print $"Loading environment variables from: ($file_path)"
    }
    
    # Parse the file
    let parsed_vars = (parse_env_file $file_path)
    if ($parsed_vars | length) == 0 {
        if ($env.ENV_LOADER_DEBUG? | default false) == "true" {
            print $"Warning: No variables found in ($file_path)"
        }
        return
    }
    
    # Extract unique base names
    let base_names = (extract_base_names $parsed_vars)
    
    # Process each base name
    for base_name in $base_names {
        if ($base_name | str length) == 0 {
            continue
        }
        
        # Find all candidates for this base name
        let candidates = ($parsed_vars 
            | where { |var|
                let var_name = ($var | split row "=" | first)
                ($var_name == $base_name) or ($var_name | str starts-with $"($base_name)_")
            }
        )
        
        # Resolve precedence and get the best value
        if ($candidates | length) > 0 {
            let best_value = (resolve_variable_precedence $base_name $candidates)
            
            if ($best_value | str length) > 0 {
                # Expand environment variables if needed
                let expanded_value = if ($best_value | str contains '$') or ($best_value | str contains '%') or ($best_value | str contains '~') {
                    expand_environment_variables $best_value
                } else {
                    $best_value
                }
                
                # Special handling for PATH variables using global $env assignment
                match $base_name {
                    "PATH_ADDITION" => {
                        # Append to existing PATH using global $env assignment
                        let path_additions = ($expanded_value | split row ":")
                        let current_path = $env.PATH
                        let new_path = ($current_path | append $path_additions)
                        $env.PATH = $new_path

                        # Also set the variable for reference using global assignment
                        $env.PATH_ADDITION = $expanded_value

                        if ($env.ENV_LOADER_DEBUG? | default false) == "true" {
                            print $"  Appended to PATH: ($expanded_value)"
                            print $"  New PATH length: ($new_path | length)"
                        }
                    }
                    "PATH_EXPORT" => {
                        # Handle PATH export using global assignment
                        $env.PATH_EXPORT = $expanded_value

                        if ($env.ENV_LOADER_DEBUG? | default false) == "true" {
                            print $"  Set PATH_EXPORT: ($expanded_value)"
                        }
                    }
                    "PATH" => {
                        # Direct PATH replacement using global assignment
                        if ($expanded_value | str contains ":") {
                            let path_entries = ($expanded_value | split row ":")
                            $env.PATH = $path_entries
                        } else {
                            $env.PATH = [$expanded_value]
                        }

                        if ($env.ENV_LOADER_DEBUG? | default false) == "true" {
                            print $"  Set PATH: ($expanded_value)"
                        }
                    }
                    _ => {
                        # Regular variable using global assignment
                        # Handle specific common variables with direct assignment
                        match $base_name {
                            "EDITOR" => { $env.EDITOR = $expanded_value }
                            "VISUAL" => { $env.VISUAL = $expanded_value }
                            "PAGER" => { $env.PAGER = $expanded_value }
                            "TERM" => { $env.TERM = $expanded_value }
                            "COLORTERM" => { $env.COLORTERM = $expanded_value }
                            "USER_HOME" => { $env.USER_HOME = $expanded_value }
                            "CONFIG_DIR" => { $env.CONFIG_DIR = $expanded_value }
                            "TEMP_DIR" => { $env.TEMP_DIR = $expanded_value }
                            "SYSTEM_BIN" => { $env.SYSTEM_BIN = $expanded_value }
                            "NODE_VERSION" => { $env.NODE_VERSION = $expanded_value }
                            "PYTHON_VERSION" => { $env.PYTHON_VERSION = $expanded_value }
                            "GO_VERSION" => { $env.GO_VERSION = $expanded_value }
                            "DEV_HOME" => { $env.DEV_HOME = $expanded_value }
                            "PROJECTS_DIR" => { $env.PROJECTS_DIR = $expanded_value }
                            "WORKSPACE_DIR" => { $env.WORKSPACE_DIR = $expanded_value }
                            "GIT_EDITOR" => { $env.GIT_EDITOR = $expanded_value }
                            "GIT_PAGER" => { $env.GIT_PAGER = $expanded_value }
                            "GIT_DEFAULT_BRANCH" => { $env.GIT_DEFAULT_BRANCH = $expanded_value }
                            "LOCAL_BIN" => { $env.LOCAL_BIN = $expanded_value }
                            "CARGO_BIN" => { $env.CARGO_BIN = $expanded_value }
                            "GO_BIN" => { $env.GO_BIN = $expanded_value }
                            "DOCKER_HOST" => { $env.DOCKER_HOST = $expanded_value }
                            "COMPOSE_PROJECT_NAME" => { $env.COMPOSE_PROJECT_NAME = $expanded_value }
                            "DATABASE_URL" => { $env.DATABASE_URL = $expanded_value }
                            "REDIS_URL" => { $env.REDIS_URL = $expanded_value }
                            "MONGODB_URL" => { $env.MONGODB_URL = $expanded_value }
                            "API_KEY" => { $env.API_KEY = $expanded_value }
                            "JWT_SECRET" => { $env.JWT_SECRET = $expanded_value }
                            "GITHUB_TOKEN" => { $env.GITHUB_TOKEN = $expanded_value }
                            "TEST_BASIC" => { $env.TEST_BASIC = $expanded_value }
                            "TEST_QUOTED" => { $env.TEST_QUOTED = $expanded_value }
                            "TEST_SHELL" => { $env.TEST_SHELL = $expanded_value }
                            "TEST_PLATFORM" => { $env.TEST_PLATFORM = $expanded_value }
                            "SPECIAL_CHARS_TEST" => { $env.SPECIAL_CHARS_TEST = $expanded_value }
                            "UNICODE_TEST" => { $env.UNICODE_TEST = $expanded_value }
                            "PATH_TEST" => { $env.PATH_TEST = $expanded_value }
                            _ => {
                                # For other variables, use load-env as fallback
                                load-env {$base_name: $expanded_value}
                            }
                        }

                        # Debug output
                        if ($env.ENV_LOADER_DEBUG? | default false) == "true" {
                            print $"  Set ($base_name)=($expanded_value)"
                        }
                    }
                }
            }
        }
    }
}

# Main load function
def main [file_path?: string] {
    let target_file = ($file_path | default ".env.example")
    load_env_file $target_file
}

# Test function
def test_nushell_loader [] {
    print "Testing Nushell loader..."
    $env.ENV_LOADER_DEBUG = "true"
    
    # Test basic loading
    hide-env EDITOR
    hide-env TEST_BASIC
    
    print "Before loading:"
    print $"  EDITOR: [($env.EDITOR? | default 'UNSET')]"
    print $"  TEST_BASIC: [($env.TEST_BASIC? | default 'UNSET')]"
    
    load_env_file ".env.example"
    
    print "After loading:"
    print $"  EDITOR: [($env.EDITOR? | default 'UNSET')]"
    print $"  TEST_BASIC: [($env.TEST_BASIC? | default 'UNSET')]"
    print $"  Platform: (detect_platform)"
    print $"  Shell: (detect_shell)"
}

# Export functions for module usage
export def "env load" [file_path?: string] {
    main $file_path
}

export def "env test" [] {
    test_nushell_loader
}

export def "env platform" [] {
    detect_platform
}

export def "env shell" [] {
    detect_shell
}
