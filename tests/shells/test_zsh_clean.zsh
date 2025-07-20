#!/bin/zsh
# Clean Zsh Test - Run in completely fresh environment
# ====================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="${0:A:h}"

print -P "${BLUE}Running Clean Zsh Test...${NC}"
print "========================="

# Run test in a completely new zsh process
zsh -c "
# Prevent auto-initialization
export ENV_LOADER_INITIALIZED=true

# Source the loader
source '$SCRIPT_DIR/../../src/shells/zsh/loader.zsh'

# Clear the flag to allow loading
unset ENV_LOADER_INITIALIZED

# Clear variables
unset EDITOR VISUAL PAGER TERM COLORTERM TEST_SHELL HISTSIZE SAVEHIST HISTFILE CONFIG_DIR

# Load .env file
load_env_file '$SCRIPT_DIR/../../.env' 2>/dev/null

# Test variables
echo 'Testing variables:'
echo \"EDITOR=[\$EDITOR]\"
echo \"VISUAL=[\$VISUAL]\"
echo \"TEST_SHELL=[\$TEST_SHELL]\"
echo \"CONFIG_DIR=[\$CONFIG_DIR]\"
echo \"DOCUMENTS_DIR=[\$DOCUMENTS_DIR]\"
echo \"TEST_QUOTED=[\$TEST_QUOTED]\"

# Count successes
success_count=0
total_count=6

if [[ \"\$EDITOR\" == \"vim\" ]]; then
    echo '✅ EDITOR: PASS'
    ((success_count++))
else
    echo '❌ EDITOR: FAIL'
fi

if [[ \"\$VISUAL\" == \"vim\" ]]; then
    echo '✅ VISUAL: PASS'
    ((success_count++))
else
    echo '❌ VISUAL: FAIL'
fi

if [[ \"\$TEST_SHELL\" == \"zsh_detected\" ]]; then
    echo '✅ TEST_SHELL: PASS'
    ((success_count++))
else
    echo '❌ TEST_SHELL: FAIL'
fi

if [[ \"\$CONFIG_DIR\" == \"~/.config/linux\" ]]; then
    echo '✅ CONFIG_DIR: PASS'
    ((success_count++))
else
    echo '❌ CONFIG_DIR: FAIL'
fi

if [[ \"\$DOCUMENTS_DIR\" == \"/home/user/Documents\" ]]; then
    echo '✅ DOCUMENTS_DIR: PASS'
    ((success_count++))
else
    echo '❌ DOCUMENTS_DIR: FAIL'
fi

if [[ \"\$TEST_QUOTED\" == \"quoted value\" ]]; then
    echo '✅ TEST_QUOTED: PASS'
    ((success_count++))
else
    echo '❌ TEST_QUOTED: FAIL'
fi

echo
echo \"Results: \$success_count/\$total_count tests passed\"

if [[ \$success_count -eq \$total_count ]]; then
    echo '🎉 All tests passed!'
    exit 0
else
    echo '💥 Some tests failed!'
    exit 1
fi
"
