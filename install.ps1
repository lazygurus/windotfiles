# 顶级父目录
$dotfiles = "$HOME\dotfiles"
$config = "$HOME\.config"
$localAppData = "$HOME\AppData\Local"
$roamingAppData = "$HOME\AppData\Roaming"
$scoop = "D:\scoop"
$scoopApps = "$scoop\apps"

# 导入下载应用和配置软链接的模块
Import-Module "$dotfiles\Install-Application.psm1"
Import-Module "$dotfiles\Set-SymbolicLink.psm1"
Import-Module "$dotfiles\App-and-Symlink.psm1"

# 安装scoop
Write-Host ""
Write-Host "🔭 Install And Configurate Scoop"

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "🚀 Scoop is not installed, installing now..."

    # 安装scoop
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    irm get.scoop.sh -outfile 'install.ps1' -proxy "127.0.0.1:7890" *>> scoop-installation.log
    .\install.ps1 -ScoopDir $scoop -proxy "127.0.0.1:7890" *>> scoop-installation.log
    Remove-Item .\install.ps1

    # 是否成功安装scoop
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "👌 Scoop installation successful!"
    } 
    else {
        Write-Error "💥 Scoop installation failed, please check your network or permission settings."
        exit
    }
} 
else {
    Write-Host "👌 Scoop is already installed, skipping installation."
}

# 配置scoop
Write-Host ""
Write-Host "🔭 Configurate Scoop"

Write-Host "🚀 set scoop proxy to clash"
scoop config proxy 127.0.0.1:7890 *>> scoop-configuration.log
Write-Host "🚀 add bucket extras."
scoop bucket add extras *>> scoop-configuration.log 
Write-Host "🚀 add bucket nerd-fonts"
scoop bucket add nerd-fonts *>> scoop-configuration.wwlog
Write-Host "🚀 set aria2 to use multi-process function"
scoop install aira2 *>> scoop-installation.log
scoop config aria2-enabled true *>> scoop-configuration.log
socop config aria2-warning-enabled false *>> scoop-configuration.log

Write-Host "👌 Scoop configuration complete."

# 通过scoop安装应用
Write-Host ""
Write-Host "🔭 Install Apps Via Scoop"
Install-Application -AppList $applist

# 配置软链接
Write-Host ""
Write-Host "🔭 Configurate SymbolicLink"
Set-SymbolicLink -Paths $paths -Targets $targets 

# 安装上下文环境使可以通过右键打开应用
Write-Host ""
Write-Host "🔭 Install Context"

# windows terminal
Write-Host "🚀 install windows-terminal context"
reg import "$scoopApps\windows-terminal\current\install-context.reg" *>> context-installation.log
# git
Write-Host "🚀 install git context"
reg import "$scoopApps\git\current\install-context.reg"
reg import "$scoopApps\git\current\install-file-associations.reg"
# vscode
Write-Host "🚀 install vscode context"
reg import "$scoopApps\vscode\current\install-context.reg"
# pycharm
Write-Host "🚀 install pycharm context"
reg import "$scoopApps\pycharm\current\install-context.reg"
# neovide
Write-Host "🚀 install neovide context"
reg import "$scoopApps\neovide\current\install-context.reg"

Write-Host "👌 Context installation complete."

# 为一些应用安装包
Write-Host "🔭 Install Packages For Some Apps"

# yazi
Write-Host "🚀 install yazi catppuccin-mocha theme package"
ya pkg add yazi-rs/flavors:catppuccin-mocha *>> package-installation.log

Write-Host "👌 Packages installation complete."
