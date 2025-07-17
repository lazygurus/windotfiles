## My dotfiles

本仓库包含了我常用软件的配置项，以及自动化安装脚本，用于重装系统后快速恢复开发环境。

> **⚠️ 重要提醒**  
> Scoop 包管理器不支持在管理员权限下安装！  
> 请先在管理员权限下设置执行策略，然后在**普通用户权限**下运行安装脚本。

## 🚀 快速开始

### 前置要求

1. **D盘空间**：本脚本将 Scoop 安装在 D 盘，请确保有足够空间
2. **dotfiles 位置**：将此仓库克隆到 `$HOME\dotfiles` 目录
3. **网络代理**：需要先启动 Clash for Windows（代理端口：127.0.0.1:7890）
4. **PowerShell**：需要使用 PowerShell 7.0以上版本
5. **权限设置**：需要分## 🛠️ 故障排除

如果遇到问题，请：

1. **检查权限设置**：确认已在管理员权限下设置执行策略，然后在**普通用户权限**下运行脚本
2. **检查日志文件**：查看 `logs/` 目录中的相应日志文件
3. **验证网络连接**：确认代理设置是否正确（127.0.0.1:7890）
4. **检查磁盘空间**：确认 D 盘有足够的可用空间
5. **验证 PowerShell 版本**：确认使用 PowerShell 7.0 以上版本
6. **使用帮助文档**：运行 `Get-Help 函数名 -Full` 查看详细说明- 第一步：在**管理员权限**下设置执行策略
   - 第二步：在**普通用户权限**下运行安装脚本

⚠️ **关键提醒**：Scoop 不支持管理员权限安装，安装脚本必须在普通用户权限下运行！

### 设置执行权限

⚠️ **重要说明**：Scoop 包管理器不能在管理员权限下安装，因此需要分两步执行：

**第一步：设置执行权限（管理员权限）**

在**管理员权限**的 PowerShell 中运行：

```powershell
$ExecutionContext.SessionState.LanguageMode = "FullLanguage"
Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope CurrentUser
```

**第二步：执行安装脚本（普通用户权限）**

设置完执行权限后，**关闭管理员 PowerShell**，然后打开**普通用户权限**的 PowerShell：

### 运行安装脚本

⚠️ **注意**：必须在**普通用户权限**（非管理员）的 PowerShell 中运行安装脚本：

```powershell
# 进入 dotfiles 目录
cd $HOME\dotfiles

# 运行模块化安装脚本（普通用户权限）
.\Install-dotfiles.ps1
```

> **为什么不能用管理员权限？**
> - Scoop 设计为在用户级别安装，避免系统级权限污染
> - 管理员权限下安装会导致权限问题和路径冲突
> - 符号链接创建等操作会在脚本内部自动请求必要的权限

## 📋 功能特性

### ✅ 自动安装和配置

- **Scoop 包管理器**：自动安装和配置
- **开发环境**：Git, Node.js, Python, Miniconda3, CMake 等
- **代码编辑器**：Neovim, VS Code, PyCharm, Typora 等
- **终端工具**：Windows Terminal, Starship, Yazi, Fastfetch, Zoxide 等
- **字体**：JetBrains Mono Nerd Font 系列
- **桌面管理**：Komorebi, YASB 等
- **实用工具**：flow-launcher、Everything、mathpix等

### 🗂️ 完整应用列表

| 类别 | 应用名称 | 描述 |
|------|----------|------|
| **开发环境** | pwsh | PowerShell 7+ |
| | nodejs | Node.js 运行时 |
| | msys2 | Unix-like 环境 |
| | cmake | 跨平台构建工具 |
| | miniconda3 | Python 包管理器 |
| **字体** | JetBrainsMono-NF | JetBrains Mono Nerd Font |
| | JetBrainsMono-NF-Mono | JetBrains Mono Nerd Font Mono |
| | JetBrainsMono-NF-Propo | JetBrains Mono Nerd Font Propo |
| **终端工具** | windows-terminal | Windows 终端 |
| | starship | 智能终端提示符 |
| | yazi | 终端文件管理器 |
| | fastfetch | 系统信息显示工具 |
| | zoxide | 智能目录跳转 |
| | lazygit | Git 的 TUI 界面 |
| | bottom | 系统资源监视器 |
| | terminal-icons | PowerShell 文件图标 |
| **实用工具** | 7zip | 压缩解压工具 |
| | fd | 快速文件查找 |
| | ffmpeg | 多媒体处理工具 |
| | fzf | 模糊查找工具 |
| | imagemagick | 图像处理工具 |
| | innounp | Inno Setup 解包工具 |
| | jq | JSON 处理工具 |
| | lsd | 增强版 ls 命令 |
| | poppler | PDF 处理工具 |
| | resvg | SVG 渲染工具 |
| | ripgrep | 快速文本搜索 |
| **桌面管理** | yasb | 状态栏工具 |
| | komorebi | 平铺窗口管理器 |
| **代码工具** | neovim | 现代化 Vim 编辑器 |
| | neovide | Neovim GUI 客户端 |
| | vscode | Visual Studio Code |
| | pycharm | Python IDE |
| | typora | Markdown 编辑器 |
| **桌面应用** | googlechrome | Google Chrome 浏览器 |
| | discord | Discord 聊天工具 |
| | flow-launcher | 应用启动器 |
| | everything | 文件搜索工具 |
| | mathpix | 数学公式截图工具 |
| | snipaste | 截图工具 |
| | obs-studio | 直播录制软件 |
| | translucenttb | 任务栏透明化工具 |
| | zotero | 文献管理工具 |
| **网络工具** | v2rayn | 代理客户端 |

### 🎨 应用包和主题

| 应用 | 包名 | 描述 |
|------|------|------|
| Yazi | catppuccin-mocha | Catppuccin Mocha 主题包 |

### 📁 自动软链接配置

脚本会自动创建以下配置文件的软链接：

| 配置文件 | 源路径 | 目标路径 |
|----------|--------|----------|
| PowerShell Profile | `dotfiles\pwsh\profile.ps1` | `$PROFILE` |
| Starship 配置 | `dotfiles\starship\starship.toml` | `$HOME\.config\starship.toml` |
| Komorebi 主配置 | `dotfiles\komorebi\komorebi.json` | `$HOME\.config\komorebi\komorebi.json` |
| Komorebi 状态栏配置 | `dotfiles\komorebi\komorebi.bar.json` | `$HOME\.config\komorebi\komorebi.bar.json` |
| Komorebi 应用配置 | `dotfiles\komorebi\applications.json` | `$HOME\.config\komorebi\applications.json` |
| Komorebi 热键配置 | `dotfiles\komorebi\whkdrc` | `$HOME\.config\whkdrc` |
| Fastfetch 配置 | `dotfiles\fastfetch\` | `$HOME\.config\fastfetch` |
| YASB 配置 | `dotfiles\yasb\` | `$HOME\.yasb` |
| WezTerm 配置 | `dotfiles\wezterm\` | `$HOME\.config\wezterm` |
| Windows Terminal 配置 | `dotfiles\windows-terminal\settings.json` | `$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` |
| Neovim 配置 | `dotfiles\nvim\` | `$env:LOCALAPPDATA\nvim` |
| Yazi 按键配置 | `dotfiles\yazi\keymap.toml` | `$env:APPDATA\yazi\config\keymap.toml` |
| Yazi 主配置 | `dotfiles\yazi\yazi.toml` | `$env:APPDATA\yazi\config\yazi.toml` |
| Yazi 主题配置 | `dotfiles\yazi\theme.toml` | `$env:APPDATA\yazi\config\theme.toml` |

### 🔧 右键上下文菜单

自动安装以下应用的右键菜单：

| 应用 | 功能 |
|------|------|
| Windows Terminal | 在此处打开终端 |
| Git | Git Bash, Git GUI |
| VS Code | 用 VS Code 打开 |
| Neovide | 用 Neovide 打开 |

### 📝 详细日志记录

模块化脚本提供了详细的日志记录系统：

| 日志文件 | 内容 |
|----------|------|
| `logs/dotfiles-installation.log` | 主安装日志 |
| `logs/scoop-configuration.log` | Scoop 配置日志 |
| `logs/app-installation.log` | 应用安装日志 |
| `logs/symbolicLink-configuration.log` | 软链接配置日志 |
| `logs/context-installation.log` | 上下文菜单安装日志 |
| `logs/package-installation.log` | 应用包安装日志 |

### 🔧 错误处理

- 自动检查依赖是否存在
- 验证安装结果
- 详细的错误信息和建议
- 优雅的失败处理

## 📂 目录结构

```
dotfiles/
├── Install-dotfiles.ps1              # 主安装脚本（模块化版本）
├── Write-Logger.psm1                 # 日志记录模块
├── Install-Scoop.psm1                # Scoop 安装配置模块
├── Install-Application.psm1          # 应用安装模块
├── Set-SymbolicLink.psm1            # 软链接配置模块
├── Install-ContextMenus.psm1        # 上下文菜单安装模块
├── Install-Packages.psm1            # 应用包安装模块
├── App-and-Symlink.psm1             # 配置数据定义模块
├── logs/                            # 日志文件目录
│   ├── dotfiles-installation.log    # 主安装日志
│   ├── scoop-configuration.log      # Scoop 配置日志
│   ├── app-installation.log         # 应用安装日志
│   ├── symbolicLink-configuration.log # 软链接配置日志
│   ├── context-installation.log     # 上下文菜单日志
│   └── package-installation.log     # 包安装日志
├── fastfetch/                       # Fastfetch 配置
├── git/                             # Git 配置
├── komorebi/                        # Komorebi 窗口管理器配置
├── nvim/                            # Neovim 配置
├── pwsh/                            # PowerShell 配置
├── starship/                        # Starship 配置
├── wezterm/                         # WezTerm 配置
├── windows-terminal/                # Windows Terminal 配置
├── yasb/                            # YASB 状态栏配置
├── yazi/                            # Yazi 文件管理器配置
└── ...                              # 其他配置文件
```

## 🔧 模块说明

### Write-Logger.psm1 - 核心日志模块
- **功能**：提供统一的日志记录和输出管理
- **特性**：
  - 多级别日志（Info、Warning、Error、Success）
  - 多类型日志文件支持
  - 彩色控制台输出和emoji格式化
  - 结构化章节报告功能
- **核心函数**：
  - `Write-Log` - 写入日志消息
  - `Write-SectionHeader` - 显示章节标题
  - `Write-SectionResult` - 显示章节结果
  - `Test-CommandAvailability` - 检查命令可用性
  - `Invoke-WithLogging` - 执行命令并记录日志

### Install-Scoop.psm1 - Scoop 包管理器模块
- **功能**：完整的 Scoop 安装和配置
- **特性**：
  - 自动安装 Scoop 包管理器
  - 配置代理设置和 Git
  - 添加必要的 buckets（extras、nerd-fonts）
  - 安装和配置 Aria2 下载器
- **核心函数**：
  - `Install-ScoopManager` - 安装和配置完整的 Scoop 环境

### Install-Application.psm1 - 应用安装模块
- **功能**：批量安装和管理应用程序
- **特性**：
  - 智能检查已安装应用，避免重复安装
  - 详细的安装进度显示
  - 完整的成功/失败统计
  - 基于退出码的错误诊断
- **核心函数**：
  - `Install-Application` - 批量安装应用程序
  - `Get-InstallFailureReason` - 获取安装失败原因

### Set-SymbolicLink.psm1 - 符号链接配置模块
- **功能**：自动化配置文件符号链接管理
- **特性**：
  - 自动创建目标目录
  - 智能处理已存在的文件或链接
  - 详细的操作进度和日志记录
  - 统一的错误处理机制
- **核心函数**：
  - `Set-SymbolicLink` - 创建符号链接配置

### Install-ContextMenus.psm1 - 上下文菜单安装模块
- **功能**：安装应用程序的右键上下文菜单
- **特性**：
  - 为常用应用安装右键菜单
  - 支持文件关联配置
  - 批量处理多个应用
  - 智能检测应用安装状态
- **核心函数**：
  - `Install-ContextMenus` - 安装上下文菜单

### Install-Packages.psm1 - 应用包安装模块
- **功能**：安装应用程序的附加包和主题
- **特性**：
  - 可扩展的包安装框架
  - 智能检测包安装状态
  - 支持多种包管理器
- **核心函数**：
  - `Install-ApplicationPackages` - 安装应用程序包
  - `Install-YaziTheme` - 安装 Yazi 主题包

### App-and-Symlink.psm1 - 配置数据模块
- **功能**：统一的配置数据定义
- **特性**：
  - 集中管理应用程序列表
  - 定义符号链接源和目标路径映射
  - 提供系统路径变量
- **导出变量**：
  - `$applist` - 应用程序安装列表
  - `$targets` - 符号链接源文件路径
  - `$paths` - 符号链接目标路径

## 🔄 使用场景

1. **重装系统后**：一键恢复所有开发环境和配置
2. **新机器配置**：快速部署个人化的开发环境
3. **配置同步**：在多台机器间保持配置一致

## � 安装统计

安装完成后，您将获得：
- **44+ 应用程序**：涵盖开发、终端、桌面管理等各个方面
- **14 个配置文件**：自动软链接到正确位置
- **4 个右键菜单**：提升文件操作效率
- **1 个应用主题包**：美化 Yazi 文件管理器

## �🛠️ 故障排除

如果遇到问题，请：

1. **检查日志文件**：查看 `logs/` 目录中的相应日志文件
2. **验证网络连接**：确认代理设置是否正确（127.0.0.1:7890）
3. **检查磁盘空间**：确认 D 盘有足够的可用空间
4. **验证执行权限**：确认 PowerShell 执行策略设置正确
5. **使用帮助文档**：运行 `Get-Help 函数名 -Full` 查看详细说明

### 常见问题

| 问题 | 解决方案 |
|------|----------|
| Scoop 安装失败："需要管理员权限" | **错误**：不要在管理员权限下运行！在普通用户 PowerShell 中重新执行 |
| 脚本执行被阻止 | 确认已在管理员权限下设置执行策略：`Set-ExecutionPolicy ByPass -Scope CurrentUser` |
| Scoop 安装失败：网络错误 | 检查网络代理设置，确保可以访问 GitHub（127.0.0.1:7890）|
| 应用安装超时 | 检查 Aria2 配置，可能需要调整下载设置 |
| 符号链接创建失败 | 脚本会自动请求必要权限，如果失败请检查目标路径是否被占用 |
| 上下文菜单无效 | 检查应用是否正确安装到 Scoop 目录 |
| PowerShell 版本过低 | 升级到 PowerShell 7.0+ 或使用 `pwsh` 命令启动新版本 |

### 获取模块帮助

每个模块的函数都有帮助文档：

```powershell
# 查看 Write-Log 函数帮助
Get-Help Write-Log -Full

# 查看 Install-Application 函数帮助  
Get-Help Install-Application -Full

# 查看 Set-SymbolicLink 函数帮助
Get-Help Set-SymbolicLink -Full
```