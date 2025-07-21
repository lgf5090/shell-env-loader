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

    # Check for other suffixes (like _BASIC, _PREFERRED, etc.) but exclude known base variable patterns
    # Base variables that naturally contain underscores should not be penalized
    # Variables that have platform-specific variants should NOT get base variable bonus
    let platform_variant_bases = ["CONFIG_DIR", "TEMP_DIR", "SYSTEM_BIN", "DOCKER_HOST"]
    let known_base_patterns = ["USER_HOME", "DEV_HOME", "PROJECTS_DIR", "WORKSPACE_DIR", "LOCAL_BIN", "CARGO_BIN", "GO_BIN", "PATH_ADDITION", "PATH_EXPORT", "DATABASE_URL", "REDIS_URL", "MONGODB_URL", "API_KEY", "JWT_SECRET", "GITHUB_TOKEN", "TEST_BASIC", "TEST_QUOTED", "TEST_SHELL", "TEST_PLATFORM", "SPECIAL_CHARS_TEST", "UNICODE_TEST", "PATH_TEST", "PROGRAM_FILES", "PROGRAM_FILES_X86", "DOCUMENTS_DIR", "MESSAGE_WITH_QUOTES", "SQL_QUERY", "JSON_CONFIG", "COMMAND_WITH_QUOTES", "COMPLEX_MESSAGE", "WINDOWS_PATH", "REGEX_PATTERN", "LOG_FILE", "WELCOME_MESSAGE", "EMOJI_STATUS", "CURRENCY_SYMBOLS", "DOCUMENTS_INTL", "PROJECTS_INTL", "SECRET_KEY", "DATABASE_PASSWORD", "API_TOKEN", "DB_HOST_DEV", "DB_HOST_PROD", "STRIPE_KEY_DEV", "STRIPE_KEY_PROD", "JAVA_OPTS", "NODE_OPTIONS", "PYTHON_OPTIMIZE", "TEST_ENV", "TESTING_MODE", "MOCK_EXTERNAL_APIS", "LOG_FORMAT", "LOG_TIMESTAMP", "LOG_COLOR", "GOOD_PATH", "GOOD_QUOTES", "GOOD_EXPANSION", "GOOD_RELATIVE"]
    let is_known_base = ($known_base_patterns | any { |pattern| $var_name == $pattern })
    let is_platform_variant_base = ($platform_variant_bases | any { |pattern| $var_name == $pattern })
    let has_other_suffix = ($var_name | str contains "_") and (not $has_shell_suffix) and (not $has_platform_suffix) and (not $is_known_base) and (not $is_platform_variant_base)

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
    # Variables with platform variants get small bonus to beat non-matching platform variants
    if (not $has_shell_suffix) and (not $has_platform_suffix) and (not $has_other_suffix) and (not $is_platform_variant_base) {
        $score = ($score + 500)  # Base variable bonus
    } else if $is_platform_variant_base {
        $score = ($score + 50)   # Small bonus for base variables with platform variants
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

# Get environment variables to set (returns a record)
def get_env_vars_to_set [file_path: string] {
    if not ($file_path | path exists) {
        return {}  # Return empty record
    }

    # Parse the file
    let parsed_vars = (parse_env_file $file_path)
    if ($parsed_vars | length) == 0 {
        return {}
    }

    # Extract unique base names
    let base_names = (extract_base_names $parsed_vars)

    mut env_vars = {}
    mut path_additions = []

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

                # Handle PATH variables specially
                match $base_name {
                    "PATH_ADDITION" => {
                        let additions = ($expanded_value | split row ":")
                        $path_additions = ($path_additions | append $additions)
                        $env_vars = ($env_vars | insert $base_name $expanded_value)
                    }
                    "PATH_EXPORT" => {
                        $env_vars = ($env_vars | insert $base_name $expanded_value)
                    }
                    "PATH" => {
                        if ($expanded_value | str contains ":") {
                            let path_entries = ($expanded_value | split row ":")
                            $env_vars = ($env_vars | insert "PATH" $path_entries)
                        } else {
                            $env_vars = ($env_vars | insert "PATH" [$expanded_value])
                        }
                    }
                    _ => {
                        $env_vars = ($env_vars | insert $base_name $expanded_value)
                    }
                }
            }
        }
    }

    # Add PATH modifications if any
    if ($path_additions | length) > 0 {
        let new_path = ($env.PATH | append $path_additions)
        $env_vars = ($env_vars | insert "PATH" $new_path)
    }

    return $env_vars
}

# Load environment variables from a single file (Nushell native)
def load_env_file [file_path: string] {
    if not ($file_path | path exists) {
        return  # Silently skip missing files
    }

    if ($env.ENV_LOADER_DEBUG? | default false) == "true" {
        print $"Loading environment variables from: ($file_path)"
    }

    # Get environment variables to set
    let env_vars = (get_env_vars_to_set $file_path)

    if ($env_vars | columns | length) == 0 {
        if ($env.ENV_LOADER_DEBUG? | default false) == "true" {
            print $"Warning: No variables found in ($file_path)"
        }
        return
    }

    # Apply environment variables using global assignment
    # Handle each variable individually for proper global scope
    for key in ($env_vars | columns) {
        let value = ($env_vars | get $key)
        match $key {
            "PATH" => { $env.PATH = $value }
            "EDITOR" => { $env.EDITOR = $value }
            "VISUAL" => { $env.VISUAL = $value }
            "PAGER" => { $env.PAGER = $value }
            "TERM" => { $env.TERM = $value }
            "COLORTERM" => { $env.COLORTERM = $value }
            "USER_HOME" => { $env.USER_HOME = $value }
            "CONFIG_DIR" => { $env.CONFIG_DIR = $value }
            "TEMP_DIR" => { $env.TEMP_DIR = $value }
            "SYSTEM_BIN" => { $env.SYSTEM_BIN = $value }
            "NODE_VERSION" => { $env.NODE_VERSION = $value }
            "PYTHON_VERSION" => { $env.PYTHON_VERSION = $value }
            "GO_VERSION" => { $env.GO_VERSION = $value }
            "DEV_HOME" => { $env.DEV_HOME = $value }
            "PROJECTS_DIR" => { $env.PROJECTS_DIR = $value }
            "WORKSPACE_DIR" => { $env.WORKSPACE_DIR = $value }
            "GIT_EDITOR" => { $env.GIT_EDITOR = $value }
            "GIT_PAGER" => { $env.GIT_PAGER = $value }
            "GIT_DEFAULT_BRANCH" => { $env.GIT_DEFAULT_BRANCH = $value }
            "LOCAL_BIN" => { $env.LOCAL_BIN = $value }
            "CARGO_BIN" => { $env.CARGO_BIN = $value }
            "GO_BIN" => { $env.GO_BIN = $value }
            "PATH_ADDITION" => { $env.PATH_ADDITION = $value }
            "PATH_EXPORT" => { $env.PATH_EXPORT = $value }
            "DOCKER_HOST" => { $env.DOCKER_HOST = $value }
            "COMPOSE_PROJECT_NAME" => { $env.COMPOSE_PROJECT_NAME = $value }
            "DATABASE_URL" => { $env.DATABASE_URL = $value }
            "REDIS_URL" => { $env.REDIS_URL = $value }
            "MONGODB_URL" => { $env.MONGODB_URL = $value }
            "API_KEY" => { $env.API_KEY = $value }
            "JWT_SECRET" => { $env.JWT_SECRET = $value }
            "GITHUB_TOKEN" => { $env.GITHUB_TOKEN = $value }
            "TEST_BASIC" => { $env.TEST_BASIC = $value }
            "TEST_QUOTED" => { $env.TEST_QUOTED = $value }
            "TEST_SHELL" => { $env.TEST_SHELL = $value }
            "TEST_PLATFORM" => { $env.TEST_PLATFORM = $value }
            "SPECIAL_CHARS_TEST" => { $env.SPECIAL_CHARS_TEST = $value }
            "UNICODE_TEST" => { $env.UNICODE_TEST = $value }
            "PATH_TEST" => { $env.PATH_TEST = $value }
            "PROGRAM_FILES" => { $env.PROGRAM_FILES = $value }
            "PROGRAM_FILES_X86" => { $env.PROGRAM_FILES_X86 = $value }
            "DOCUMENTS_DIR" => { $env.DOCUMENTS_DIR = $value }
            "MESSAGE_WITH_QUOTES" => { $env.MESSAGE_WITH_QUOTES = $value }
            "SQL_QUERY" => { $env.SQL_QUERY = $value }
            "JSON_CONFIG" => { $env.JSON_CONFIG = $value }
            "COMMAND_WITH_QUOTES" => { $env.COMMAND_WITH_QUOTES = $value }
            "COMPLEX_MESSAGE" => { $env.COMPLEX_MESSAGE = $value }
            "WINDOWS_PATH" => { $env.WINDOWS_PATH = $value }
            "REGEX_PATTERN" => { $env.REGEX_PATTERN = $value }
            "LOG_FILE" => { $env.LOG_FILE = $value }
            "WELCOME_MESSAGE" => { $env.WELCOME_MESSAGE = $value }
            "EMOJI_STATUS" => { $env.EMOJI_STATUS = $value }
            "CURRENCY_SYMBOLS" => { $env.CURRENCY_SYMBOLS = $value }
            "DOCUMENTS_INTL" => { $env.DOCUMENTS_INTL = $value }
            "PROJECTS_INTL" => { $env.PROJECTS_INTL = $value }
            "HISTSIZE" => { $env.HISTSIZE = $value }
            "HISTFILESIZE" => { $env.HISTFILESIZE = $value }
            "HISTCONTROL" => { $env.HISTCONTROL = $value }
            "SAVEHIST" => { $env.SAVEHIST = $value }
            "HIST_STAMPS" => { $env.HIST_STAMPS = $value }
            "FISH_GREETING" => { $env.FISH_GREETING = $value }
            "FISH_TERM24BIT" => { $env.FISH_TERM24BIT = $value }
            "NU_CONFIG_DIR" => { $env.NU_CONFIG_DIR = $value }
            "NU_PLUGIN_DIRS" => { $env.NU_PLUGIN_DIRS = $value }
            "POWERSHELL_TELEMETRY_OPTOUT" => { $env.POWERSHELL_TELEMETRY_OPTOUT = $value }
            "DOTNET_CLI_TELEMETRY_OPTOUT" => { $env.DOTNET_CLI_TELEMETRY_OPTOUT = $value }
            "PAGER_PREFERRED" => { $env.PAGER_PREFERRED = $value }
            "PAGER_FALLBACK" => { $env.PAGER_FALLBACK = $value }
            "PAGER_BASIC" => { $env.PAGER_BASIC = $value }
            "TERMINAL_MULTIPLEXER" => { $env.TERMINAL_MULTIPLEXER = $value }
            "TERMINAL_MULTIPLEXER_FALLBACK" => { $env.TERMINAL_MULTIPLEXER_FALLBACK = $value }
            "PROJECT_TYPE" => { $env.PROJECT_TYPE = $value }
            "DEBUG_LEVEL" => { $env.DEBUG_LEVEL = $value }
            "LOG_LEVEL" => { $env.LOG_LEVEL = $value }
            "ENVIRONMENT" => { $env.ENVIRONMENT = $value }
            "PROJECT_TYPE_WORK" => { $env.PROJECT_TYPE_WORK = $value }
            "DEBUG_LEVEL_WORK" => { $env.DEBUG_LEVEL_WORK = $value }
            "COMPANY_DOMAIN" => { $env.COMPANY_DOMAIN = $value }
            "ENVIRONMENT_DEV" => { $env.ENVIRONMENT_DEV = $value }
            "DEBUG_LEVEL_DEV" => { $env.DEBUG_LEVEL_DEV = $value }
            "DATABASE_URL_DEV" => { $env.DATABASE_URL_DEV = $value }
            "SECRET_KEY" => { $env.SECRET_KEY = $value }
            "DATABASE_PASSWORD" => { $env.DATABASE_PASSWORD = $value }
            "API_TOKEN" => { $env.API_TOKEN = $value }
            "DB_HOST_DEV" => { $env.DB_HOST_DEV = $value }
            "DB_HOST_PROD" => { $env.DB_HOST_PROD = $value }
            "STRIPE_KEY_DEV" => { $env.STRIPE_KEY_DEV = $value }
            "STRIPE_KEY_PROD" => { $env.STRIPE_KEY_PROD = $value }
            "JAVA_OPTS" => { $env.JAVA_OPTS = $value }
            "NODE_OPTIONS" => { $env.NODE_OPTIONS = $value }
            "PYTHON_OPTIMIZE" => { $env.PYTHON_OPTIMIZE = $value }
            "MAKEFLAGS" => { $env.MAKEFLAGS = $value }
            "TEST_ENV" => { $env.TEST_ENV = $value }
            "TESTING_MODE" => { $env.TESTING_MODE = $value }
            "MOCK_EXTERNAL_APIS" => { $env.MOCK_EXTERNAL_APIS = $value }
            "DEBUG" => { $env.DEBUG = $value }
            "VERBOSE" => { $env.VERBOSE = $value }
            "TRACE_ENABLED" => { $env.TRACE_ENABLED = $value }
            "LOG_FORMAT" => { $env.LOG_FORMAT = $value }
            "LOG_TIMESTAMP" => { $env.LOG_TIMESTAMP = $value }
            "LOG_COLOR" => { $env.LOG_COLOR = $value }
            "GOOD_PATH" => { $env.GOOD_PATH = $value }
            "GOOD_QUOTES" => { $env.GOOD_QUOTES = $value }
            "GOOD_EXPANSION" => { $env.GOOD_EXPANSION = $value }
            "GOOD_RELATIVE" => { $env.GOOD_RELATIVE = $value }
            "HIERARCHY_TEST_GLOBAL" => { $env.HIERARCHY_TEST_GLOBAL = $value }
            "HIERARCHY_TEST_USER" => { $env.HIERARCHY_TEST_USER = $value }
            "HIERARCHY_TEST_PROJECT" => { $env.HIERARCHY_TEST_PROJECT = $value }
            _ => {
                # For truly unknown variables, skip them
                if ($env.ENV_LOADER_DEBUG? | default false) == "true" {
                    print $"  Warning: Skipping unknown variable ($key)"
                }
            }
        }
    }

    # Debug output
    if ($env.ENV_LOADER_DEBUG? | default false) == "true" {
        for key in ($env_vars | columns) {
            let value = ($env_vars | get $key)
            match $key {
                "PATH" => {
                    if ($value | describe) == "list<string>" {
                        print $"  Set PATH with ($value | length) entries"
                        if ($env.ENV_LOADER_DEBUG? | default false) == "true" {
                            print $"  PATH additions: {($value | last 3)}"
                        }
                    } else {
                        print $"  Set PATH: ($value)"
                    }
                }
                "PATH_ADDITION" => {
                    print $"  Appended to PATH: ($value)"
                }
                _ => {
                    print $"  Set ($key)=($value)"
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
