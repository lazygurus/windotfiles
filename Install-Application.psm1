# 应用安装模块
Import-Module "$PSScriptRoot\Logger.psm1"

function Install-Application {
    param (
        [string[]]$AppList  # 应用名称数组
    )
    
    # 获取当前已安装的应用名
    try {
        $installedApps = & scoop export 2>> (Get-LogFilePath -LogType "AppInstall") |
                           ConvertFrom-Json |
                           Select-Object -ExpandProperty apps |
                           Select-Object -ExpandProperty Name
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

    foreach ($app in $AppList) {
        $currentApp++
        Write-Progress -Activity "Installing Applications" -Status "Processing $app ($currentApp/$totalApps)" -PercentComplete (($currentApp / $totalApps) * 100)
        
        if ($installedApps -contains $app) {
            Write-Log -Message "$app already installed" -LogType "AppInstall" -Level "Success"
            $successCount++
            continue
        } 
        else {
            Write-Log -Message "Installing $app..." -LogType "AppInstall" -Level "Info" -Silent
            try {
                $result = Invoke-WithLogging -Command "scoop install $app" -LogType "AppInstall" -Description ""
                
                if ($result) {
                    # 重新检查是否安装成功
                    $logFile = Get-LogFilePath -LogType "AppInstall"
                    $updatedApps = & scoop export 2>> $logFile |
                                   ConvertFrom-Json |
                                   Select-Object -ExpandProperty apps |
                                   Select-Object -ExpandProperty Name
                    
                    if ($updatedApps -contains $app) {
                        Write-Log -Message "$app successfully installed" -LogType "AppInstall" -Level "Success"
                        $successCount++
                    } 
                    else {
                        Write-Log -Message "$app installation failed (not found in installed apps)" -LogType "AppInstall" -Level "Error"
                        $failureCount++
                    }
                } else {
                    Write-Log -Message "$app installation failed" -LogType "AppInstall" -Level "Error"
                    $failureCount++
                }
            }
            catch {
                Write-Log -Message "$app installation error: $($_.Exception.Message)" -LogType "AppInstall" -Level "Error"
                $failureCount++
            }
        }
    }
    
    Write-Progress -Activity "Installing Applications" -Completed
    Write-Log -Message "Application installation completed: $successCount successful, $failureCount failed" -LogType "AppInstall" -Level "Success"
    
    if ($failureCount -gt 0) {
        Write-Log -Message "Some application installations failed. Check logs for details." -LogType "AppInstall" -Level "Warning"
    }
}

Export-ModuleMember -Function "Install-Application"
