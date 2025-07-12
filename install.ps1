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
    irm get.scoop.sh -outfile 'install.ps1' -proxy "127.0.0.1:7890" *>> scoop_installation.log
    .\install.ps1 -ScoopDir $scoop -proxy "127.0.0.1:7890" *>> scoop_installation.log
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
scoop config proxy 127.0.0.1:7890 *>> scoop_configuration.log
Write-Host "🚀 set proxy to clash"
scoop bucket add extras *>> scoop_configuration.log 
Write-Host "🚀 add bucket extras."
scoop bucket add nerd-fonts *>> scoop_configuration.wwlog
Write-Host "🚀 add bucket nerd-fonts"
scoop install aira2 *>> scoop_installation.log
scoop config aria2-enabled true *>> scoop_configuration.log
socop config aria2-warning-enabled false *>> scoop_configuration.log
Write-Host "🚀 set aria2 to use multi-process function"
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
Write-Host "🔭 Install Context"
# windows terminal
reg import "$scoopApps\windows-terminal\current\install-context.reg"
Write-Host "🚀 install windows-terminal context"
# git
reg import "$scoopApps\git\current\install-context.reg"
reg import "$scoopApps\git\current\install-file-associations.reg"
Write-Host "🚀 install git context"
# vscode
reg import "$scoopApps\vscode\current\install-context.reg"
Write-Host "🚀 install vscode context"
# pycharm
reg import "$scoopApps\pycharm\current\install-context.reg"
Write-Host "🚀 install pycharm context"
# neovide
reg import "$scoopApps\neovide\current\install-context.reg"
Write-Host "🚀 install neovide context"
