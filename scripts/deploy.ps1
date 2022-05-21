$script_path = Split-Path $MyInvocation.MyCommand.Path -Parent

$root_path = Resolve-Path "${script_path}/.."
$build_path = Resolve-Path "${root_path}/build"

$mod_name = 'moriah'

$steam_path = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Valve\Steam\' 'InstallPath' -ErrorAction SilentlyContinue

if (!$steam_path) {
  $steam_path = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam\' 'InstallPath' -ErrorAction SilentlyContinue
}


if (!$steam_path) {
  throw [System.IO.FileNotFoundException] "Steam installation path not found."
}

$steam_path

$isaac_mod_path = "$steam_path\steamapps\common\The Binding of Isaac Rebirth\mods\$mod_name"

$isaac_mod_path

Remove-Item $isaac_mod_path -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue

Copy-Item -Recurse -Force -Path "$build_path" $isaac_mod_path
