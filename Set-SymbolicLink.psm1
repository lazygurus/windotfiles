# 符号链接配置模块
Import-Module (Join-Path $PSScriptRoot "Write-Logger.psm1")

function Set-SymbolicLink {
    <#
    .SYNOPSIS
    创建符号链接配置
    
    .DESCRIPTION
    此函数会：
    1. 批量创建从 dotfiles 到系统配置目录的符号链接
    2. 检查源文件和目标路径的对应关系
    3. 提供进度显示和详细日志记录
    4. 处理已存在文件的覆盖逻辑
    5. 返回整体操作的成功状态
    
    .PARAMETER Targets
    源文件路径数组（dotfiles中的文件）
    
    .PARAMETER Paths
    目标符号链接路径数组
    
    .EXAMPLE
    Set-SymbolicLink -Targets @("C:\dotfiles\git\.gitconfig") -Paths @("C:\Users\Username\.gitconfig")
    
    .OUTPUTS
    [bool] 返回符号链接创建的整体成功状态
    #>
    
    param (
        [string[]]$Targets,  # 源文件路径数组（dotfiles中的文件）
        [string[]]$Paths     # 目标符号链接路径数组
    )

    # 检查源文件和目标路径数组长度是否相等
    if ($Targets.Length -ne $Paths.Length) {
        $errorMsg = "Source file count ($($Targets.Length)) does not match target path count ($($Paths.Length))"
        Write-Log -Message $errorMsg -LogType "Symlink" -Level "Error"
        return $false
    }

    $successCount = 0
    $failureCount = 0

    # 逐个创建符号链接
    for ($i = 0; $i -lt $Targets.Length; $i++) {
        $Target = $Targets[$i]
        $Path = $Paths[$i]

        Write-Progress -Activity "Configuring symbolic links" -Status "Processing ($($i + 1)/$($Targets.Length))" -PercentComplete ((($i + 1) / $Targets.Length) * 100)
        
        try {
            # 删除已存在的符号链接或配置文件
            if (Test-Path $Path) {
                $removeResult = Invoke-WithLogging -Command "Remove-Item '$Path' -Recurse -Force" -LogType "Symlink" -Description ""
                if (-not $removeResult.Success) {
                    Write-Log -Message "Cannot remove existing file: $Path" -LogType "Symlink" -Level "Error"
                    $failureCount++
                    continue
                }
            }

            # 检查并创建父目录
            $ParentPath = Split-Path -Path $Path -Parent
            if (-not (Test-Path $ParentPath)) {
                $createDirResult = Invoke-WithLogging -Command "New-Item -ItemType Directory -Path '$ParentPath' -Force" -LogType "Symlink" -Description ""
                if (-not $createDirResult.Success) {
                    Write-Log -Message "Failed to create parent directory: $ParentPath" -LogType "Symlink" -Level "Error"
                    $failureCount++
                    continue
                }
            }

            # 检查源文件是否存在
            if (-not (Test-Path $Target)) {
                Write-Log -Message "Source file does not exist: $Target" -LogType "Symlink" -Level "Error"
                $failureCount++
                continue
            }

            # 创建新的符号链接
            $fileName = Split-Path -Path $Target -Leaf
            Write-Log -Message "Configuring $fileName..." -LogType "Symlink" -Level "Info"
            
            # 使用 Invoke-WithLogging 执行符号链接创建命令
            $command = "New-Item -ItemType SymbolicLink -Path '$Path' -Target '$Target' -Force"
            $result = Invoke-WithLogging -Command $command -LogType "Symlink" -Description ""
            
            if ($result.Success) {
                Write-Log -Message "$fileName configured successfully" -LogType "Symlink" -Level "Success"
                $successCount++
            } else {
                Write-Log -Message "$fileName configuration failed" -LogType "Symlink" -Level "Error"
                $failureCount++
            }
        }
        catch {
            Write-Log -Message "Error creating symbolic link $Path - $($_.Exception.Message)" -LogType "Symlink" -Level "Error"
            $failureCount++
        }
    }
    
    Write-Progress -Activity "Configuring symbolic links" -Completed
    Write-Log -Message "Symbolic link configuration completed - Success: $successCount, Failed: $failureCount" -LogType "Symlink" -Level "Info" -Silent
    
    if ($failureCount -gt 0) {
        Write-Log -Message "Some symbolic link operations failed, check symbolicLink-configuration.log for details" -LogType "Symlink" -Level "Error" -Silent
        return $false
    }
    return $true
}

Export-ModuleMember -Function "Set-SymbolicLink"
