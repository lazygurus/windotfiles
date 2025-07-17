<#
.SYNOPSIS
应用程序列表和符号链接配置模块

.DESCRIPTION
此模块定义了：
1. dotfiles 安装系统使用的所有应用程序列表
2. 符号链接的源文件和目标路径映射
3. 系统路径变量和配置目录
4. 为其他模块提供统一的配置数据源

.NOTES
此模块导出三个主要变量：
- $applist: 通过 Scoop 安装的应用程序列表
- $targets: 符号链接源文件路径数组  
- $paths: 符号链接目标路径数组
#>

# 顶级父目录
$dotfiles = "$HOME\dotfiles"
$config = "$HOME\.config"
$localAppData = "$HOME\AppData\Local"
$roamingAppData = "$HOME\AppData\Roaming"
$scoop = "D:\scoop"
$scoopApps = "$scoop\apps"

# 通过scoop安装的应用列表
$applist = @(
    # enviroments
    "pwsh",
    "nodejs",
    "msys2",
    "cmake",
    "miniconda3",
    # fonts
    "JetBrainsMono-NF",
    "JetBrainsMono-NF-Mono",
    "JetBrainsMono-NF-Propo",
    # terminal tools
    "windows-terminal",
    "starship", 
    "yazi",
    "fastfetch",
    "zoxide",
    "lazygit",
    "bottom",
    "terminal-icons",
    "7zip",
    "fd",
    "ffmpeg",
    "fzf",
    "imagemagick",
    "innounp",
    "jq",
    "lsd",
    "poppler",
    "resvg",
    "ripgrep",
    # windows desktop mangaer
    "yasb",
    "komorebi",
    # code tools
    "neovim",
    "neovide",
    "vscode",
    "pycharm",
    "typora",
    # desktop applications
    "googlechrome",
    "discord",
    "flow-launcher",
    "everything",
    "mathpix", 
    "snipaste",
    "obs-studio",
    "translucenttb",
    "zotero",
    # network
    "v2rayn"
)

# dotfiles路径列表
$targets = @(
    # pwsh
    "$dotfiles\pwsh\profile.ps1",
    # starship
    "$dotfiles\starship\starship.toml",
    # komorebi
    "$dotfiles\komorebi\komorebi.json",
    "$dotfiles\komorebi\komorebi.bar.json",
    "$dotfiles\komorebi\applications.json",
    "$dotfiles\komorebi\whkdrc",
    # fastfetch 
    "$dotfiles\fastfetch",
    # yasb
    "$dotfiles\yasb",
    # wezterm
    "$dotfiles\wezterm",
    # windows-terminal
    "$dotfiles\windows-terminal\settings.json",
    # neovim
    "$dotfiles\nvim",
    # yazi
    "$dotfiles\yazi\keymap.toml",
    "$dotfiles\yazi\yazi.toml",
    "$dotfiles\yazi\theme.toml"
)

# 软链接路径
$paths = @(
    # pwsh
    "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1", 
    # starship
    "$config\starship.toml",
    # komorebi
    "$HOME\komorebi.json",
    "$HOME\komorebi.bar.json",
    "$HOME\applications.json",
    "$config\whkdrc",
    # fastfetch
    "$config\fastfetch",
    # yasb
    "$config\yasb",
    # wezterm
    "$config\wezterm",
    # windows-terminal
    "$scoopApps\windows-terminal\current\settings\settings.json",
    # neovim
    "$localAppData\nvim",
    # yazi
    "$roamingAppData\yazi\keymap.toml",
    "$roamingAppData\yazi\yazi.toml",
    "$roamingAppData\yazi\theme.toml"
) 

# 导出变量
Export-ModuleMember -Variable "applist", "paths", "targets"
