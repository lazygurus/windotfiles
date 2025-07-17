# 应用安装模块
Import-Module (Join-Path $PSScriptRoot "Write-Logger.psm1")

# 根据退出码获取安装失败的详细原因
function Get-InstallFailureReason {
    <#
    .SYNOPSIS
    根据退出码获取安装失败的详细原因
    
    .DESCRIPTION
    此函数会：
    1. 根据应用安装的退出码
    2. 提供对应的错误原因描述
    3. 基于 Scoop 和 Aria2 的退出码映射
    
    .PARAMETER AppName
    应用程序名称
    
    .PARAMETER ExitCode
    安装过程的退出码
    
    .EXAMPLE
    Get-InstallFailureReason -AppName "git" -ExitCode 3
    
    .OUTPUTS
    [string] 返回失败原因的详细描述
    #>
    
    param (
        [string]$AppName,
        [int]$ExitCode
    )
    
    # 基于 Scoop 和 Aria2 的退出码映射
    $exitCodeMap = @{
        0   = "Success (should not be treated as failure)"
        1   = "General error or unknown error occurred"
        2   = "Timeout during download or installation"
        3   = "Resource not found (404 error, missing manifest, or broken URL)"
        4   = "Too many 'resource not found' errors"
        5   = "Download speed too slow (below minimum threshold)"
        6   = "Network problem occurred during download"
        7   = "Download was interrupted (Ctrl-C or signal)"
        8   = "Resume not supported by remote server"
        9   = "Insufficient disk space available"
        10  = "Piece length mismatch in aria2 control file"
        11  = "Aria2 was already downloading the same file"
        12  = "Aria2 was already downloading the same torrent"
        13  = "File already exists and overwrite not allowed"
        14  = "File renaming failed"
        15  = "Could not open existing file"
        16  = "Could not create new file or truncate existing file"
        17  = "File I/O error occurred"
        18  = "Could not create directory"
        19  = "DNS resolution failed"
        20  = "Could not parse Metalink document"
        21  = "FTP command failed"
        22  = "HTTP response header was malformed"
        23  = "Too many HTTP redirects"
        24  = "HTTP authorization failed (invalid credentials)"
        25  = "Could not parse bencoded file (torrent corrupted)"
        26  = "Torrent file was corrupted or missing required information"
        27  = "Magnet URI was malformed"
        28  = "Bad or unrecognized command line option"
        29  = "Remote server temporarily overloaded or under maintenance"
        30  = "Could not parse JSON-RPC request"
        32  = "Checksum validation failed (hash mismatch)"
        3010 = "Manifest not found or invalid"
        3011 = "Architecture not supported"
        3012 = "Dependency resolution failed"
        3013 = "Installation script failed"
        3014 = "Permission denied (requires admin privileges)"
        3015 = "Application already running (cannot update/install)"
    }
    
    $reason = $exitCodeMap[$ExitCode]
    if (-not $reason) {
        $reason = "Unknown error (exit code: $ExitCode)"
    }
    
    return "Exit Code $ExitCode - $reason"
}

function Install-Application {
    <#
    .SYNOPSIS
    通过 Scoop 安装应用程序列表
    
    .DESCRIPTION
    此函数会：
    1. 检查当前已安装的应用程序
    2. 清理 Scoop 缓存
    3. 批量安装指定的应用程序列表
    4. 提供详细的安装进度和状态报告
    5. 处理安装失败和重试逻辑
    
    .PARAMETER AppList
    要安装的应用程序名称数组
    
    .EXAMPLE
    Install-Application -AppList @("git", "nodejs", "python")
    
    .OUTPUTS
    [bool] 返回安装过程的整体成功状态
    #>
    
    param (
        [string[]]$AppList  # 应用名称数组
    )
    
    # 获取当前已成功安装的应用名（排除安装失败的应用）
    try {
        # 使用 scoop list 获取应用信息，包括安装状态
        $scoopListOutput = & scoop list | Out-String
        
        # 解析输出，排除包含 "Install failed" 的应用
        $installedApps = @()
        if ($scoopListOutput) {
            # 按行分割并处理每一行
            $scoopListOutput -split "`n" | ForEach-Object {
                $line = $_.Trim()
                # 匹配应用行（不是标题行或分隔符或空行）
                if ($line -match '^([^\s]+)\s+' -and $line -notmatch '^Name\s+' -and $line -notmatch '^-+\s+' -and $line -ne '') {
                    $appName = $matches[1]
                    # 检查是否包含 "Install failed" 标记
                    if ($line -notmatch 'Install failed') {
                        $installedApps += $appName
                    } else {
                        Write-Log -Message "Detected failed installation for $appName, will retry if requested" -LogType "AppInstall" -Level "Info" -Silent
                    }
                }
            }
        }
        
        Write-Log -Message "Found $($installedApps.Count) successfully installed apps" -LogType "AppInstall" -Level "Info" -Silent
    }
    catch {
        Write-Log -Message "Warning: Cannot get installed apps list, continuing anyway..." -LogType "AppInstall" -Level "Warning"
        Write-Log -Message "Failed to get installed apps: $($_.Exception.Message)" -LogType "AppInstall" -Level "Error" -Silent
        $installedApps = @()
    }

    $totalApps = $AppList.Count
    $currentApp = 0
    $successCount = 0
    $failureCount = 0

    # 清理 scoop 所有应用缓存，避免识别到未成功安装的应用
    $result = Invoke-WithLogging -Command "scoop cache rm *" -LogType "AppInstall" -Description ""
    if (-not $result.Success) {
        Write-Log -Message "Failed to clean scoop cache" -LogType "AppInstall" -Level "Error"
        return $false
    } else {
        Write-Log -Message "Scoop cache cleaned successfully" -LogType "AppInstall" -Level "Success"
    }

    # 安装列表中没有安装的应用
    foreach ($app in $AppList) {
        $currentApp++
        Write-Progress -Activity "Installing Applications" -Status "Processing $app ($currentApp/$totalApps)" -PercentComplete (($currentApp / $totalApps) * 100)
        
        if ($installedApps -contains $app) {
            Write-Log -Message "$app is already installed" -LogType "AppInstall" -Level "Success"
            $successCount++
            continue
        } 
        else {
            Write-Log -Message "Installing $app..." -LogType "AppInstall" -Level "Info"
            
            # 重试机制：最多尝试3次安装
            $maxRetries = 3
            $retryCount = 0
            $installSuccessful = $false
            
            while ($retryCount -lt $maxRetries -and -not $installSuccessful) {
                $retryCount++
                
                if ($retryCount -gt 1) {
                    Write-Log -Message "Retrying $app installation (attempt $retryCount/$maxRetries)..." -LogType "AppInstall" -Level "Info"
                }
                
                try {
                    $result = Invoke-WithLogging -Command "scoop install $app" -LogType "AppInstall" -Description ""
                    
                    if ($result.Success) {
                        # 重新检查是否安装成功（排除安装失败的应用）
                        try {
                            $scoopListOutput = & scoop list | Out-String
                            $isInstalledSuccessfully = $false
                            
                            if ($scoopListOutput) {
                                # 按行分割并检查当前应用
                                $scoopListOutput -split "`n" | ForEach-Object {
                                    $line = $_.Trim()
                                    # 匹配当前应用且不包含 "Install failed"
                                    if ($line -match "^$app\s+" -and $line -notmatch 'Install failed') {
                                        $isInstalledSuccessfully = $true
                                    }
                                }
                            }
                            
                            if ($isInstalledSuccessfully) {
                                Write-Log -Message "$app installed successfully on attempt $retryCount" -LogType "AppInstall" -Level "Success"
                                $successCount++
                                $installSuccessful = $true
                            } else {
                                # 获取详细的失败原因
                                $failureReason = Get-InstallFailureReason $app $LASTEXITCODE
                                Write-Log -Message "${app} installation attempt $retryCount failed: $failureReason" -LogType "AppInstall" -Level "Error"
                                
                                if ($retryCount -lt $maxRetries) {
                                    Write-Log -Message "Will retry $app installation..." -LogType "AppInstall" -Level "Info"
                                    # 清理失败的安装残留
                                    try {
                                        $cleanupResult = Invoke-WithLogging -Command "scoop uninstall $app" -LogType "AppInstall" -Description ""
                                        if ($cleanupResult.Success) {
                                            Write-Log -Message "Cleaned up failed installation of $app" -LogType "AppInstall" -Level "Info" -Silent
                                        }
                                    } catch {
                                        Write-Log -Message "Failed to cleanup $app, continuing..." -LogType "AppInstall" -Level "Warning" -Silent
                                    }
                                }
                            }
                        } catch {
                            $failureReason = "Verification failed: $($_.Exception.Message)"
                            Write-Log -Message "$app installation verification failed on attempt ${retryCount}: $failureReason" -LogType "AppInstall" -Level "Error"
                        }
                    } else {
                        # 检查是否是因为应用已经安装
                        if ($result.Output -match "already installed") {
                            Write-Log -Message "$app already installed" -LogType "AppInstall" -Level "Success"
                            $successCount++
                            $installSuccessful = $true
                        } else {
                            # 命令执行失败，获取详细原因
                            $failureReason = Get-InstallFailureReason $app $result.ExitCode
                            Write-Log -Message "$app installation command failed on attempt ${retryCount}: $failureReason" -LogType "AppInstall" -Level "Error"
                        }
                    }
                }
                catch {
                    $failureReason = "Exception occurred: $($_.Exception.Message)"
                    Write-Log -Message "$app installation error on attempt ${retryCount}: $failureReason" -LogType "AppInstall" -Level "Error"
                }
            }
            
            # 如果所有重试都失败了
            if (-not $installSuccessful) {
                Write-Log -Message "$app installation failed after $maxRetries attempts. Skipping this application." -LogType "AppInstall" -Level "Error"
                $failureCount++
            }
        }
    }
    
    Write-Progress -Activity "Installing Applications" -Completed
    Write-Log -Message "Application installation completed: $successCount successful, $failureCount failed" -LogType "AppInstall" -Level "Info" -Silent
    
    if ($failureCount -gt 0) {
        Write-Log -Message "Some application installations failed. Check app-installation.log for details." -LogType "AppInstall" -Level "Error" -Silent
        return $false
    }
    return $true
}

Export-ModuleMember -Function "Install-Application", "Get-InstallFailureReason"
