# ------------------ alias ------------------ #
Set-Alias -Name ls -Value lsd
Set-Alias -Name ff -Value fastfetch
Set-Alias lvim 'C:\Users\Bear Professor\.local\bin\lvim.ps1'

# ------------------ event ------------------ #
$settings = "C:\Users\Bear Professor\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# ------------------ event ------------------ #
# # cd the current directory when quit yazi
function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
}

# ------------------ some tools init ------------------ #
Invoke-Expression (&starship init powershell)

# zoxide should init after starship so that it can init zoxide database correctly
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# ------------------ actions ------------------ #
cls
