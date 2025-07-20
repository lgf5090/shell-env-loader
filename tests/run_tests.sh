#!/bin/bash
# Test Runner for Cross-Shell Environment Loader
# ===============================================
# Runs all test suites and provides comprehensive reporting

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Test statistics
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to run a test suite
run_test_suite() {
    local test_file="$1"
    local suite_name="$2"
    
    echo -e "${BLUE}${BOLD}Running $suite_name...${NC}"
    echo "$(printf '=%.0s' {1..50})"
    
    TOTAL_SUITES=$((TOTAL_SUITES + 1))
    
    if [ -f "$test_file" ] && [ -x "$test_file" ]; then
        if "$test_file"; then
            echo -e "${GREEN}${BOLD}✅ $suite_name PASSED${NC}"
            PASSED_SUITES=$((PASSED_SUITES + 1))
            return 0
        else
            echo -e "${RED}${BOLD}❌ $suite_name FAILED${NC}"
            FAILED_SUITES=$((FAILED_SUITES + 1))
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  $suite_name SKIPPED (file not found or not executable)${NC}"
        return 2
    fi
}

# Function to print test summary
print_summary() {
    echo
    echo -e "${BOLD}Test Summary${NC}"
    echo "$(printf '=%.0s' {1..30})"
    echo -e "Total test suites: $TOTAL_SUITES"
    echo -e "${GREEN}Passed: $PASSED_SUITES${NC}"
    echo -e "${RED}Failed: $FAILED_SUITES${NC}"
    
    if [ $FAILED_SUITES -eq 0 ]; then
        echo -e "${GREEN}${BOLD}🎉 All test suites passed!${NC}"
        return 0
    else
        echo -e "${RED}${BOLD}💥 Some test suites failed.${NC}"
        return 1
    fi
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    
    # Check if we're in the right directory
    if [ ! -d "$SCRIPT_DIR/../src" ]; then
        echo -e "${RED}Error: src directory not found. Please run from the project root.${NC}"
        return 1
    fi
    
    # Make test files executable
    find "$SCRIPT_DIR" -name "test_*.sh" -type f -exec chmod +x {} \; 2>/dev/null
    
    echo -e "${GREEN}Prerequisites check passed.${NC}"
    echo
}

# Function to run common tests
run_common_tests() {
    echo -e "${BOLD}Running Common Module Tests${NC}"
    echo "$(printf '=%.0s' {1..40})"
    echo
    
    run_test_suite "$SCRIPT_DIR/common/test_platform.sh" "Platform Detection Tests"
    echo
    run_test_suite "$SCRIPT_DIR/common/test_hierarchy.sh" "File Hierarchy Tests"
    echo
    
    # Add parser tests when available
    if [ -f "$SCRIPT_DIR/common/test_parser.sh" ]; then
        run_test_suite "$SCRIPT_DIR/common/test_parser.sh" "Parser Tests"
        echo
    fi
}

# Function to run shell-specific tests
run_shell_tests() {
    echo -e "${BOLD}Running Shell-Specific Tests${NC}"
    echo "$(printf '=%.0s' {1..40})"
    echo
    
    # Bash tests
    if [ -f "$SCRIPT_DIR/shells/test_bash.sh" ]; then
        run_test_suite "$SCRIPT_DIR/shells/test_bash.sh" "Bash Implementation Tests"
        echo
    fi
    
    # Zsh tests
    if [ -f "$SCRIPT_DIR/shells/test_zsh.sh" ]; then
        run_test_suite "$SCRIPT_DIR/shells/test_zsh.sh" "Zsh Implementation Tests"
        echo
    fi
    
    # Fish tests
    if [ -f "$SCRIPT_DIR/shells/test_fish.fish" ]; then
        if command -v fish >/dev/null 2>&1; then
            echo -e "${BLUE}${BOLD}Running Fish Implementation Tests...${NC}"
            echo "$(printf '=%.0s' {1..50})"
            TOTAL_SUITES=$((TOTAL_SUITES + 1))
            
            if fish "$SCRIPT_DIR/shells/test_fish.fish"; then
                echo -e "${GREEN}${BOLD}✅ Fish Implementation Tests PASSED${NC}"
                PASSED_SUITES=$((PASSED_SUITES + 1))
            else
                echo -e "${RED}${BOLD}❌ Fish Implementation Tests FAILED${NC}"
                FAILED_SUITES=$((FAILED_SUITES + 1))
            fi
            echo
        else
            echo -e "${YELLOW}⚠️  Fish Implementation Tests SKIPPED (fish not available)${NC}"
            echo
        fi
    fi
    
    # Nushell tests
    if [ -f "$SCRIPT_DIR/shells/test_nushell.nu" ]; then
        if command -v nu >/dev/null 2>&1; then
            echo -e "${BLUE}${BOLD}Running Nushell Implementation Tests...${NC}"
            echo "$(printf '=%.0s' {1..50})"
            TOTAL_SUITES=$((TOTAL_SUITES + 1))
            
            if nu "$SCRIPT_DIR/shells/test_nushell.nu"; then
                echo -e "${GREEN}${BOLD}✅ Nushell Implementation Tests PASSED${NC}"
                PASSED_SUITES=$((PASSED_SUITES + 1))
            else
                echo -e "${RED}${BOLD}❌ Nushell Implementation Tests FAILED${NC}"
                FAILED_SUITES=$((FAILED_SUITES + 1))
            fi
            echo
        else
            echo -e "${YELLOW}⚠️  Nushell Implementation Tests SKIPPED (nu not available)${NC}"
            echo
        fi
    fi
    
    # PowerShell tests
    if [ -f "$SCRIPT_DIR/shells/test_powershell.ps1" ]; then
        if command -v pwsh >/dev/null 2>&1; then
            echo -e "${BLUE}${BOLD}Running PowerShell Implementation Tests...${NC}"
            echo "$(printf '=%.0s' {1..50})"
            TOTAL_SUITES=$((TOTAL_SUITES + 1))
            
            if pwsh -NoProfile -NoLogo -File "$SCRIPT_DIR/shells/test_powershell.ps1"; then
                echo -e "${GREEN}${BOLD}✅ PowerShell Implementation Tests PASSED${NC}"
                PASSED_SUITES=$((PASSED_SUITES + 1))
            else
                echo -e "${RED}${BOLD}❌ PowerShell Implementation Tests FAILED${NC}"
                FAILED_SUITES=$((FAILED_SUITES + 1))
            fi
            echo
        else
            echo -e "${YELLOW}⚠️  PowerShell Implementation Tests SKIPPED (pwsh not available)${NC}"
            echo
        fi
    fi
}

# Function to run integration tests
run_integration_tests() {
    echo -e "${BOLD}Running Integration Tests${NC}"
    echo "$(printf '=%.0s' {1..40})"
    echo
    
    # Add integration tests when available
    if [ -f "$SCRIPT_DIR/integration/test_hierarchy.sh" ]; then
        run_test_suite "$SCRIPT_DIR/integration/test_hierarchy.sh" "Hierarchy Integration Tests"
        echo
    fi
    
    if [ -f "$SCRIPT_DIR/integration/test_precedence.sh" ]; then
        run_test_suite "$SCRIPT_DIR/integration/test_precedence.sh" "Precedence Integration Tests"
        echo
    fi
    
    if [ -f "$SCRIPT_DIR/integration/test_special_chars.sh" ]; then
        run_test_suite "$SCRIPT_DIR/integration/test_special_chars.sh" "Special Characters Integration Tests"
        echo
    fi
}

# Main function
main() {
    echo -e "${BOLD}Cross-Shell Environment Loader Test Suite${NC}"
    echo "$(printf '=%.0s' {1..50})"
    echo
    
    # Check prerequisites
    if ! check_prerequisites; then
        exit 1
    fi
    
    # Run test suites
    run_common_tests
    run_shell_tests
    run_integration_tests
    
    # Print summary and exit with appropriate code
    if print_summary; then
        exit 0
    else
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --common       Run only common module tests"
        echo "  --shells       Run only shell-specific tests"
        echo "  --integration  Run only integration tests"
        echo
        exit 0
        ;;
    --common)
        check_prerequisites && run_common_tests && print_summary
        exit $?
        ;;
    --shells)
        check_prerequisites && run_shell_tests && print_summary
        exit $?
        ;;
    --integration)
        check_prerequisites && run_integration_tests && print_summary
        exit $?
        ;;
    "")
        main
        ;;
    *)
        echo -e "${RED}Error: Unknown option '$1'${NC}"
        echo "Use --help for usage information."
        exit 1
        ;;
esac
