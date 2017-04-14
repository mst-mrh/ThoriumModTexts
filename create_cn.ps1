$current_dir = $ExecutionContext.SessionState.Path.CurrentLocation

Write-Host "Cloning patcher..."

git clone -q --branch=master --depth=1 https://github.com/mst-mrh/Miyuu.TmlModTextDumper.git
Set-Location Miyuu.TmlModTextDumper
git submodule update --init --recursive
appveyor-retry nuget restore Miyuu.TmlModTextDumper.sln

msbuild Miyuu.TmlModTextDumper.sln /m /p:Configuration=Release
Set-Location Miyuu.TmlModTextDumper\bin\Release

$modname = "ThoriumMod"

$params = @{modloaderversion="tModLoader v0.9.2.3";platform="w"}

$mods = ((Invoke-WebRequest -Uri http://javid.ddns.net/tModLoader/listmods.php -Method POST -Body $params).Content | ConvertFrom-Json).modlist

$m = $mods | Where-Object name -eq $modname
$ver = $m.version
$link = $m.download
$name = $modname + ".tmod"

Write-Host "Start downloading $modname $ver from $link"

Try
{
    Invoke-WebRequest $link -OutFile $name
}
Catch
{
    (New-Object System.Net.WebClient).DownloadFile($link, $name)
}

.\Miyuu.TmlModTextDumper --file=$name --mode=patch --text=$current_dir

Get-Childitem -filter "*.tmod" | Copy-Item -Destination $current_dir