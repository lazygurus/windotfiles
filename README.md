### My dotfiles
本仓库包含了我常用软件的配置项，也包含了几个pwsh脚本，install脚本用于自动化重装系统时的软件安装和配置流程。

1. 本脚本是将scoop安装在D盘，因此要保证设备上有D盘，且存在一定空间，因为scoop安装的应用都存在D盘
2. 本脚本要求dotfiles存放在Home目录下
3. 要运行install.ps1脚本,首先要安装clash for windows
4. 然后要在管理员身份下设置脚本权限

```
Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope CurrentUser
```
