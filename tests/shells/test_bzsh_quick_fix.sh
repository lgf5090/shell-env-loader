#!/bin/bash
# Quick test to verify Bash/Zsh escape character fixes

echo "Testing escape character handling fixes..."

# Source the loader
source src/shells/bzsh/loader.sh

# Clear test variables
unset JSON_CONFIG COMMAND_WITH_QUOTES COMPLEX_MESSAGE PROGRAM_FILES WINDOWS_PATH REGEX_PATTERN

# Load environment
load_env_file .env.example >/dev/null 2>&1

echo "Test results:"
echo "JSON_CONFIG: [$JSON_CONFIG]"
echo "COMMAND_WITH_QUOTES: [$COMMAND_WITH_QUOTES]"
echo "COMPLEX_MESSAGE: [$COMPLEX_MESSAGE]"
echo "PROGRAM_FILES: [$PROGRAM_FILES]"
echo "WINDOWS_PATH: [$WINDOWS_PATH]"
echo "REGEX_PATTERN: [$REGEX_PATTERN]"

echo ""
echo "Expected values:"
echo 'JSON_CONFIG: [{"debug": true, "port": 3000}]'
echo 'COMMAND_WITH_QUOTES: [echo "Hello World"]'
echo 'COMPLEX_MESSAGE: [He said "It'\''s working!" with excitement]'
echo 'PROGRAM_FILES: [C:\Program Files]'
echo 'WINDOWS_PATH: [C:\Users\Developer\AppData\Local]'
echo 'REGEX_PATTERN: [\d{4}-\d{2}-\d{2}]'
