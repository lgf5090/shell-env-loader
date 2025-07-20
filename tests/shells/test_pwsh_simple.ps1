# Simple PowerShell Tests
# =======================
# Basic functionality test for PowerShell implementation

# Colors for output (PowerShell style)
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

Write-Host "${Blue}Running Simple PowerShell Tests${Reset}"
Write-Host "=================================="

# Test counters
$totalTests = 0
$passedTests = 0

# Test function
function Test-Variable {
    param(
        [string]$Expected,
        [string]$Actual,
        [string]$TestName
    )
    
    $script:totalTests++
    
    if ($Expected -eq $Actual) {
        Write-Host "${Green}✅ ${TestName}: PASS${Reset}"
        $script:passedTests++
    } else {
        Write-Host "${Red}❌ ${TestName}: FAIL${Reset} (expected: '$Expected', got: '$Actual')"
    }
}

# Get platform for platform-specific tests
function Get-TestPlatform {
    if ($IsWindows -or ($env:OS -eq "Windows_NT")) {
        return "WIN"
    } elseif ($IsLinux) {
        if (Test-Path "/proc/version") {
            $version = Get-Content "/proc/version" -ErrorAction SilentlyContinue
            if ($version -match "Microsoft") {
                return "WSL"
            }
        }
        return "LINUX"
    } elseif ($IsMacOS) {
        return "MACOS"
    } else {
        return "UNIX"
    }
}

$platform = Get-TestPlatform

Write-Host "`n${Yellow}Testing PowerShell Mode:${Reset}"

# Source the PowerShell loader
. "./src/shells/pwsh/loader.ps1"

# Clear variables for clean test
Remove-Item -Path "env:EDITOR" -ErrorAction SilentlyContinue
Remove-Item -Path "env:VISUAL" -ErrorAction SilentlyContinue
Remove-Item -Path "env:PAGER" -ErrorAction SilentlyContinue
Remove-Item -Path "env:TERM" -ErrorAction SilentlyContinue
Remove-Item -Path "env:COLORTERM" -ErrorAction SilentlyContinue
Remove-Item -Path "env:CONFIG_DIR" -ErrorAction SilentlyContinue
Remove-Item -Path "env:NODE_VERSION" -ErrorAction SilentlyContinue
Remove-Item -Path "env:GIT_DEFAULT_BRANCH" -ErrorAction SilentlyContinue
Remove-Item -Path "env:API_KEY" -ErrorAction SilentlyContinue
Remove-Item -Path "env:DATABASE_URL" -ErrorAction SilentlyContinue
Remove-Item -Path "env:DOCUMENTS_DIR" -ErrorAction SilentlyContinue
Remove-Item -Path "env:WELCOME_MESSAGE" -ErrorAction SilentlyContinue
Remove-Item -Path "env:TEST_BASIC" -ErrorAction SilentlyContinue
Remove-Item -Path "env:TEST_QUOTED" -ErrorAction SilentlyContinue
Remove-Item -Path "env:TEST_SHELL" -ErrorAction SilentlyContinue
Remove-Item -Path "env:SPECIAL_CHARS_TEST" -ErrorAction SilentlyContinue
Remove-Item -Path "env:UNICODE_TEST" -ErrorAction SilentlyContinue

# Load environment variables
Import-EnvFile ".env.example"

# Test results
Test-Variable "POWERSHELL" (Get-Shell) "PowerShell shell detection"

# Basic environment variables
Test-Variable "vim" $env:EDITOR "EDITOR variable"
Test-Variable "vim" $env:VISUAL "VISUAL variable"
Test-Variable "less" $env:PAGER "PAGER variable"
Test-Variable "xterm-256color" $env:TERM "TERM variable"
Test-Variable "truecolor" $env:COLORTERM "COLORTERM variable"

# Platform-specific variables
switch ($platform) {
    "LINUX" {
        # CONFIG_DIR should be expanded to full path
        $expectedConfigDir = $env:HOME + "/.config/linux"
        Test-Variable $expectedConfigDir $env:CONFIG_DIR "CONFIG_DIR_LINUX precedence (expanded)"
    }
    default {
        $expectedConfigDir = $env:HOME + "/.config"
        Test-Variable $expectedConfigDir $env:CONFIG_DIR "CONFIG_DIR generic fallback (expanded)"
    }
}

# Development environment
Test-Variable "18.17.0" $env:NODE_VERSION "NODE_VERSION variable"
Test-Variable "main" $env:GIT_DEFAULT_BRANCH "GIT_DEFAULT_BRANCH variable"

# Application configs
Test-Variable "your_api_key_here" $env:API_KEY "API_KEY variable"
Test-Variable "postgresql://localhost:5432/mydb" $env:DATABASE_URL "DATABASE_URL variable"

# Special characters (PowerShell handles quotes differently)
$expectedDocumentsDir = $env:HOME + "/Documents/My Projects"
Test-Variable $expectedDocumentsDir $env:DOCUMENTS_DIR "DOCUMENTS_DIR variable (expanded)"

Test-Variable "Welcome! 欢迎! Bienvenidos! Добро пожаловать!" $env:WELCOME_MESSAGE "WELCOME_MESSAGE variable"

# Test variables
Test-Variable "basic_value_works" $env:TEST_BASIC "TEST_BASIC variable"
Test-Variable "value with spaces works" $env:TEST_QUOTED "TEST_QUOTED variable"

# TEST_SHELL should prefer PowerShell-specific value if available, otherwise generic
# In .env.example, there's TEST_SHELL_PS=powershell_detected
Test-Variable "powershell_detected" $env:TEST_SHELL "TEST_SHELL variable (PowerShell precedence)"

Test-Variable "!@#`$%^&*()_+-=[]{}|;:,.<>?" $env:SPECIAL_CHARS_TEST "SPECIAL_CHARS_TEST variable"
Test-Variable "Testing: αβγ 中文 العربية русский 🎉" $env:UNICODE_TEST "UNICODE_TEST variable"

# Summary
Write-Host "`n${Blue}Simple PowerShell Test Summary:${Reset}"
Write-Host "==============================="
Write-Host "Platform: $platform"
Write-Host "Total tests: $totalTests"
Write-Host "${Green}Passed: $passedTests${Reset}"
Write-Host "${Red}Failed: $($totalTests - $passedTests)${Reset}"

if ($passedTests -eq $totalTests) {
    Write-Host "${Green}🎉 All tests passed! PowerShell implementation is working correctly${Reset}"
    exit 0
} else {
    Write-Host "${Red}💥 Some tests failed. Check the output above for details.${Reset}"
    exit 1
}
