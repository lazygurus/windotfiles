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

Write-Host "🚀 Starting dotfiles installation" -ForegroundColor Cyan

# 1. 安装和配置 Scoop
Write-Host "⚙️ Setting up Scoop..." -ForegroundColor Cyan

if (-not (Test-CommandExists "scoop")) {
    Write-Log -Message "Installing Scoop package manager..." -LogType "Scoop" -Level "Info"

    try {
        Invoke-RestMethod get.scoop.sh -outfile 'install.ps1'
        $result = Invoke-WithLogging -Command ".\install.ps1 -ScoopDir $scoop -proxy '127.0.0.1:7890'" -LogType "Scoop" -Description "Installing Scoop"
        Remove-Item .\install.ps1

        if (Test-CommandExists "scoop") {
            Write-Log -Message "Scoop installation completed successfully" -LogType "Scoop" -Level "Success"
        } 
        else {
            Write-Log -Message "Scoop installation failed - Check details in: scoop-configuration.log" -LogType "Scoop" -Level "Error"
            exit 1
        }
    }
    catch {
        Write-Log -Message "Scoop installation failed: $($_.Exception.Message) - Check details in: scoop-configuration.log" -LogType "Scoop" -Level "Error"
        exit 1
    }
} 
else {
    Write-Log -Message "Scoop is already installed" -LogType "Scoop" -Level "Success"
}

# 配置 Scoop（关键配置步骤）
Write-Log -Message "Configuring Scoop proxy..." -LogType "Scoop" -Level "Info"

$proxyResult = Invoke-WithLogging -Command "scoop config proxy 127.0.0.1:7890" -LogType "Scoop" -Description ""
if (-not $proxyResult) {
    Write-Log -Message "Failed to configure Scoop proxy (this may affect download speeds) - Check details in: scoop-configuration.log" -LogType "Scoop" -Level "Warning"
} else {
    Write-Log -Message "Scoop proxy configured successfully" -LogType "Scoop" -Level "Success"
}

# scoop 安装 git
Write-Log -Message "Installing Git via Scoop..." -LogType "Scoop" -Level "Info"
$gitResult = Invoke-WithLogging -Command "scoop install git" -LogType "Scoop" -Description ""
if (-not $gitResult) {
    Write-Log -Message "Failed to install Git - Check details in: scoop-configuration.log" -LogType "Scoop" -Level "Error"
    exit 1
} else {
    Write-Log -Message "Git installed successfully" -LogType "Scoop" -Level "Success"
}

# 检查 git 配置文件是否存在
if (Test-Path "$dotfiles\git\.gitconfig") {
    Write-Log -Message "Setting up Git configuration..." -LogType "Scoop" -Level "Info"
    Set-SymbolicLink -Targets @("$dotfiles\git\.gitconfig") -Paths @("$Home\.gitconfig")
    Write-Log -Message "Git configuration setup completed" -LogType "Scoop" -Level "Success"
} else {
    Write-Log -Message "Git config file not found at $dotfiles\git\.gitconfig" -LogType "Scoop" -Level "Warning"
}

# 添加 Scoop buckets（关键步骤，失败则退出）
Write-Log -Message "Adding Scoop extras bucket..." -LogType "Scoop" -Level "Info"
$extrasResult = Invoke-WithLogging -Command "scoop bucket add extras" -LogType "Scoop" -Description ""
if (-not $extrasResult) {
    # 检查是否是因为 bucket 已存在
    $bucketList = & scoop bucket list 2>&1
    if ($bucketList -match "extras") {
        Write-Log -Message "Extras bucket already exists" -LogType "Scoop" -Level "Success"
        $extrasResult = $true
    } else {
        Write-Log -Message "Failed to add extras bucket - Check details in: scoop-configuration.log" -LogType "Scoop" -Level "Error"
        exit 1
    }
} else {
    Write-Log -Message "Extras bucket added successfully" -LogType "Scoop" -Level "Success"
}

Write-Log -Message "Adding Scoop nerd-fonts bucket..." -LogType "Scoop" -Level "Info"
$fontsResult = Invoke-WithLogging -Command "scoop bucket add nerd-fonts" -LogType "Scoop" -Description ""
if (-not $fontsResult) {
    # 检查是否是因为 bucket 已存在
    $bucketList = & scoop bucket list 2>&1
    if ($bucketList -match "nerd-fonts") {
        Write-Log -Message "Nerd-fonts bucket already exists" -LogType "Scoop" -Level "Success"
        $fontsResult = $true
    } else {
        Write-Log -Message "Failed to add nerd-fonts bucket - Check details in: scoop-configuration.log" -LogType "Scoop" -Level "Error"
        exit 1
    }
} else {
    Write-Log -Message "Nerd-fonts bucket added successfully" -LogType "Scoop" -Level "Success"
}

Write-Log -Message "Installing and configuring Aria2..." -LogType "Scoop" -Level "Info"
$aria2InstallResult = Invoke-WithLogging -Command "scoop install aria2" -LogType "Scoop" -Description ""
$aria2EnableResult = Invoke-WithLogging -Command "scoop config aria2-enabled true" -LogType "Scoop" -Description ""
$aria2WarningResult = Invoke-WithLogging -Command "scoop config aria2-warning-enabled false" -LogType "Scoop" -Description ""
if (-not ($aria2InstallResult -and $aria2EnableResult -and $aria2WarningResult)) {
    Write-Log -Message "Failed to configure Aria2 properly - Check details in: scoop-configuration.log" -LogType "Scoop" -Level "Warning"
} else {
    Write-Log -Message "Aria2 configured successfully for faster downloads" -LogType "Scoop" -Level "Success"
}

# 2. 通过 Scoop 安装应用
Write-Host "📦 Installing applications..." -ForegroundColor Cyan -NoNewline
$appInstallResult = Install-Application -AppList $applist
if ($appInstallResult) {
    Write-Host " ✅" -ForegroundColor Green
} else {
    Write-Host " ⚠️" -ForegroundColor Yellow
    Write-Host "   Some applications failed to install. Check: $HOME\dotfiles\logs\app-installation.log" -ForegroundColor Gray
}

# 3. 配置软链接
Write-Host "🔗 Configuring symbolic links..." -ForegroundColor Cyan -NoNewline
$symlinkResult = Set-SymbolicLink -Targets $targets -Paths $paths 
if ($symlinkResult) {
    Write-Host " ✅" -ForegroundColor Green
} else {
    Write-Host " ⚠️" -ForegroundColor Yellow
    Write-Host "   Some symbolic links failed to create. Check: $HOME\dotfiles\logs\symbolicLink-configuration.log" -ForegroundColor Gray
}

# 4. 安装上下文菜单
Write-Host "📋 Installing context menus..." -ForegroundColor Cyan -NoNewline
$contextResult = Install-ContextMenus -ScoopAppsPath $scoopApps
if ($contextResult) {
    Write-Host " ✅" -ForegroundColor Green
} else {
    Write-Host " ⚠️" -ForegroundColor Yellow
    Write-Host "   Some context menus failed to install. Check: $HOME\dotfiles\logs\context-installation.log" -ForegroundColor Gray
}

# 5. 安装应用包
Write-Host "📦 Installing application packages..." -ForegroundColor Cyan

# Yazi 主题包
if (Test-CommandExists "ya") {
    Write-Log -Message "Installing yazi catppuccin-mocha theme package..." -LogType "Package" -Level "Info"
    $result = Invoke-WithLogging -Command "ya pkg add yazi-rs/flavors:catppuccin-mocha" -LogType "Package" -Description ""
    if (-not $result) {
        Write-Log -Message "Failed to install Yazi theme package - Check details in: package-installation.log" -LogType "Package" -Level "Error"
    } else {
        Write-Log -Message "Yazi theme package installed successfully" -LogType "Package" -Level "Success"
    }
} else {
    Write-Log -Message "Yazi (ya command) not found, skipping theme installation" -LogType "Package" -Level "Warning"
}

# 6. 完成安装
Write-Host ""
Write-Host "🎉 Dotfiles installation completed!" -ForegroundColor Green
Write-Host "📋 Check logs in: $HOME\dotfiles\logs\" -ForegroundColor Gray
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Cyan
Write-Host "1. Restart your terminal to apply changes" -ForegroundColor White
Write-Host "2. Run 'starship init powershell' if starship is not working" -ForegroundColor White
Write-Host "3. Check git configuration with 'git config --list'" -ForegroundColor White

Write-Log -Message "=== DOTFILES INSTALLATION COMPLETED ===" -Level "Success" -Silent
