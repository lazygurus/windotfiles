# 上下文菜单安装模块
Import-Module (Join-Path $PSScriptRoot "Write-Logger.psm1")

function Install-ContextMenus {
    <#
    .SYNOPSIS
    安装应用程序的上下文菜单
    
    .DESCRIPTION
    此函数会：
    1. 安装指定应用程序的右键上下文菜单
    2. 支持文件关联的应用程序会额外安装文件关联
    3. 提供进度显示和详细的安装状态报告
    4. 处理注册表导入和错误处理
    
    .PARAMETER ScoopAppsPath
    Scoop 应用程序安装路径，默认为 "D:\scoop\apps"
    
    .EXAMPLE
    Install-ContextMenus -ScoopAppsPath "D:\scoop\apps"
    
    .OUTPUTS
    [bool] 返回上下文菜单安装的整体成功状态
    #>
    
    param (
        [string]$ScoopAppsPath = "D:\scoop\apps"
    )

    $contextApps = @(
        @{ Name = "windows-terminal"; Description = "Windows Terminal"; HasFileAssociation = $false },
        @{ Name = "git"; Description = "Git"; HasFileAssociation = $true },
        @{ Name = "vscode"; Description = "VS Code"; HasFileAssociation = $false },
        @{ Name = "neovide"; Description = "Neovide"; HasFileAssociation = $false }
    )

    $successCount = 0
    $failureCount = 0
    $totalApps = $contextApps.Count

    for ($i = 0; $i -lt $contextApps.Count; $i++) {
        $app = $contextApps[$i]
        Write-Progress -Activity "Installing Context Menus" -Status "Processing $($app.Description) ($($i + 1)/$totalApps)" -PercentComplete ((($i + 1) / $totalApps) * 100)
        
        try {
            $contextPath = "$ScoopAppsPath\$($app.Name)\current\install-context.reg"
            
            if (Test-Path $contextPath) {
                Write-Log -Message "Installing $($app.Description) context menu..." -LogType "Context" -Level "Info"
                $result = Invoke-WithLogging -Command "reg import `"$contextPath`"" -LogType "Context" -Description ""
                
                if ($result.Success) {
                    Write-Log -Message "$($app.Description) context menu installed successfully" -LogType "Context" -Level "Success"
                    $successCount++
                } else {
                    Write-Log -Message "$($app.Description) context menu installation failed" -LogType "Context" -Level "Error"
                    $failureCount++
                }
            } else {
                Write-Log -Message "Context file not found for $($app.Description)" -LogType "Context" -Level "Warning"
                $failureCount++
            }

            # 安装文件关联（如果有的话）
            if ($app.HasFileAssociation) {
                $assocPath = "$ScoopAppsPath\$($app.Name)\current\install-file-associations.reg"
                if (Test-Path $assocPath) {
                    Write-Log -Message "Installing $($app.Description) file associations..." -LogType "Context" -Level "Info"
                    $result = Invoke-WithLogging -Command "reg import `"$assocPath`"" -LogType "Context" -Description ""
                    
                    if ($result.Success) {
                        Write-Log -Message "$($app.Description) file associations installed successfully" -LogType "Context" -Level "Success"
                    } else {
                        Write-Log -Message "$($app.Description) file associations installation failed" -LogType "Context" -Level "Error"
                    }
                } else {
                    Write-Log -Message "$($app.Description) file associations file not found" -LogType "Context" -Level "Warning"
                }
            }
        }
        catch {
            Write-Log -Message "Error installing context menu for $($app.Description): $($_.Exception.Message)" -LogType "Context" -Level "Error"
            $failureCount++
        }
    }

    Write-Progress -Activity "Installing Context Menus" -Completed
    Write-Log -Message "Context menu installation completed: $successCount successful, $failureCount failed" -LogType "Context" -Level "Info" -Silent
    
    if ($failureCount -gt 0) {
        Write-Log -Message "Some context menu installations failed. Check context-installation.log for details." -LogType "Context" -Level "Error" -Silent
        return $false
    }
    return $true
}

Export-ModuleMember -Function "Install-ContextMenus"