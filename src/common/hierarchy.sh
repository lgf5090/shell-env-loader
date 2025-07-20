#!/bin/bash
# File Hierarchy Management
# =========================
# POSIX-compatible functions for managing .env file hierarchy
# Handles the three-tier loading system: global -> user -> project

# Source platform detection utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/platform.sh"

# Get the list of .env files in hierarchical order (lowest to highest priority)
# Usage: get_env_file_hierarchy
# Returns: Newline-separated list of existing .env files
get_env_file_hierarchy() {
    local files=""
    local file
    
    # Global user settings (lowest priority)
    file="$(expand_tilde "$HOME/.env")"
    if [ -f "$file" ] && [ -r "$file" ]; then
        files="$files$file\n"
    fi
    
    # User configuration directory (medium priority)
    file="$(expand_tilde "$HOME/.cfgs/.env")"
    if [ -f "$file" ] && [ -r "$file" ]; then
        files="$files$file\n"
    fi
    
    # Project-specific settings (highest priority)
    file="$PWD/.env"
    if [ -f "$file" ] && [ -r "$file" ]; then
        files="$files$file\n"
    fi
    
    # Output files (remove trailing newline)
    printf "%b" "$files" | sed '/^$/d'
}

# Get file precedence score for a given file path
# Usage: get_file_precedence <file_path>
# Returns: Numeric precedence score (higher = higher priority)
get_file_precedence() {
    local file="$1"
    local normalized_file

    # Normalize the file path for comparison
    normalized_file="$(normalize_path "$file")"

    # Check against known hierarchy patterns
    # First check for .cfgs/.env pattern (more specific)
    case "$normalized_file" in
        *"/.cfgs/.env")
            # User configuration directory
            echo "50"
            return 0
            ;;
    esac

    # Then check for project .env
    case "$normalized_file" in
        *"/.env")
            # Project-specific (current directory)
            if [ "$(dirname "$normalized_file")" = "$PWD" ]; then
                echo "100"
            else
                echo "10"
            fi
            return 0
            ;;
    esac

    # Check if it's the global user .env
    local global_env
    global_env="$(expand_tilde "$HOME/.env")"
    if [ "$normalized_file" = "$global_env" ]; then
        echo "10"
    else
        # Unknown file, give it low priority
        echo "5"
    fi
}

# Create directory structure for .env files if it doesn't exist
# Usage: ensure_env_directories
ensure_env_directories() {
    local dir
    
    # Ensure user configuration directory exists
    dir="$(expand_tilde "$HOME/.cfgs")"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" 2>/dev/null || {
            echo "Warning: Could not create directory: $dir" >&2
            return 1
        }
    fi
    
    return 0
}

# Check if a file is readable and not empty
# Usage: is_valid_env_file <file_path>
# Returns: 0 if valid, 1 otherwise
is_valid_env_file() {
    local file="$1"
    
    # Check if file exists and is readable
    [ -f "$file" ] && [ -r "$file" ] && [ -s "$file" ]
}

# Get the relative path of a file from the current directory
# Usage: get_relative_path <file_path>
# Returns: Relative path or absolute path if not under current directory
get_relative_path() {
    local file="$1"
    local current_dir="$PWD"
    
    # If file starts with current directory, make it relative
    case "$file" in
        "$current_dir"/*)
            echo "./${file#$current_dir/}"
            ;;
        "$current_dir")
            echo "."
            ;;
        *)
            echo "$file"
            ;;
    esac
}

# Find all .env files in a directory tree (for debugging/discovery)
# Usage: find_env_files <directory>
# Returns: List of .env files found
find_env_files() {
    local search_dir="${1:-$PWD}"
    
    if [ ! -d "$search_dir" ]; then
        echo "Error: Directory does not exist: $search_dir" >&2
        return 1
    fi
    
    # Use find if available, otherwise use a simple approach
    if command_exists find; then
        find "$search_dir" -name ".env" -type f -readable 2>/dev/null
    else
        # Fallback: check common locations manually
        local file
        for file in "$search_dir/.env" "$search_dir"/*/.env "$search_dir"/*/*/.env; do
            if [ -f "$file" ] && [ -r "$file" ]; then
                echo "$file"
            fi
        done
    fi
}

# Backup an existing .env file before modification
# Usage: backup_env_file <file_path>
# Returns: Path to backup file or empty string on failure
backup_env_file() {
    local file="$1"
    local backup_file
    local timestamp
    
    if [ ! -f "$file" ]; then
        echo "Error: File does not exist: $file" >&2
        return 1
    fi
    
    # Create timestamp for backup
    timestamp=$(date +%Y%m%d_%H%M%S 2>/dev/null || echo "backup")
    backup_file="${file}.${timestamp}.bak"
    
    # Copy file to backup location
    if cp "$file" "$backup_file" 2>/dev/null; then
        echo "$backup_file"
        return 0
    else
        echo "Error: Could not create backup of $file" >&2
        return 1
    fi
}

# Clean up old backup files (keep only the most recent N backups)
# Usage: cleanup_env_backups <file_path> [max_backups]
cleanup_env_backups() {
    local file="$1"
    local max_backups="${2:-5}"
    local dir
    local basename
    local backup_pattern
    
    if [ ! -f "$file" ]; then
        return 0
    fi
    
    dir="$(dirname "$file")"
    basename="$(basename "$file")"
    backup_pattern="${basename}.*.bak"
    
    # Find and sort backup files by modification time (newest first)
    # Keep only the most recent backups
    if command_exists find && command_exists sort; then
        find "$dir" -name "$backup_pattern" -type f -printf '%T@ %p\n' 2>/dev/null | \
        sort -rn | \
        tail -n +$((max_backups + 1)) | \
        cut -d' ' -f2- | \
        while IFS= read -r backup_file; do
            rm -f "$backup_file" 2>/dev/null
        done
    fi
}

# Debug function to print hierarchy information
# Usage: debug_hierarchy_info
debug_hierarchy_info() {
    echo "File Hierarchy Debug Information:"
    echo "  Current directory: $PWD"
    echo "  Home directory: ${HOME:-N/A}"
    echo "  Available .env files:"
    
    local file
    get_env_file_hierarchy | while IFS= read -r file; do
        if [ -n "$file" ]; then
            local precedence
            local relative_path
            precedence=$(get_file_precedence "$file")
            relative_path=$(get_relative_path "$file")
            echo "    $relative_path (precedence: $precedence)"
        fi
    done
    
    echo "  User config directory exists: $([ -d "$(expand_tilde "$HOME/.cfgs")" ] && echo "yes" || echo "no")"
}
