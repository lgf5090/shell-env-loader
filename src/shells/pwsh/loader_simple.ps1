# Simple PowerShell Environment Variable Loader
# ==============================================
# Simplified PowerShell implementation for cross-shell environment loading

# Platform detection
function Get-Platform {
    if ($IsWindows -or ($env:OS -eq "Windows_NT")) {
        return "WIN"
    } elseif ($IsLinux) {
        if (Test-Path "/proc/version") {
            try {
                $version = Get-Content "/proc/version" -ErrorAction SilentlyContinue
                if ($version -match "Microsoft") {
                    return "WSL"
                }
            } catch {
                # Ignore errors
            }
        }
        return "LINUX"
    } elseif ($IsMacOS) {
        return "MACOS"
    } else {
        return "UNIX"
    }
}

# Shell detection
function Get-Shell {
    return "POWERSHELL"
}

# Parse environment file
function Parse-EnvFile {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        return @()
    }
    
    $variables = @()
    try {
        $content = Get-Content $FilePath -ErrorAction Stop
        foreach ($line in $content) {
            $line = $line.Trim()
            if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
                $variables += $line
            }
        }
    } catch {
        Write-Warning "Failed to read $FilePath"
    }
    
    return $variables
}

# Get base names from variables
function Get-BaseNames {
    param([string[]]$Variables)
    
    $baseNames = @()
    foreach ($var in $Variables) {
        $name = ($var -split '=')[0]
        $baseName = $name -replace '_POWERSHELL$|_PS$|_FISH$|_ZSH$|_BASH$', ''
        $baseName = $baseName -replace '_WSL$|_LINUX$|_MACOS$|_WIN$|_UNIX$', ''
        
        if ($baseNames -notcontains $baseName) {
            $baseNames += $baseName
        }
    }
    return $baseNames
}

# Get variable precedence score
function Get-Precedence {
    param([string]$VarName)
    
    $score = 0
    $platform = Get-Platform
    
    # Shell-specific bonus
    if ($VarName -match "_POWERSHELL$|_PS$") {
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

# Resolve best variable
function Get-BestValue {
    param([string]$BaseName, [string[]]$Candidates)
    
    $bestValue = ""
    $bestScore = -1
    
    foreach ($candidate in $Candidates) {
        $parts = $candidate -split '=', 2
        $varName = $parts[0]
        $varValue = if ($parts.Length -gt 1) { $parts[1] } else { "" }
        
        $score = Get-Precedence $varName
        if ($score -gt $bestScore) {
            $bestValue = $varValue
            $bestScore = $score
        }
    }
    
    return $bestValue
}

# Expand variables
function Expand-Variables {
    param([string]$Value)
    
    # Remove surrounding quotes
    if (($Value.StartsWith('"') -and $Value.EndsWith('"')) -or 
        ($Value.StartsWith("'") -and $Value.EndsWith("'"))) {
        $Value = $Value.Substring(1, $Value.Length - 2)
    }
    
    # Basic variable expansion
    $Value = $Value -replace '\$HOME', $env:HOME
    $Value = $Value -replace '\$USER', $env:USER
    $Value = $Value -replace '~', $env:HOME
    $Value = $Value -replace '%HOME%', $env:HOME
    $Value = $Value -replace '%USER%', $env:USER
    $Value = $Value -replace '%USERNAME%', $env:USERNAME
    $Value = $Value -replace '%USERPROFILE%', $env:USERPROFILE
    
    # Date expansion
    if ($Value -match '\$\(date \+%Y%m%d\)') {
        $dateStr = Get-Date -Format "yyyyMMdd"
        $Value = $Value -replace '\$\(date \+%Y%m%d\)', $dateStr
    }
    
    return $Value
}

# Main function to load environment file
function Import-EnvFile {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        return
    }
    
    if ($env:ENV_LOADER_DEBUG -eq "true") {
        Write-Host "Loading environment variables from: $FilePath" -ForegroundColor Yellow
    }
    
    $variables = Parse-EnvFile $FilePath
    if ($variables.Count -eq 0) {
        return
    }
    
    $baseNames = Get-BaseNames $variables
    
    foreach ($baseName in $baseNames) {
        if (-not $baseName) { continue }
        
        # Find candidates
        $candidates = @()
        foreach ($var in $variables) {
            $varName = ($var -split '=')[0]
            if ($varName -eq $baseName -or $varName.StartsWith("$baseName" + "_")) {
                $candidates += $var
            }
        }
        
        if ($candidates.Count -gt 0) {
            $bestValue = Get-BestValue $baseName $candidates
            if ($bestValue) {
                $expandedValue = Expand-Variables $bestValue
                Set-Item -Path "env:$baseName" -Value $expandedValue
                
                if ($env:ENV_LOADER_DEBUG -eq "true") {
                    Write-Host "  Set $baseName=$expandedValue" -ForegroundColor Green
                }
            }
        }
    }
}

# Test function
function Test-Loader {
    Write-Host "Testing PowerShell loader..." -ForegroundColor Cyan
    $env:ENV_LOADER_DEBUG = "true"
    
    # Clear test variables
    if (Test-Path "env:EDITOR") { Remove-Item "env:EDITOR" }
    if (Test-Path "env:TEST_BASIC") { Remove-Item "env:TEST_BASIC" }
    
    Write-Host "Before loading:" -ForegroundColor White
    Write-Host "  EDITOR: [$env:EDITOR]" -ForegroundColor White
    Write-Host "  TEST_BASIC: [$env:TEST_BASIC]" -ForegroundColor White
    
    Import-EnvFile ".env.example"
    
    Write-Host "After loading:" -ForegroundColor White
    Write-Host "  EDITOR: [$env:EDITOR]" -ForegroundColor White
    Write-Host "  TEST_BASIC: [$env:TEST_BASIC]" -ForegroundColor White
    Write-Host "  Platform: $(Get-Platform)" -ForegroundColor White
    Write-Host "  Shell: $(Get-Shell)" -ForegroundColor White
}

# If script is executed directly, run test
if ($MyInvocation.InvocationName -ne '.') {
    Test-Loader
}
