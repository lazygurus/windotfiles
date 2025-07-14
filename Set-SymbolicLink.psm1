# 软链接配置模块
Import-Module "$PSScriptRoot\Logger.psm1"

function Set-SymbolicLink {
    param (
        [string[]]$Targets,  # dotfiles
        [string[]]$Paths     # SymbolicLink
    )

    # dotfiles 和 symboliclink 数量是否相同
    if ($Targets.Length -ne $Paths.Length) {
        $errorMsg = "The length of targets ($($Targets.Length)) is not equal to paths ($($Paths.Length))"
        Write-Log -Message $errorMsg -LogType "Symlink" -Level "Error"
        return
    }

    $successCount = 0
    $failureCount = 0

    # 依次设置软链接
    for ($i = 0; $i -lt $Targets.Length; $i++) {
        $Target = $Targets[$i]
        $Path = $Paths[$i]

        Write-Progress -Activity "Creating Symbolic Links" -Status "Processing ($($i + 1)/$($Targets.Length))" -PercentComplete ((($i + 1) / $Targets.Length) * 100)
        
        try {
            # 删除已有软链接或者配置文件
            if (Test-Path $Path) {
                Write-Log -Message "Removing existing: $Path" -LogType "Symlink" -Level "Info" -Silent
                Remove-Item $Path -Recurse -Force
            }

            # 检查并创建父目录
            $ParentPath = Split-Path -Path $Path -Parent
            if (-not (Test-Path $ParentPath)) {
                Write-Log -Message "Creating directory: $ParentPath" -LogType "Symlink" -Level "Info" -Silent
                $result = Invoke-WithLogging -Command "New-Item -ItemType Directory -Path `"$ParentPath`" -Force" -LogType "Symlink" -Description ""
            }

            # 检查目标文件是否存在
            if (-not (Test-Path $Target)) {
                Write-Log -Message "Target does not exist: $Target - Check details in: symbolicLink-configuration.log" -LogType "Symlink" -Level "Error"
                $failureCount++
                continue
            }

            # 创建新的软链接
            Write-Log -Message "Creating symbolic link: $(Split-Path -Path $Target -Leaf)" -LogType "Symlink" -Level "Info"
            $result = Invoke-WithLogging -Command "New-Item -ItemType SymbolicLink -Path `"$Path`" -Target `"$Target`"" -LogType "Symlink" -Description ""
            
            if ($result) {
                # 获取文件名用于显示
                $fileName = Split-Path -Path $Target -Leaf
                Write-Log -Message "$fileName symbolic link created successfully" -LogType "Symlink" -Level "Success"
                $successCount++
            } else {
                $fileName = Split-Path -Path $Target -Leaf
                Write-Log -Message "$fileName symbolic link creation failed - Check details in: symbolicLink-configuration.log" -LogType "Symlink" -Level "Error"
                $failureCount++
            }
        }
        catch {
            Write-Log -Message "ERROR creating symbolic link for $Path: $($_.Exception.Message) - Check details in: symbolicLink-configuration.log" -LogType "Symlink" -Level "Error"
            $failureCount++
        }
    }
    
    Write-Progress -Activity "Creating Symbolic Links" -Completed
    Write-Log -Message "Symbolic link configuration completed: $successCount successful, $failureCount failed" -LogType "Symlink" -Level "Info" -Silent
    
    if ($failureCount -gt 0) {
        Write-Log -Message "Some symbolic link operations failed. Check symbolicLink-configuration.log for details." -LogType "Symlink" -Level "Error" -Silent
        return $false
    }
    return $true
}

Export-ModuleMember -Function "Set-SymbolicLink"
