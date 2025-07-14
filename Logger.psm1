# 日志记录模块

# 全局变量 - 日志目录和文件路径
$script:LogDirectory = "$HOME\dotfiles\logs"
$script:MainLogFile = "$script:LogDirectory\dotfiles-installation.log"
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
    
    # 清空主日志文件，创建新的会话
    $sessionStart = "=== NEW SESSION STARTED: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ==="
    Set-Content -Path $script:MainLogFile -Value $sessionStart
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
            "Info"    { Write-Host "ℹ️ $Message" -ForegroundColor Cyan }
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
        # 记录正在执行的命令
        Write-Log -Message "Executing: $Command" -LogType $LogType -Level "Info" -Silent
        
        # 解析命令
        if ($Command -match '^(\S+)(.*)$') {
            $executable = $matches[1]
            $arguments = $matches[2].Trim()
            
            # 检查是否是外部可执行文件（非 PowerShell 内置命令）
            $externalCommand = Get-Command $executable -CommandType Application -ErrorAction SilentlyContinue
            $isBuiltinOrFunction = Get-Command $executable -CommandType Cmdlet,Function,Alias -ErrorAction SilentlyContinue
            
            # 特殊处理：scoop 是 PowerShell 脚本，需要通过 PowerShell 调用
            if ($executable -eq 'scoop') {
                $scoopCommand = Get-Command scoop -ErrorAction SilentlyContinue
                if ($scoopCommand -and $scoopCommand.Source -like "*.ps1") {
                    # Scoop 是 PowerShell 脚本，使用 PowerShell 调用
                    $fullCommand = "powershell -NoProfile -Command `"& '$($scoopCommand.Source)' $arguments`""
                    $process = Start-Process -FilePath "powershell" -ArgumentList "-NoProfile", "-Command", "& '$($scoopCommand.Source)' $arguments" -Wait -PassThru -NoNewWindow -RedirectStandardOutput "$logFile.out" -RedirectStandardError "$logFile.err"
                } else {
                    # 回退到普通处理
                    $ErrorActionPreference = 'Stop'
                    $output = Invoke-Expression $Command 2>&1
                    $output | Out-String | Add-Content -Path $logFile
                    
                    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
                        Write-Log -Message "Command completed successfully: $Command" -LogType $LogType -Level "Info" -Silent
                        return $true
                    } else {
                        Write-Log -Message "Command failed with exit code ${LASTEXITCODE}: $Command" -LogType $LogType -Level "Error"
                        return $false
                    }
                }
            }
            # 对于真正的外部可执行文件（如 git.exe, ping.exe 等）
            elseif ($externalCommand -and -not $isBuiltinOrFunction) {
                $process = Start-Process -FilePath $executable -ArgumentList $arguments -Wait -PassThru -NoNewWindow -RedirectStandardOutput "$logFile.out" -RedirectStandardError "$logFile.err"
            }
            # 对于 PowerShell 内置命令、函数等
            else {
                $ErrorActionPreference = 'Stop'
                try {
                    $output = Invoke-Expression $Command 2>&1
                    $output | Out-String | Add-Content -Path $logFile
                    
                    # 检查是否有 PowerShell 子进程的退出码
                    if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
                        Write-Log -Message "Command failed with exit code ${LASTEXITCODE}: $Command" -LogType $LogType -Level "Error"
                        return $false
                    }
                    
                    Write-Log -Message "Command completed successfully: $Command" -LogType $LogType -Level "Info" -Silent
                    return $true
                } catch {
                    Write-Log -Message "Command failed: $Command. Error: $($_.Exception.Message)" -LogType $LogType -Level "Error"
                    return $false
                }
            }
            
            # 处理 Start-Process 的结果（适用于 scoop 和外部命令）
            if ($process) {
                # 将输出追加到日志文件
                if (Test-Path "$logFile.out") {
                    Get-Content "$logFile.out" | Add-Content -Path $logFile
                    Remove-Item "$logFile.out" -ErrorAction SilentlyContinue
                }
                if (Test-Path "$logFile.err") {
                    Get-Content "$logFile.err" | Add-Content -Path $logFile
                    Remove-Item "$logFile.err" -ErrorAction SilentlyContinue
                }
                
                if ($process.ExitCode -eq 0) {
                    Write-Log -Message "Command completed successfully: $Command" -LogType $LogType -Level "Info" -Silent
                    return $true
                } else {
                    Write-Log -Message "Command failed with exit code $($process.ExitCode): $Command" -LogType $LogType -Level "Error"
                    return $false
                }
            }
        } else {
            # 无法解析命令，回退到原来的方法
            $ErrorActionPreference = 'Stop'
            $output = Invoke-Expression $Command 2>&1
            $output | Out-String | Add-Content -Path $logFile
            
            if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
                Write-Log -Message "Command completed successfully: $Command" -LogType $LogType -Level "Info" -Silent
                return $true
            } else {
                Write-Log -Message "Command failed with exit code ${LASTEXITCODE}: $Command" -LogType $LogType -Level "Error"
                return $false
            }
        }
    }
    catch {
        Write-Log -Message "Command failed: $Command. Error: $($_.Exception.Message)" -LogType $LogType -Level "Error"
        return $false
    }
}

Export-ModuleMember -Function "Write-Log", "Write-SectionHeader", "Test-CommandExists", "Initialize-LogDirectory", "Get-LogFilePath", "Invoke-WithLogging"
