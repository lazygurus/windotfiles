# 通过scoop安装的应用列表
$applist = @(
    # enviroments
    "pwsh",
    "git",
    "git-credential-manager",
    "nodejs",
    "msys2",
    "cmake",
    "miniconda3",
    # fonts
    "JetBrainsMono-NF"
    "JetBrainsMono-NF-Mono"
    "JetBrainsMono-NF-Propo"
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
    # user_gitconfig
    "$dotfiles\git\.gitconfig",
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
)

# 软链接路径
$paths = @(
    # user_gitconfig
    "$HOME\.gitconfig",
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
) 

# 导出变量
Export-ModuleMember -Variable "applist", "paths", "targets"
