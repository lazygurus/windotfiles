function Set-SymbolicLink {
    param (
        [string[]]$Targets,  # dotfiles
        [string[]]$Paths     # SymbolicLink
    )

    # dotfiles 和 symboliclink 数量是否相同
    if ($Targets.Length -ne $Paths.Length) {
        Write-Error "💥 the length of dotfiles is not equal with symboliclink"
        return
    }

    # 依次设置软链接
    for ($i = 0; $i -lt $Targets.Length; $i++) {
        $Target = $Targets[$i]
        $Path = $Paths[$i]

        # 删除已有软链接或者配置文件
        if (Test-Path $Path) {
            Write-Host "👻 delete: $Path"
            Remove-Item $Path -Recurse -Force
        }

        # 创建新的软链接
        Write-Host "😎 new: $Target"
        # 将所有流都追加到 log 中
        New-Item -ItemType SymbolicLink -Path $Path -Target $Target *>> symbolicLink-configuration.log
    }
}

Export-ModuleMember -Function "Set-SymbolicLink"
