# PowerShell Environment Variable Loader
# =======================================
# PowerShell-specific implementation of the cross-shell environment loader
# Uses PowerShell cmdlets and .NET methods for optimal performance

# Get the directory of this script (for future use)
# $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Platform detection (PowerShell version)
function Get-Platform {
    if ($IsWindows -or ($env:OS -eq "Windows_NT")) {
        return "WIN"
    } elseif ($IsLinux) {
        # Check for WSL
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

# Shell detection (PowerShell version)
function Get-Shell {
    return "POWERSHELL"
}

# Get shell suffix (PowerShell version)
function Get-ShellSuffix {
    return "_PS"
}

# Get platform suffixes (PowerShell version)
function Get-PlatformSuffixes {
    $platform = Get-Platform
    switch ($platform) {
        "WSL" { return @("_WSL", "_LINUX", "_UNIX") }
        "LINUX" { return @("_LINUX", "_UNIX") }
        "MACOS" { return @("_MACOS", "_UNIX") }
        "WIN" { return @("_WIN") }
        default { return @("_UNIX") }
    }
}

# Simple environment file parser (PowerShell native)
function Parse-EnvFile {
    param(
        [string]$FilePath
    )
    
    if (-not (Test-Path $FilePath)) {
        return @()
    }
    
    $variables = @()
    $content = Get-Content $FilePath -ErrorAction SilentlyContinue
    
    foreach ($line in $content) {
        # Skip empty lines and comments
        if ([string]::IsNullOrWhiteSpace($line) -or $line.Trim().StartsWith("#")) {
            continue
        }
        
        # Extract variable assignments (KEY=VALUE format)
        if ($line -match '^[A-Za-z_][A-Za-z0-9_]*=') {
            $variables += $line.Trim()
        }
    }
    
    return $variables
}

# Extract base names from parsed variables (PowerShell native)
function Get-BaseNames {
    param(
        [string[]]$ParsedVars
    )
    
    $baseNames = @()
    
    foreach ($line in $ParsedVars) {
        # Extract the variable name (everything before the first =)
        $varName = ($line -split '=', 2)[0]
        
        # Extract base name (remove suffixes)
        $baseName = $varName
        
        # Remove shell suffixes
        $baseName = $baseName -replace '_FISH$|_ZSH$|_BASH$|_PS$', ''
        
        # Remove platform suffixes
        $baseName = $baseName -replace '_WSL$|_LINUX$|_MACOS$|_WIN$|_UNIX$', ''
        
        # Add to list if not already present
        if ($baseNames -notcontains $baseName) {
            $baseNames += $baseName
        }
    }
    
    return $baseNames
}

# Get variable precedence score (PowerShell native)
function Get-VariablePrecedence {
    param(
        [string]$VarName
    )
    
    $shell = Get-Shell
    $platform = Get-Platform
    $score = 0
    
    # Shell-specific bonus
    if ($VarName -match "_$shell$") {
        $score += 1000
    }
    
    # Platform-specific bonus
    switch ($platform) {
        "WSL" {
            if ($VarName -match "_WSL$") { $score += 100 }
            elseif ($VarName -match "_LINUX$") { $score += 50 }
            elseif ($VarName -match "_UNIX$") { $score += 10 }
        }
        "LINUX" {
            if ($VarName -match "_LINUX$") { $score += 100 }
            elseif ($VarName -match "_UNIX$") { $score += 10 }
        }
        "MACOS" {
            if ($VarName -match "_MACOS$") { $score += 100 }
            elseif ($VarName -match "_UNIX$") { $score += 10 }
        }
        "WIN" {
            if ($VarName -match "_WIN$") { $score += 100 }
        }
    }
    
    return $score
}

# Resolve variable precedence (PowerShell native)
function Resolve-VariablePrecedence {
    param(
        [string]$BaseName,
        [string[]]$Candidates
    )
    
    $bestValue = ""
    $bestScore = -1

    foreach ($candidate in $Candidates) {
        # Extract variable name and value
        $parts = $candidate -split '=', 2
        $varName = $parts[0]
        $varValue = if ($parts.Length -gt 1) { $parts[1] } else { "" }

        # Get precedence score
        $score = Get-VariablePrecedence $varName

        if ($score -gt $bestScore) {
            $bestValue = $varValue
            $bestScore = $score
        }
    }
    
    return $bestValue
}

# Expand environment variables in a value (PowerShell native)
function Expand-EnvironmentVariables {
    param(
        [string]$Value
    )
    
    # PowerShell automatic variable expansion
    $expandedValue = $ExecutionContext.InvokeCommand.ExpandString($Value)
    
    # Additional expansions for common patterns
    $expandedValue = $expandedValue -replace '\$HOME', $env:HOME
    $expandedValue = $expandedValue -replace '\$USER', $env:USER
    $expandedValue = $expandedValue -replace '~', $env:HOME
    
    # Handle Windows-style variables
    $expandedValue = $expandedValue -replace '%HOME%', $env:HOME
    $expandedValue = $expandedValue -replace '%USER%', $env:USER
    $expandedValue = $expandedValue -replace '%USERNAME%', $env:USERNAME
    $expandedValue = $expandedValue -replace '%USERPROFILE%', $env:USERPROFILE
    $expandedValue = $expandedValue -replace '%APPDATA%', $env:APPDATA
    $expandedValue = $expandedValue -replace '%TEMP%', $env:TEMP
    
    # Simple command substitution for date
    if ($expandedValue -match '\$\(date \+%Y%m%d\)') {
        $dateStr = Get-Date -Format "yyyyMMdd"
        $expandedValue = $expandedValue -replace '\$\(date \+%Y%m%d\)', $dateStr
    }
    
    # PowerShell-style command substitution
    if ($expandedValue -match '\$\(Get-Date\)') {
        $dateStr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $expandedValue = $expandedValue -replace '\$\(Get-Date\)', $dateStr
    }
    
    return $expandedValue
}

# Set environment variable using PowerShell
function Set-EnvironmentVariable {
    param(
        [string]$Key,
        [string]$Value
    )
    
    # Validate key
    if ($Key -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') {
        Write-Warning "Invalid variable name: $Key"
        return $false
    }
    
    # Remove quotes if they wrap the entire value
    if (($Value.StartsWith('"') -and $Value.EndsWith('"')) -or 
        ($Value.StartsWith("'") -and $Value.EndsWith("'"))) {
        $Value = $Value.Substring(1, $Value.Length - 2)
    }
    
    # Set the environment variable
    Set-Item -Path "env:$Key" -Value $Value
    return $true
}

# Load environment variables from a single file (PowerShell native)
function Import-EnvFile {
    param(
        [string]$FilePath
    )
    
    if (-not (Test-Path $FilePath)) {
        return  # Silently skip missing files
    }
    
    if ($env:ENV_LOADER_DEBUG -eq "true") {
        Write-Host "Loading environment variables from: $FilePath" -ForegroundColor Yellow
    }
    
    # Parse the file
    $parsedVars = Parse-EnvFile $FilePath
    if ($parsedVars.Count -eq 0) {
        if ($env:ENV_LOADER_DEBUG -eq "true") {
            Write-Warning "No variables found in $FilePath"
        }
        return
    }
    
    # Extract unique base names
    $baseNames = Get-BaseNames $parsedVars
    
    # Process each base name
    foreach ($baseName in $baseNames) {
        if ([string]::IsNullOrWhiteSpace($baseName)) {
            continue
        }
        
        # Find all candidates for this base name
        $candidates = @()
        foreach ($line in $parsedVars) {
            $varName = ($line -split '=', 2)[0]
            if ($varName -eq $baseName -or $varName -match "^$baseName" + "_") {
                $candidates += $line
            }
        }
        
        # Resolve precedence and get the best value
        if ($candidates.Count -gt 0) {
            $bestValue = Resolve-VariablePrecedence $baseName $candidates
            
            if (-not [string]::IsNullOrWhiteSpace($bestValue)) {
                # Expand environment variables if needed
                if ($bestValue -match '\$' -or $bestValue -match '%.*%' -or $bestValue -match '~') {
                    $bestValue = Expand-EnvironmentVariables $bestValue
                }
                
                # Set the variable
                $success = Set-EnvironmentVariable $baseName $bestValue
                
                # Debug output
                if ($env:ENV_LOADER_DEBUG -eq "true" -and $success) {
                    Write-Host "  Set $baseName=$bestValue" -ForegroundColor Green
                }
            }
        }
    }
}

# Main load function
function Load-EnvFile {
    param(
        [string]$FilePath
    )
    Import-EnvFile $FilePath
}

# Test function
function Test-PowerShellLoader {
    Write-Host "Testing PowerShell loader..." -ForegroundColor Cyan
    $env:ENV_LOADER_DEBUG = "true"
    
    # Test basic loading
    Remove-Item -Path "env:TEST_BASIC" -ErrorAction SilentlyContinue
    Remove-Item -Path "env:EDITOR" -ErrorAction SilentlyContinue
    Import-EnvFile ".env.example"
    
    Write-Host "Results:" -ForegroundColor Cyan
    Write-Host "  EDITOR: [$env:EDITOR]" -ForegroundColor White
    Write-Host "  TEST_BASIC: [$env:TEST_BASIC]" -ForegroundColor White
}

# If script is run directly, execute test
if ($MyInvocation.InvocationName -ne '.') {
    # Script is being executed directly, not sourced
    # You can add direct execution logic here if needed
}
