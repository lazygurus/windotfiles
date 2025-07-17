# Install-Scoop.psm1
# Scoop 包管理器安装和配置模块

# 导入依赖模块
Import-Module (Join-Path $PSScriptRoot "Write-Logger.psm1")

function Install-ScoopManager {
    <#
    .SYNOPSIS
    安装和配置 Scoop 包管理器
    
    .DESCRIPTION
    此函数会：
    1. 安装 Scoop 包管理器（如果尚未安装）
    2. 配置代理设置
    3. 安装 Git
    4. 配置 Git 配置文件
    5. 添加必要的 buckets（extras, nerd-fonts）
    6. 安装和配置 Aria2 下载器
    
    .PARAMETER ScoopDirectory
    Scoop 安装目录，默认为 "D:\scoop"
    
    .PARAMETER ProxyUrl
    代理服务器 URL，默认为 "127.0.0.1:7890"
    
    .PARAMETER DotfilesPath
    dotfiles 目录路径，用于查找 Git 配置文件
    
    .EXAMPLE
    Install-ScoopManager -ScoopDirectory "D:\scoop" -ProxyUrl "127.0.0.1:7890" -DotfilesPath "$HOME\dotfiles"
    
    .OUTPUTS
    [bool] 返回安装和配置的整体成功状态
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ScoopDirectory = "D:\scoop",
        
        [Parameter(Mandatory = $false)]
        [string]$ProxyUrl = "127.0.0.1:7890",
        
        [Parameter(Mandatory = $false)]
        [string]$DotfilesPath = "$HOME\dotfiles"
    )
    
    # 安装 Scoop
    if (-not (Test-CommandAvailability "scoop")) {
        Write-Log -Message "Installing Scoop package manager..." -LogType "Scoop" -Level "Info"

        try {
            Invoke-RestMethod get.scoop.sh -outfile 'install.ps1'
            Invoke-WithLogging -Command ".\install.ps1 -ScoopDir $ScoopDirectory -proxy '$ProxyUrl'" -LogType "Scoop" -Description "Installing Scoop" | Out-Null
            Remove-Item .\install.ps1

            if (Test-CommandAvailability "scoop") {
                Write-Log -Message "Scoop installation completed successfully" -LogType "Scoop" -Level "Success"
            } 
            else {
                Write-Log -Message "Scoop installation failed - Check details in: scoop-configuration.log" -LogType "Scoop" -Level "Error"
                return $false
            }
        }
        catch {
            Write-Log -Message "Scoop installation failed: $($_.Exception.Message) - Check details in: scoop-configuration.log" -LogType "Scoop" -Level "Error"
            return $false
        }
    } 
    else {
        Write-Log -Message "Scoop is already installed" -LogType "Scoop" -Level "Success"
    }

    # 配置 scoop proxy
    Write-Log -Message "Configuring Scoop proxy" -LogType "Scoop" -Level "Info"
    $proxyResult = Invoke-WithLogging -Command "scoop config proxy $ProxyUrl" -LogType "Scoop" -Description ""
    if (-not $proxyResult.Success) {
        Write-Log -Message "Failed to configure Scoop proxy (this may affect download speeds)" -LogType "Scoop" -Level "Warning"
    } else {
        Write-Log -Message "Scoop proxy configured successfully" -LogType "Scoop" -Level "Success"
    }

    # scoop 安装 git
    Write-Log -Message "Installing Git" -LogType "Scoop" -Level "Info"
    $gitResult = Invoke-WithLogging -Command "scoop install git" -LogType "Scoop" -Description ""
    if (-not $gitResult.Success) {
        Write-Log -Message "Failed to install Git" -LogType "Scoop" -Level "Error"
        return $false
    } else {
        # 检查输出中是否包含 "already installed"
        if ($gitResult.Output -match "already installed") {
            Write-Log -Message "Git already installed" -LogType "Scoop" -Level "Success"
        } else {
            Write-Log -Message "Git installed successfully" -LogType "Scoop" -Level "Success"
        }
    }

    # 检查 git 配置文件是否存在
    if (Test-Path "$DotfilesPath\git\.gitconfig") {
        Write-Log -Message "Setting up Git configuration..." -LogType "Scoop" -Level "Info"
        try {
            # 使用统一的 Set-SymbolicLink 函数创建符号链接
            $linkResult = Set-SymbolicLink -Targets @("$DotfilesPath\git\.gitconfig") -Paths @("$Home\.gitconfig")
            if ($linkResult) {
                Write-Log -Message "Git configuration setup completed" -LogType "Scoop" -Level "Success"
            } else {
                Write-Log -Message "Failed to setup Git configuration" -LogType "Scoop" -Level "Warning"
            }
        }
        catch {
            Write-Log -Message "Failed to setup Git configuration: $($_.Exception.Message)" -LogType "Scoop" -Level "Warning"
        }
    } else {
        Write-Log -Message "Git config file not found" -LogType "Scoop" -Level "Warning"
    }

    # 添加 Scoop buckets（关键步骤，失败则退出）
    Write-Log -Message "Adding Scoop extras bucket..." -LogType "Scoop" -Level "Info"
    $extrasResult = Invoke-WithLogging -Command "scoop bucket add extras" -LogType "Scoop" -Description ""
    if (-not $extrasResult.Success) {
        # 检查是否是因为 bucket 已存在
        if ($extrasResult.Output -match "already exists") {
            Write-Log -Message "Extras bucket already installed" -LogType "Scoop" -Level "Success"
            $extrasResult.Success = $true
        } else {
            Write-Log -Message "Failed to add extras bucket" -LogType "Scoop" -Level "Error"
            return $false
        }
    } else {
        Write-Log -Message "Extras bucket added successfully" -LogType "Scoop" -Level "Success"
    }

    Write-Log -Message "Adding Scoop nerd-fonts bucket..." -LogType "Scoop" -Level "Info"
    $fontsResult = Invoke-WithLogging -Command "scoop bucket add nerd-fonts" -LogType "Scoop" -Description ""
    if (-not $fontsResult.Success) {
        # 检查是否是因为 bucket 已存在
        if ($fontsResult.Output -match "already exists") {
            Write-Log -Message "Nerd-fonts bucket already installed" -LogType "Scoop" -Level "Success"
            $fontsResult.Success = $true
        } else {
            Write-Log -Message "Failed to add nerd-fonts bucket" -LogType "Scoop" -Level "Error"
            return $false
        }
    } else {
        Write-Log -Message "Nerd-fonts bucket added successfully" -LogType "Scoop" -Level "Success"
    }

    Write-Log -Message "Installing and configuring Aria2..." -LogType "Scoop" -Level "Info"
    $aria2InstallResult = Invoke-WithLogging -Command "scoop install aria2" -LogType "Scoop" -Description ""
    Invoke-WithLogging -Command "scoop config aria2-enabled true" -LogType "Scoop" -Description "" | Out-Null
    Invoke-WithLogging -Command "scoop config aria2-warning-enabled false" -LogType "Scoop" -Description "" | Out-Null

    # 检查 Aria2 安装结果
    if ($aria2InstallResult.Output -match "already installed") {
        Write-Log -Message "Aria2 already installed" -LogType "Scoop" -Level "Success"
    } elseif ($aria2InstallResult.Success) {
        Write-Log -Message "Aria2 installed successfully" -LogType "Scoop" -Level "Success"
    } else {
        Write-Log -Message "Failed to install Aria2" -LogType "Scoop" -Level "Warning"
    }

    # 计算整体成功状态
    $overallSuccess = (Test-CommandAvailability "scoop")-and $proxyResult -and $aria2InstallResult.Success -and $extrasResult.Success -and $fontsResult.Success

    return $overallSuccess
}

# 导出函数
Export-ModuleMember -Function Install-ScoopManager
