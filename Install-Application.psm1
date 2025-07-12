function Install-Application {
    param (
        [string[]]$AppList  # 应用名称数组
    )

    # 获取当前已安装的应用名
    $installedApps = & scoop export |
                       ConvertFrom-Json |
                       Select-Object -ExpandProperty apps |
                       Select-Object -ExpandProperty Name

    foreach ($app in $AppList) {
        if ($installedApps -contains $app) {
            Write-Host "👌 $app already instlled"
            continue
        } 
        else {
            Write-Host "🚀 $app installing..."
            (scoop install $app *>> app_installation.log) *>> app_suggestion.log
        }
        $installedApps = & scoop export |
                           ConvertFrom-Json |
                           Select-Object -ExpandProperty apps |
                           Select-Object -ExpandProperty Name

        # 检查是否成功安装
        if ($installedApps -contains $app) {
            Write-Host "👌 $app sucessfully installed"
        } 
        else {
            Write-Host "💥 $app installation failed, please check the app_installation.log"
        }
    }
}

Export-ModuleMember -Function "Install-Application"
