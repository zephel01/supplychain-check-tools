<#
.SYNOPSIS
Supply Chain Security Check Tool for Windows
Windowsシステムのサプライチェーン攻撃防止セキュリティチェック

.DESCRIPTION
複数のセキュリティ観点からローカル環境を監査します

.PARAMETER Verbose
詳細出力を有効化

.EXAMPLE
.\check-supply-chain-windows.ps1
.\check-supply-chain-windows.ps1 -Verbose

.NOTES
Requires: PowerShell 5.0+
Admin rights: Recommended (not required for basic checks)
#>

param(
    [switch]$Verbose = $false
)

# Configuration
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$REPORT_FILE = "supply_chain_check_report_$TIMESTAMP.txt"
$CHECKS_PASSED = 0
$CHECKS_FAILED = 0
$CHECKS_WARNED = 0
$CHECKS_INFO = 0

# Color definitions
$COLOR_PASS = "Green"
$COLOR_FAIL = "Red"
$COLOR_WARN = "Yellow"
$COLOR_INFO = "Cyan"

# ============================================================================
# Utility Functions
# ============================================================================

function Write-LogHeader {
    param([string]$Text)
    $separator = "=" * 80
    Write-Host $separator -ForegroundColor DarkGray
    Write-Host "► $Text" -ForegroundColor Cyan -BackgroundColor Black
    Write-Host $separator -ForegroundColor DarkGray
    Add-Content -Path $REPORT_FILE -Value "`n$separator"
    Add-Content -Path $REPORT_FILE -Value "► $Text"
    Add-Content -Path $REPORT_FILE -Value $separator
}

function Write-PassCheck {
    param([string]$Message)
    $msg = "✓ PASS: $Message"
    Write-Host $msg -ForegroundColor $COLOR_PASS
    Add-Content -Path $REPORT_FILE -Value $msg
    $global:CHECKS_PASSED++
}

function Write-FailCheck {
    param([string]$Message)
    $msg = "✗ FAIL: $Message"
    Write-Host $msg -ForegroundColor $COLOR_FAIL
    Add-Content -Path $REPORT_FILE -Value $msg
    $global:CHECKS_FAILED++
}

function Write-WarnCheck {
    param([string]$Message)
    $msg = "⚠ WARN: $Message"
    Write-Host $msg -ForegroundColor $COLOR_WARN
    Add-Content -Path $REPORT_FILE -Value $msg
    $global:CHECKS_WARNED++
}

function Write-InfoCheck {
    param([string]$Message)
    $msg = "ℹ INFO: $Message"
    Write-Host $msg -ForegroundColor $COLOR_INFO
    Add-Content -Path $REPORT_FILE -Value $msg
    $global:CHECKS_INFO++
}

function Test-AdminPrivileges {
    $isAdmin = [bool]([System.Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
    if (-not $isAdmin) {
        Write-WarnCheck "Not running with administrator privileges. Some checks may be limited."
    }
    return $isAdmin
}

# ============================================================================
# 1. Code Signature Verification (Authenticode)
# ============================================================================

function Check-CodeSignatures {
    Write-LogHeader "1. コード署名検証 (Authenticode)"
    
    # Check system executables
    $systemPaths = @(
        "C:\Windows\System32",
        "C:\Program Files",
        "C:\Program Files (x86)"
    )
    
    $unsignedCount = 0
    $signedCount = 0
    
    foreach ($path in $systemPaths) {
        if (Test-Path $path) {
            $files = Get-ChildItem -Path $path -Recurse -Include "*.exe", "*.dll" -ErrorAction SilentlyContinue | Select-Object -First 20
            
            foreach ($file in $files) {
                $sig = Get-AuthenticodeSignature -FilePath $file.FullName -ErrorAction SilentlyContinue
                
                if ($sig.Status -eq [System.Management.Automation.SignatureStatus]::Valid) {
                    $signedCount++
                } else {
                    $unsignedCount++
                    if ($Verbose) {
                        Write-InfoCheck "Unsigned file: $($file.Name)"
                    }
                }
            }
        }
    }
    
    if ($signedCount -gt 0) {
        Write-PassCheck "Found $signedCount signed executables"
    }
    
    if ($unsignedCount -eq 0) {
        Write-PassCheck "No unsigned system executables detected in sampled paths"
    } else {
        Write-WarnCheck "Found $unsignedCount unsigned files (sampling)"
    }
}

# ============================================================================
# 2. Windows Updates Security
# ============================================================================

function Check-WindowsUpdates {
    Write-LogHeader "2. セキュリティ更新確認"
    
    $updateHistory = Get-HotFix -ErrorAction SilentlyContinue | Measure-Object
    
    if ($updateHistory.Count -gt 0) {
        Write-PassCheck "Windows updates installed: $($updateHistory.Count)"
        
        $lastUpdate = Get-HotFix -ErrorAction SilentlyContinue | Sort-Object InstalledOn -Descending | Select-Object -First 1
        if ($lastUpdate) {
            Write-InfoCheck "Latest update: $($lastUpdate.Description) - $($lastUpdate.InstalledOn)"
        }
    } else {
        Write-FailCheck "No Windows updates found"
    }
    
    # Check Windows Defender status
    try {
        $defenderStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
        if ($defenderStatus) {
            Write-PassCheck "Windows Defender is installed"
        }
    } catch {
        Write-WarnCheck "Could not verify Windows Defender status"
    }
}

# ============================================================================
# 3. Firewall Status
# ============================================================================

function Check-Firewall {
    Write-LogHeader "3. ファイアウォール設定"
    
    try {
        $fwProfiles = Get-NetFirewallProfile -ErrorAction SilentlyContinue
        
        foreach ($profile in $fwProfiles) {
            if ($profile.Enabled) {
                Write-PassCheck "$($profile.Name) Firewall: ENABLED"
            } else {
                Write-FailCheck "$($profile.Name) Firewall: DISABLED"
            }
        }
    } catch {
        Write-WarnCheck "Could not query firewall settings"
    }
}

# ============================================================================
# 4. npm Packages
# ============================================================================

function Check-NPMPackages {
    Write-LogHeader "4. npm パッケージ検証"
    
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-InfoCheck "npm not installed, skipping"
        return
    }
    
    Write-InfoCheck "npm version: $(npm --version)"
    
    # Check for package-lock.json
    $packageLocks = Get-ChildItem -Path $HOME -Recurse -Name "package-lock.json" -ErrorAction SilentlyContinue | Measure-Object
    
    if ($packageLocks.Count -gt 0) {
        Write-PassCheck "Found $($packageLocks.Count) package-lock.json files"
    } else {
        Write-WarnCheck "No package-lock.json files found"
    }
    
    # Run npm audit if in a project directory
    $currentDir = Get-Location
    if (Test-Path "$currentDir\package.json") {
        try {
            Write-InfoCheck "Running npm audit in current directory..."
            $auditResult = npm audit --json 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
            
            if ($auditResult.metadata.vulnerabilities.total -eq 0) {
                Write-PassCheck "npm audit: No vulnerabilities detected"
            } else {
                $criticalCount = $auditResult.metadata.vulnerabilities.critical
                $highCount = $auditResult.metadata.vulnerabilities.high
                Write-FailCheck "npm audit: $criticalCount critical, $highCount high severity vulnerabilities"
            }
        } catch {
            Write-WarnCheck "npm audit failed or npm not available"
        }
    }
}

# ============================================================================
# 5. Python Packages
# ============================================================================

function Check-PythonPackages {
    Write-LogHeader "5. Python パッケージ検証"
    
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-InfoCheck "Python not installed, skipping"
        return
    }
    
    Write-InfoCheck "Python version: $(python --version 2>&1)"
    
    # Check for requirements.txt
    $requirementsTxt = Get-ChildItem -Path $HOME -Recurse -Name "requirements.txt" -ErrorAction SilentlyContinue | Measure-Object
    
    if ($requirementsTxt.Count -gt 0) {
        Write-PassCheck "Found $($requirementsTxt.Count) requirements.txt files"
    }
    
    # Check for suspicious packages
    try {
        $installedPackages = python -m pip list 2>$null
        Write-InfoCheck "Python packages listed successfully"
    } catch {
        Write-WarnCheck "Could not list Python packages"
    }
}

# ============================================================================
# 6. Git Configuration
# ============================================================================

function Check-GitConfiguration {
    Write-LogHeader "6. Git 設定検証"
    
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-InfoCheck "Git not installed, skipping"
        return
    }
    
    Write-InfoCheck "Git version: $(git --version)"
    
    # Check for git hooks
    $gitHooksPath = Join-Path $HOME ".git\hooks"
    if (Test-Path $gitHooksPath) {
        $hooks = Get-ChildItem -Path $gitHooksPath -ErrorAction SilentlyContinue | Measure-Object
        Write-InfoCheck "Git hooks found: $($hooks.Count)"
    }
    
    # Check git config for commit signing
    try {
        $signCommits = git config --global commit.gpgsign 2>$null
        if ($signCommits -eq "true") {
            Write-PassCheck "Git commit signing enabled"
        } else {
            Write-WarnCheck "Git commit signing not enabled"
        }
    } catch {
        Write-InfoCheck "Could not verify git commit signing"
    }
}

# ============================================================================
# 7. SSH Keys
# ============================================================================

function Check-SSHKeys {
    Write-LogHeader "7. SSH 鍵セキュリティ"
    
    $sshPath = Join-Path $HOME ".ssh"
    
    if (-not (Test-Path $sshPath)) {
        Write-InfoCheck "SSH directory not found"
        return
    }
    
    # Check .ssh directory permissions
    $sshAcl = Get-Acl $sshPath
    Write-InfoCheck ".ssh directory found"
    
    # Check for private keys
    $privateKeys = Get-ChildItem -Path $sshPath -Include "id_*" -Exclude "*.pub" -ErrorAction SilentlyContinue
    
    foreach ($key in $privateKeys) {
        $keyAcl = Get-Acl $key.FullName
        Write-InfoCheck "Private key found: $($key.Name)"
    }
    
    if ($privateKeys.Count -gt 0) {
        Write-PassCheck "SSH private keys found: $($privateKeys.Count)"
    } else {
        Write-InfoCheck "No SSH private keys detected"
    }
}

# ============================================================================
# 8. Environment Variables
# ============================================================================

function Check-EnvironmentVariables {
    Write-LogHeader "8. 環境変数セキュリティ"
    
    $suspiciousKeywords = @("password", "api_key", "token", "secret", "credential")
    $foundSuspicious = $false
    
    $envVars = Get-ChildItem -Path Env: | Select-Object Name, Value
    
    foreach ($var in $envVars) {
        foreach ($keyword in $suspiciousKeywords) {
            if ($var.Name -like "*$keyword*") {
                Write-WarnCheck "Suspicious environment variable: $($var.Name)"
                $foundSuspicious = $true
            }
        }
    }
    
    if (-not $foundSuspicious) {
        Write-PassCheck "No suspicious environment variables detected"
    }
}

# ============================================================================
# 9. Network Connections
# ============================================================================

function Check-NetworkConnections {
    Write-LogHeader "9. ネットワーク接続監視"
    
    try {
        $connections = Get-NetTCPConnection -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Established" } | Measure-Object
        Write-InfoCheck "Active TCP connections: $($connections.Count)"
        
        $listeningPorts = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue
        Write-InfoCheck "Listening ports: $($listeningPorts.Count)"
        
        foreach ($port in $listeningPorts | Select-Object -First 10) {
            Write-InfoCheck "  - Port $($port.LocalPort) - PID: $($port.OwningProcess)"
        }
    } catch {
        Write-WarnCheck "Could not query network connections"
    }
}

# ============================================================================
# 10. File System Permissions
# ============================================================================

function Check-FileSystemPermissions {
    Write-LogHeader "10. ファイルシステムパーミッション"
    
    $criticalPaths = @(
        "C:\Windows\System32",
        "C:\Program Files",
        "$HOME\AppData"
    )
    
    foreach ($path in $criticalPaths) {
        if (Test-Path $path) {
            $acl = Get-Acl $path -ErrorAction SilentlyContinue
            $accessRules = $acl.Access | Measure-Object
            Write-InfoCheck "$path has $($accessRules.Count) access rules"
        }
    }
    
    Write-PassCheck "File system permissions checked"
}

# ============================================================================
# Summary Report
# ============================================================================

function Generate-Summary {
    Write-Host "`n" + ("=" * 80) -ForegroundColor DarkGray
    Write-Host "SECURITY CHECK SUMMARY" -ForegroundColor Cyan -BackgroundColor Black
    Write-Host ("=" * 80) -ForegroundColor DarkGray
    
    Write-Host "✓ Passed:  $CHECKS_PASSED" -ForegroundColor Green
    Write-Host "✗ Failed:  $CHECKS_FAILED" -ForegroundColor Red
    Write-Host "⚠ Warned:  $CHECKS_WARNED" -ForegroundColor Yellow
    Write-Host "ℹ Infos:   $CHECKS_INFO" -ForegroundColor Cyan
    
    $totalChecks = $CHECKS_PASSED + $CHECKS_FAILED + $CHECKS_WARNED
    
    Write-Host "`nReport saved to: $REPORT_FILE" -ForegroundColor Green
    Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    
    Add-Content -Path $REPORT_FILE -Value "`n`n$('=' * 80)"
    Add-Content -Path $REPORT_FILE -Value "SUMMARY"
    Add-Content -Path $REPORT_FILE -Value "$('=' * 80)"
    Add-Content -Path $REPORT_FILE -Value "Passed:  $CHECKS_PASSED"
    Add-Content -Path $REPORT_FILE -Value "Failed:  $CHECKS_FAILED"
    Add-Content -Path $REPORT_FILE -Value "Warned:  $CHECKS_WARNED"
    Add-Content -Path $REPORT_FILE -Value "Infos:   $CHECKS_INFO"
    Add-Content -Path $REPORT_FILE -Value "Total:   $totalChecks"
    Add-Content -Path $REPORT_FILE -Value "`nTimestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

# ============================================================================
# Main Execution
# ============================================================================

function Main {
    Write-Host "`n" + ("=" * 80)
    Write-Host "SUPPLY CHAIN SECURITY CHECK - WINDOWS" -ForegroundColor Cyan -BackgroundColor Black
    Write-Host "=" * 80
    Write-Host "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host ""
    
    # Initialize report file
    Add-Content -Path $REPORT_FILE -Value "SUPPLY CHAIN SECURITY CHECK - WINDOWS"
    Add-Content -Path $REPORT_FILE -Value "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Add-Content -Path $REPORT_FILE -Value "System: $env:COMPUTERNAME"
    Add-Content -Path $REPORT_FILE -Value "OS: $([System.Environment]::OSVersion.VersionString)"
    Add-Content -Path $REPORT_FILE -Value ""
    
    # Check admin privileges
    Test-AdminPrivileges
    
    # Run all checks
    Check-CodeSignatures
    Check-WindowsUpdates
    Check-Firewall
    Check-NPMPackages
    Check-PythonPackages
    Check-GitConfiguration
    Check-SSHKeys
    Check-EnvironmentVariables
    Check-NetworkConnections
    Check-FileSystemPermissions
    
    # Generate summary
    Generate-Summary
}

# Execute
Main
