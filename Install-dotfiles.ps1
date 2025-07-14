# 优化的 dotfiles 安装脚本
# 顶级父目录
$dotfiles = "$HOME\dotfiles"
$config = "$HOME\.config"
$localAppData = "$HOME\AppData\Local"
$roamingAppData = "$HOME\AppData\Roaming"
$scoop = "D:\scoop"
$scoopApps = "$scoop\apps"

# 导入模块
Import-Module "$dotfiles\Logger.psm1"
Import-Module "$dotfiles\Install-Application.psm1"
Import-Module "$dotfiles\Set-SymbolicLink.psm1"
Import-Module "$dotfiles\Install-ContextMenus.psm1"
Import-Module "$dotfiles\App-and-Symlink.psm1"

# 初始化日志系统
Initialize-LogDirectory

Write-Host "🚀 Starting dotfiles installation..." -ForegroundColor Cyan

# 1. 安装和配置 Scoop
Write-SectionHeader -Title "Install And Configure Scoop"

if (-not (Test-CommandExists "scoop")) {
    Write-Log -Message "Scoop is not installed, installing now..." -LogType "Scoop" -Level "Info"

    try {
        Invoke-RestMethod get.scoop.sh -outfile 'install.ps1'
        $result = Invoke-WithLogging -Command ".\install.ps1 -ScoopDir $scoop -proxy '127.0.0.1:7890'" -LogType "Scoop" -Description "Installing Scoop"
        Remove-Item .\install.ps1

        if (Test-CommandExists "scoop") {
            Write-Log -Message "Scoop installation successful!" -LogType "Scoop" -Level "Success"
        } 
        else {
            Write-Log -Message "Scoop installation failed, please check your network or permission settings." -LogType "Scoop" -Level "Error"
            exit 1
        }
    }
    catch {
        Write-Log -Message "Scoop installation failed: $($_.Exception.Message)" -LogType "Scoop" -Level "Error"
        exit 1
    }
} 
else {
    Write-Log -Message "Scoop is already installed, skipping installation." -LogType "Scoop" -Level "Success"
}

# 配置 Scoop
Invoke-WithLogging -Command "scoop config proxy 127.0.0.1:7890" -LogType "Scoop" -Description ""
Write-Log -Message "Scoop proxy configured successfully" -LogType "Scoop" -Level "Success"

Invoke-WithLogging -Command "scoop install git" -LogType "Scoop" -Description ""
Write-Log -Message "Git installed successfully" -LogType "Scoop" -Level "Success"

Invoke-WithLogging -Command "scoop install git-credential-manager" -LogType "Scoop" -Description ""
Write-Log -Message "Git credential manager installed successfully" -LogType "Scoop" -Level "Success"

# 检查 git 配置文件是否存在
if (Test-Path "$dotfiles\git\.gitconfig") {
    Set-SymbolicLink -Targets @("$dotfiles\git\.gitconfig") -Paths @("$Home\.gitconfig")
} else {
    Write-Log -Message "Git config file not found at $dotfiles\git\.gitconfig" -LogType "Scoop" -Level "Warning"
}

Invoke-WithLogging -Command "scoop bucket add extras" -LogType "Scoop" -Description ""
Invoke-WithLogging -Command "scoop bucket add nerd-fonts" -LogType "Scoop" -Description ""
Write-Log -Message "Scoop buckets added successfully" -LogType "Scoop" -Level "Success"

Invoke-WithLogging -Command "scoop install aria2" -LogType "Scoop" -Description ""
Invoke-WithLogging -Command "scoop config aria2-enabled true" -LogType "Scoop" -Description ""
Invoke-WithLogging -Command "scoop config aria2-warning-enabled false" -LogType "Scoop" -Description ""
Write-Log -Message "Aria2 configured for faster downloads" -LogType "Scoop" -Level "Success"

Write-Log -Message "Scoop configuration complete." -LogType "Scoop" -Level "Success"

# 2. 通过 Scoop 安装应用
Write-SectionHeader -Title "Install Apps Via Scoop"
Install-Application -AppList $applist

# 3. 配置软链接
Write-SectionHeader -Title "Configure Symbolic Links"
Set-SymbolicLink -Targets $targets -Paths $paths 

# 4. 安装上下文菜单
Write-SectionHeader -Title "Install Context Menus"
Install-ContextMenus -ScoopAppsPath $scoopApps

# 5. 安装应用包
Write-SectionHeader -Title "Install Application Packages"

# Yazi 主题包
if (Test-CommandExists "ya") {
    Write-Log -Message "Installing yazi catppuccin-mocha theme package..." -LogType "Package" -Level "Info" -Silent
    $result = Invoke-WithLogging -Command "ya pkg add yazi-rs/flavors:catppuccin-mocha" -LogType "Package" -Description ""
    if ($result) {
        Write-Log -Message "Yazi theme package installation complete." -LogType "Package" -Level "Success"
    } else {
        Write-Log -Message "Failed to install Yazi theme package." -LogType "Package" -Level "Error"
    }
} else {
    Write-Log -Message "Yazi (ya command) not found, skipping theme installation." -LogType "Package" -Level "Warning"
}

# 6. 完成安装
Write-Host ""
Write-Host "🎉 Dotfiles installation completed!" -ForegroundColor Green
Write-Host "📋 Check the logs in $(Get-LogFilePath -LogType 'Main' | Split-Path) for detailed information." -ForegroundColor Gray
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Restart your terminal to apply changes" -ForegroundColor White
Write-Host "   2. Run 'starship init powershell' if starship is not working" -ForegroundColor White
Write-Host "   3. Check git configuration with 'git config --list'" -ForegroundColor White

Write-Log -Message "=== DOTFILES INSTALLATION COMPLETED ===" -Level "Success"
