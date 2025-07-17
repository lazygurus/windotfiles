# Install-Packages.psm1
# 应用包安装和配置模块

# 导入依赖模块
Import-Module (Join-Path $PSScriptRoot "Write-Logger.psm1")

function Install-ApplicationPackages {
    <#
    .SYNOPSIS
    安装应用程序包和主题
    
    .DESCRIPTION
    此函数会：
    1. 安装 Yazi 文件管理器的主题包
    2. 支持扩展更多应用包的安装
    
    .PARAMETER PackageList
    要安装的包列表，可以是自定义对象数组，包含应用名称和包名称
    
    .EXAMPLE
    $packages = @(
        @{App = "yazi"; Package = "yazi-rs/flavors:catppuccin-mocha"; Command = "ya"}
    )
    Install-ApplicationPackages -PackageList $packages
    
    .OUTPUTS
    [bool] 返回包安装的整体成功状态
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [array]$PackageList = @(
            @{
                App = "yazi"
                Package = "yazi-rs/flavors:catppuccin-mocha"
                Command = "ya"
                PackageName = "catppuccin-mocha"
                Description = "Yazi catppuccin-mocha theme package"
            }
        )
    )
    
    $overallSuccess = $true
    
    foreach ($pkg in $PackageList) {
        $appName = $pkg.App
        $packageName = $pkg.Package
        $command = $pkg.Command
        $checkName = $pkg.PackageName
        $description = $pkg.Description
        
        if (Test-CommandAvailability $command) {
            Write-Log -Message "Checking $description..." -LogType "Package" -Level "Info"
            
            # 先检查是否已经安装
            $listResult = Invoke-WithLogging -Command "$command pkg list" -LogType "Package" -Description ""
            if ($listResult.Success -and $listResult.Output -match $checkName) {
                Write-Log -Message "$description already installed" -LogType "Package" -Level "Success"
            } else {
                # 如果没有安装，则进行安装
                Write-Log -Message "Installing $description..." -LogType "Package" -Level "Info"
                $result = Invoke-WithLogging -Command "$command pkg add $packageName" -LogType "Package" -Description ""
                if (-not $result.Success) {
                    # 检查是否是因为包已经存在
                    if ($result.Output -match "already exists") {
                        Write-Log -Message "$description already installed" -LogType "Package" -Level "Success"
                    } else {
                        Write-Log -Message "Failed to install $description" -LogType "Package" -Level "Error"
                        $overallSuccess = $false
                    }
                } else {
                    Write-Log -Message "$description installed successfully" -LogType "Package" -Level "Success"
                }
            }
        } else {
            Write-Log -Message "$appName ($command command) not found, skipping $description installation" -LogType "Package" -Level "Warning"
            # 不是失败，只是跳过
        }
    }
    
    return $overallSuccess
}

function Install-YaziTheme {
    <#
    .SYNOPSIS
    安装 Yazi 主题包的专用函数
    
    .DESCRIPTION
    专门用于安装 Yazi 文件管理器的 catppuccin-mocha 主题包
    
    .EXAMPLE
    Install-YaziTheme
    
    .OUTPUTS
    [bool] 返回安装成功状态
    #>
    
    [CmdletBinding()]
    param()
    
    $yaziPackage = @{
        App = "yazi"
        Package = "yazi-rs/flavors:catppuccin-mocha"
        Command = "ya"
        PackageName = "catppuccin-mocha"
        Description = "Yazi catppuccin-mocha theme package"
    }
    
    return Install-ApplicationPackages -PackageList @($yaziPackage)
}

# 导出函数
Export-ModuleMember -Function Install-ApplicationPackages, Install-YaziTheme
