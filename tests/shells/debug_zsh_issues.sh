#!/bin/zsh
# Debug Zsh specific issues

echo "Debugging Zsh issues..."

# Source the loader
source src/shells/bzsh/loader.sh

# Clear test variables
unset PROGRAM_FILES PROGRAM_FILES_X86 WINDOWS_PATH REGEX_PATTERN

# Load environment
load_env_file .env.example >/dev/null 2>&1

echo "Raw variable values:"
echo "PROGRAM_FILES: [$PROGRAM_FILES]"
echo "PROGRAM_FILES_X86: [$PROGRAM_FILES_X86]"
echo "WINDOWS_PATH: [$WINDOWS_PATH]"
echo "REGEX_PATTERN: [$REGEX_PATTERN]"

echo ""
echo "Hex dump of WINDOWS_PATH:"
echo -n "$WINDOWS_PATH" | xxd

echo ""
echo "Character count:"
echo "PROGRAM_FILES length: ${#PROGRAM_FILES}"
echo "WINDOWS_PATH length: ${#WINDOWS_PATH}"

echo ""
echo "Expected values:"
echo 'PROGRAM_FILES: [C:\\Program Files]'
echo 'PROGRAM_FILES_X86: [C:\\Program Files (x86)]'
echo 'WINDOWS_PATH: [C:\\Users\\Developer\\AppData\\Local]'
echo 'REGEX_PATTERN: [\\d{4}-\\d{2}-\\d{2}]'
