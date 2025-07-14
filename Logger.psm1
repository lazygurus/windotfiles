# 日志记录模块

# 全局变量 - 日志目录和文件路径
$script:LogDirectory = "$HOME\dotfiles\logs"
$script:MainLogFile = "$script:LogDirectory\dotfiles-installation-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$script:AppInstallLogFile = "$script:LogDirectory\app-installation.log"
$script:SymlinkLogFile = "$script:LogDirectory\symbolicLink-configuration.log"
$script:ContextLogFile = "$script:LogDirectory\context-installation.log"
$script:PackageLogFile = "$script:LogDirectory\package-installation.log"
$script:ScoopLogFile = "$script:LogDirectory\scoop-configuration.log"

function Initialize-LogDirectory {
    # 创建日志目录
    if (-not (Test-Path $script:LogDirectory)) {
        New-Item -ItemType Directory -Path $script:LogDirectory -Force | Out-Null
    }
    
    # 创建会话开始标记
    $sessionStart = "=== NEW SESSION STARTED: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ==="
    Add-Content -Path $script:MainLogFile -Value $sessionStart
    
    Write-Host "📋 Logs will be saved to: $script:LogDirectory" -ForegroundColor Gray
}

function Get-LogFilePath {
    param (
        [ValidateSet("Main", "AppInstall", "Symlink", "Context", "Package", "Scoop")]
        [string]$LogType = "Main"
    )
    
    switch ($LogType) {
        "Main"       { return $script:MainLogFile }
        "AppInstall" { return $script:AppInstallLogFile }
        "Symlink"    { return $script:SymlinkLogFile }
        "Context"    { return $script:ContextLogFile }
        "Package"    { return $script:PackageLogFile }
        "Scoop"      { return $script:ScoopLogFile }
        default      { return $script:MainLogFile }
    }
}

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string]$Level = "Info",
        [ValidateSet("Main", "AppInstall", "Symlink", "Context", "Package", "Scoop")]
        [string]$LogType = "Main",
        [switch]$Silent  # 静默模式，只写入日志文件，不在控制台显示
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    $logFile = Get-LogFilePath -LogType $LogType
    
    # 写入对应的日志文件
    Add-Content -Path $logFile -Value $logMessage
    
    # 同时写入主日志文件（除非已经是主日志）
    if ($LogType -ne "Main") {
        Add-Content -Path $script:MainLogFile -Value "[$LogType] $logMessage"
    }
    
    # 只在非静默模式下显示控制台输出，且只显示重要信息
    if (-not $Silent) {
        switch ($Level) {
            "Warning" { Write-Host "⚠️ $Message" -ForegroundColor Yellow }
            "Error"   { Write-Host "❌ $Message" -ForegroundColor Red }
            "Success" { Write-Host "✅ $Message" -ForegroundColor Green }
            # Info 级别默认不显示在控制台，只记录到日志
        }
    }
}

function Write-SectionHeader {
    param (
        [string]$Title
    )
    
    Write-Host ""
    Write-Host "🔭 $Title" -ForegroundColor Magenta
    Write-Log -Message "=== $Title ===" -Level "Info" -Silent
}

function Test-CommandExists {
    param (
        [string]$Command
    )
    
    return Get-Command $Command -ErrorAction SilentlyContinue
}

# 重定向输出到日志的辅助函数
function Invoke-WithLogging {
    param (
        [string]$Command,
        [ValidateSet("AppInstall", "Symlink", "Context", "Package", "Scoop")]
        [string]$LogType,
        [string]$Description = ""
    )
    
    $logFile = Get-LogFilePath -LogType $LogType
    
    if ($Description) {
        Write-Log -Message $Description -LogType $LogType -Level "Info"
    }
    
    try {
        Invoke-Expression "$Command *>> `"$logFile`""
        return $true
    }
    catch {
        Write-Log -Message "Command failed: $Command. Error: $($_.Exception.Message)" -LogType $LogType -Level "Error"
        return $false
    }
}

Export-ModuleMember -Function "Write-Log", "Write-SectionHeader", "Test-CommandExists", "Initialize-LogDirectory", "Get-LogFilePath", "Invoke-WithLogging"
