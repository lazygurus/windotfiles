# 优化的 dotfiles 安装脚本
# 顶级父目录
$dotfiles = "$HOME\dotfiles"

# 导入模块
Import-Module (Join-Path $dotfiles "Write-Logger.psm1")
Import-Module (Join-Path $dotfiles "Install-Application.psm1")
Import-Module (Join-Path $dotfiles "Set-SymbolicLink.psm1")
Import-Module (Join-Path $dotfiles "Install-ContextMenus.psm1")
Import-Module (Join-Path $dotfiles "App-and-Symlink.psm1")
Import-Module (Join-Path $dotfiles "Install-Scoop.psm1")
Import-Module (Join-Path $dotfiles "Install-Packages.psm1")

# 初始化日志系统
Initialize-LogDirectory

# 导入应用列表和路径配置
$applist = (Get-Module "App-and-Symlink").ExportedVariables['applist'].Value
$targets = (Get-Module "App-and-Symlink").ExportedVariables['targets'].Value  
$paths = (Get-Module "App-and-Symlink").ExportedVariables['paths'].Value

Write-Host "🚀 Starting dotfiles installation" -ForegroundColor Cyan

# 1. 安装和配置 Scoop
Write-SectionHeader "Scoop Package Manager Setup"
$scoopResult = Install-ScoopManager -ScoopDirectory "D:\scoop" -ProxyUrl "127.0.0.1:7890" -DotfilesPath $dotfiles
Write-SectionResult -SectionName "Scoop Package Manager Setup" -Success $scoopResult -DetailsLogFile "scoop-configuration.log" -SuccessMessage "Scoop and all components configured successfully" -FailureMessage "Scoop setup completed with some issues"

# 2. 通过 Scoop 安装应用
Write-SectionHeader "Application Installation"
$appInstallResult = Install-Application -AppList $applist
Write-SectionResult -SectionName "Application Installation" -Success $appInstallResult -DetailsLogFile "app-installation.log" -SuccessMessage "All applications installed successfully" -FailureMessage "Application installation completed with some failures"

# 3. 配置软链接
Write-SectionHeader "Symbolic Links Configuration"
$symlinkResult = Set-SymbolicLink -Targets $targets -Paths $paths
Write-SectionResult -SectionName "Symbolic Links Configuration" -Success $symlinkResult -DetailsLogFile "symbolicLink-configuration.log" -SuccessMessage "All symbolic links created successfully" -FailureMessage "Symbolic links configuration completed with some failures"

# 4. 安装上下文菜单
Write-SectionHeader "Context Menus Installation"
$contextResult = Install-ContextMenus
Write-SectionResult -SectionName "Context Menus Installation" -Success $contextResult -DetailsLogFile "context-installation.log" -SuccessMessage "All context menus installed successfully" -FailureMessage "Context menus installation completed with some failures"

# 5. 安装应用包
Write-SectionHeader "Application Packages Setup"
$yaziPackageSuccess = Install-ApplicationPackages
Write-SectionResult -SectionName "Application Packages Setup" -Success $yaziPackageSuccess -DetailsLogFile "package-installation.log" -SuccessMessage "All application packages configured successfully" -FailureMessage "Application packages setup completed with some issues"

# 6. 完成安装
Write-SectionHeader "Installation Summary"
Write-Host ""
Write-Host "🎉 Dotfiles installation completed!" -ForegroundColor Green
Write-Host "📋 Check logs in: $HOME\dotfiles\logs\" -ForegroundColor Gray
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Cyan
Write-Host "1. Restart your terminal to apply changes" -ForegroundColor White
Write-Host "2. Run 'starship init powershell' if starship is not working" -ForegroundColor White
Write-Host "3. Check git configuration with 'git config --list'" -ForegroundColor White

# 最终安装结果报告
$overallSuccess = $scoopResult -and $appInstallResult -and $symlinkResult -and $contextResult -and $yaziPackageSuccess
Write-SectionResult -SectionName "Dotfiles Installation" -Success $overallSuccess -SuccessMessage "Complete dotfiles installation finished successfully!" -FailureMessage "Dotfiles installation completed with some issues - check individual logs for details"

Write-Log -Message "=== DOTFILES INSTALLATION COMPLETED ===" -Level "Success" -Silent
