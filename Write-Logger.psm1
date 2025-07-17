# 日志记录模块
# 设置输出编码为UTF-8，避免中文乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'UTF8'

# 全局变量 - 日志目录和文件路径
$script:LogDirectory = "$HOME\dotfiles\logs"
$script:MainLogFile = "$script:LogDirectory\dotfiles-installation.log"
$script:AppInstallLogFile = "$script:LogDirectory\app-installation.log"
$script:SymlinkLogFile = "$script:LogDirectory\symbolicLink-configuration.log"
$script:ContextLogFile = "$script:LogDirectory\context-installation.log"
$script:PackageLogFile = "$script:LogDirectory\package-installation.log"
$script:ScoopLogFile = "$script:LogDirectory\scoop-configuration.log"

function Initialize-LogDirectory {
    <#
    .SYNOPSIS
    初始化日志目录和文件
    
    .DESCRIPTION
    此函数会：
    1. 创建日志目录（如果不存在）
    2. 初始化主日志文件
    3. 记录新会话开始时间
    
    .EXAMPLE
    Initialize-LogDirectory
    
    .OUTPUTS
    [void] 无返回值
    #>
    
    # 创建日志目录
    if (-not (Test-Path $script:LogDirectory)) {
        New-Item -ItemType Directory -Path $script:LogDirectory -Force | Out-Null
    }
    
    # 清空主日志文件，创建新的会话
    $sessionStart = "=== NEW SESSION STARTED: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ==="
    Set-Content -Path $script:MainLogFile -Value $sessionStart -Encoding UTF8
}

# 根据 log 类型获取对应的日志文件路径
function Get-LogFilePath {
    <#
    .SYNOPSIS
    根据日志类型获取对应的日志文件路径
    
    .DESCRIPTION
    此函数会根据指定的日志类型返回相应的日志文件路径
    
    .PARAMETER LogType
    日志类型，支持 Main, AppInstall, Symlink, Context, Package, Scoop
    
    .EXAMPLE
    Get-LogFilePath -LogType "AppInstall"
    
    .OUTPUTS
    [string] 返回对应的日志文件路径
    #>
    
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

# 写入日志的主函数
function Write-Log {
    <#
    .SYNOPSIS
    写入日志消息到文件和控制台
    
    .DESCRIPTION
    此函数会：
    1. 将消息写入指定类型的日志文件
    2. 在控制台显示格式化的消息（除非指定静默模式）
    3. 根据级别使用不同的emoji和颜色
    
    .PARAMETER Message
    要记录的日志消息
    
    .PARAMETER Level
    日志级别：Info, Warning, Error, Success
    
    .PARAMETER LogType
    日志类型：Main, AppInstall, Symlink, Context, Package, Scoop
    
    .PARAMETER Silent
    静默模式开关，仅写入文件不在控制台显示
    
    .EXAMPLE
    Write-Log -Message "操作完成" -Level "Success" -LogType "AppInstall"
    
    .OUTPUTS
    [void] 无返回值
    #>
    
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
    Add-Content -Path $logFile -Value $logMessage -Encoding UTF8
    
    # 同时写入主日志文件（除非已经是主日志）
    if ($LogType -ne "Main") {
        Add-Content -Path $script:MainLogFile -Value "[$LogType] $logMessage" -Encoding UTF8
    }
    
    # 只在非静默模式下显示控制台输出，且只显示重要信息
    if (-not $Silent) {
        switch ($Level) {
            "Warning" { Write-Host "⚠️  $Message" -ForegroundColor Yellow }
            "Error"   { Write-Host "❌ $Message" -ForegroundColor Red }
            "Success" { Write-Host "✅ $Message" -ForegroundColor Green }
            "Info"    { Write-Host "🗒️  $Message" -ForegroundColor Cyan }
        }
    }
}

# 写入章节标题的函数
function Write-SectionHeader {
    <#
    .SYNOPSIS
    显示章节标题
    
    .DESCRIPTION
    此函数会：
    1. 在控制台显示格式化的章节标题
    2. 将章节标记写入日志文件
    
    .PARAMETER Title
    章节标题文本
    
    .EXAMPLE
    Write-SectionHeader -Title "应用程序安装"
    
    .OUTPUTS
    [void] 无返回值
    #>
    
    param (
        [string]$Title
    )
    
    Write-Host ""
    Write-Host "🔭 $Title" -ForegroundColor Magenta
    Write-Log -Message "=== $Title ===" -Level "Info" -Silent
}

# 写入章节结果的函数
function Write-SectionResult {
    <#
    .SYNOPSIS
    显示章节执行结果
    
    .DESCRIPTION
    此函数会：
    1. 根据成功/失败状态显示相应的消息
    2. 可选择性显示详细日志文件路径
    3. 支持自定义成功和失败消息
    
    .PARAMETER SectionName
    章节名称
    
    .PARAMETER Success
    执行是否成功的布尔值
    
    .PARAMETER DetailsLogFile
    详细日志文件路径（可选）
    
    .PARAMETER SuccessMessage
    自定义成功消息（可选）
    
    .PARAMETER FailureMessage
    自定义失败消息（可选）
    
    .EXAMPLE
    Write-SectionResult -SectionName "应用安装" -Success $true -SuccessMessage "所有应用安装成功"
    
    .OUTPUTS
    [void] 无返回值
    #>
    
    param (
        [string]$SectionName,
        [bool]$Success,
        [string]$DetailsLogFile = "",
        [string]$SuccessMessage = "",
        [string]$FailureMessage = ""
    )
    
    if ($Success) {
        $message = if ($SuccessMessage) { $SuccessMessage } else { "$SectionName completed successfully" }
        Write-Log -Message $message -Level "Success"
    } else {
        $message = if ($FailureMessage) { $FailureMessage } else { "$SectionName completed with issues" }
        Write-Log -Message $message -Level "Warning"
        if ($DetailsLogFile) {
            Write-Host "⚠️  Check details in: $DetailsLogFile" -ForegroundColor Gray
        }
    }
}

# 检查命令是否存在的辅助函数
function Test-CommandAvailability {
    <#
    .SYNOPSIS
    检查指定命令是否在系统中可用
    
    .DESCRIPTION
    此函数会检查指定的命令是否在当前系统中可用
    
    .PARAMETER Command
    要检查的命令名称
    
    .EXAMPLE
    Test-CommandAvailability -Command "git"
    
    .OUTPUTS
    [bool] 返回命令是否可用的布尔值
    #>
    
    param (
        [string]$Command
    )
    
    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    return [bool]$cmd
}


# 重定向输出到日志的辅助函数
function Invoke-WithLogging {
    <#
    .SYNOPSIS
    执行命令并将输出重定向到日志文件
    
    .DESCRIPTION
    此函数会：
    1. 执行指定的命令
    2. 将命令输出重定向到指定类型的日志文件
    3. 返回执行结果和输出内容
    4. 提供错误处理和日志记录
    
    .PARAMETER Command
    要执行的命令字符串
    
    .PARAMETER LogType
    日志类型，决定输出到哪个日志文件
    
    .PARAMETER Description
    命令描述，用于日志记录（可选）
    
    .EXAMPLE
    Invoke-WithLogging -Command "scoop install git" -LogType "Scoop" -Description "安装Git"
    
    .OUTPUTS
    [PSCustomObject] 返回包含Success和Output属性的对象
    #>
    
    param (
        [string]$Command,
        [ValidateSet("Main", "AppInstall", "Symlink", "Context", "Package", "Scoop")]
        [string]$LogType,
        [string]$Description = ""
    )
    
    $logFile = Get-LogFilePath -LogType $LogType
    
    if ($Description) {
        Write-Log -Message $Description -LogType $LogType -Level "Info" -Silent
    }
    
    try {
        # 记录正在执行的命令
        Write-Log -Message "Executing: $Command" -LogType $LogType -Level "Info" -Silent
        
        # 执行命令并捕获所有输出流，自动抑制控制台输出
        $ErrorActionPreference = 'Stop'
        $output = Invoke-Expression $Command *>&1 | Out-String
        
        # 写入输出到日志文件
        Add-Content -Path $logFile -Value $output -Encoding UTF8
        
        # 检查退出码（适用于外部命令）和异常（适用于内置命令）
        if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
            Write-Log -Message "Command failed with exit code ${LASTEXITCODE}: $Command" -LogType $LogType -Level "Error" -Silent
            return @{ Success = $false; Output = $output; ExitCode = $LASTEXITCODE }
        } else {
            Write-Log -Message "Command completed successfully: $Command" -LogType $LogType -Level "Info" -Silent
            return @{ Success = $true; Output = $output; ExitCode = 0 }
        }
    }
    catch {
        # 捕获命令不存在或内置命令失败的异常
        Write-Log -Message "Command failed: $Command. Error: $($_.Exception.Message)" -LogType $LogType -Level "Error" -Silent
        
        # 如果有输出，写入日志
        if ($output) {
            Add-Content -Path $logFile -Value $output -Encoding UTF8
        }
        
        return @{ Success = $false; Output = $output; ExitCode = -1 }
    }
}

Export-ModuleMember -Function "Write-Log", "Write-SectionHeader", "Write-SectionResult", "Test-CommandAvailability", "Initialize-LogDirectory", "Get-LogFilePath", "Invoke-WithLogging"