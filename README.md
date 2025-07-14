## My dotfiles

本仓库包含了我常用软件的配置项，以及自动化安装脚本，用于重装系统后快速恢复开发环境。

## 🚀 快速开始

### 前置要求

1. **D盘空间**：本脚本将 Scoop 安装在 D 盘，请确保有足够空间
2. **dotfiles 位置**：将此仓库克隆到 `$HOME\dotfiles` 目录
3. **网络代理**：需要先启动 Clash for Windows（代理端口：127.0.0.1:7890）
4. **Powershell**：需要使用 Powershell 7.0以上版本
4. **执行权限**：需要在管理员身份下设置 PowerShell 执行权限

### 设置执行权限

在管理员权限的 PowerShell 中运行：

```powershell
$ExecutionContext.SessionState.LanguageMode = "FullLanguage"
Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope CurrentUser
```

### 运行安装脚本

```powershell
# 进入 dotfiles 目录
cd $HOME\dotfiles

# 运行改进版安装脚本
.\Install-Dotfiles.ps1
```

## 📋 功能特性

### ✅ 自动安装和配置

- **Scoop 包管理器**：自动安装和配置
- **开发工具**：Git, Node.js, Python, Neovim, VS Code 等
- **终端工具**：Windows Terminal, Starship, Yazi, Fastfetch 等
- **字体**：JetBrains Mono Nerd Font 系列
- **桌面管理**：Komorebi, YASB 等

### 📁 自动软链接配置

脚本会自动创建以下配置文件的软链接：

- PowerShell Profile
- Starship 配置
- Komorebi 窗口管理器配置
- Neovim 配置
- Yazi 文件管理器配置
- Windows Terminal 配置
- 等等...

### 📝 日志记录

改进版脚本提供了详细的日志记录：

- **主日志**：`logs/dotfiles-installation-[timestamp].log`
- **应用安装日志**：`logs/app-installation.log`
- **软链接日志**：`logs/symbolicLink-configuration.log`
- **上下文菜单日志**：`logs/context-installation.log`

### 🔧 错误处理

- 自动检查依赖是否存在
- 验证安装结果
- 详细的错误信息和建议
- 优雅的失败处理

## 📂 目录结构

```
dotfiles/
├── Install-dotfiles.ps1              # 原版安装脚本
├── Install-dotfiles-improved.ps1     # 改进版安装脚本（推荐）
├── Install-Application.psm1          # 应用安装模块
├── Set-SymbolicLink.psm1            # 软链接配置模块
├── Install-ContextMenus.psm1        # 上下文菜单安装模块
├── App-and-Symlink.psm1             # 应用和路径定义
├── Logger.psm1                      # 统一日志记录模块
├── logs/                            # 日志文件目录
│   ├── dotfiles-installation-*.log  # 主日志文件
│   ├── app-installation.log         # 应用安装日志
│   ├── symbolicLink-configuration.log # 软链接配置日志
│   ├── context-installation.log     # 上下文菜单日志
│   ├── package-installation.log     # 包安装日志
│   └── scoop-configuration.log      # Scoop 配置日志
├── nvim/                            # Neovim 配置
├── pwsh/                            # PowerShell 配置
├── starship/                        # Starship 配置
├── yazi/                            # Yazi 配置
├── wezterm/                         # WezTerm 配置
└── ...                              # 其他配置文件
```

## 🔧 模块说明

### Logger.psm1 - 统一日志模块
- 提供统一的日志记录功能
- 支持不同类型的日志文件（应用安装、软链接、上下文菜单等）
- 自动时间戳和日志级别管理
- 彩色控制台输出

### Install-Application.psm1 - 应用安装模块
- 通过 Scoop 批量安装应用
- 检查已安装应用，避免重复安装
- 安装进度显示
- 详细的成功/失败统计

### Set-SymbolicLink.psm1 - 软链接配置模块
- 自动创建目标目录
- 检查源文件是否存在
- 处理已存在的文件或链接
- 详细的操作日志记录

### Install-ContextMenus.psm1 - 上下文菜单安装模块
- 为常用应用安装右键菜单
- 支持文件关联配置
- 批量处理多个应用

### App-and-Symlink.psm1 - 配置定义模块
- 定义要安装的应用列表
- 定义软链接的源和目标路径

## 🔄 使用场景

1. **重装系统后**：一键恢复所有开发环境和配置
2. **新机器配置**：快速部署个人化的开发环境
3. **配置同步**：在多台机器间保持配置一致

## 🛠️ 故障排除

如果遇到问题，请：

1. 检查 `logs/` 目录中的日志文件
2. 确认网络代理是否正常工作
3. 验证 D 盘是否有足够空间
4. 检查 PowerShell 执行权限