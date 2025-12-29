Set-Location $PSScriptRoot

function Command-Exists {
    param ($cmd)
    return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null
}

$inst = Join-Path $PSScriptRoot "installers"

if (-not (Command-Exists git)) {
    Start-Process "$inst\git.exe" -ArgumentList "/VERYSILENT /NORESTART" -Wait
}

if (-not (Command-Exists node)) {
    Start-Process msiexec -ArgumentList "/i `"$inst\node.msi`" /quiet /norestart" -Wait
}

if (-not (Command-Exists python)) {
    Start-Process "$inst\python.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
}

# refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")

npm install -g pnpm@10.4.1

Get-Process Discord -ErrorAction SilentlyContinue | Stop-Process -Force

Set-Location "$PSScriptRoot\equicord"

git pull
pnpm install --frozen-lockfile
pnpm build
pnpm inject

python "$PSScriptRoot\stereo_injector.py"

Write-Host "=== OFFLINE INSTALL DONE ==="
pause
