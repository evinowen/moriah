$script_path = Split-Path $MyInvocation.MyCommand.Path -Parent
$root_path = Resolve-Path "$script_path\.."

if (Test-Path "$root_path\build") {
  Remove-Item -Recurse -Force "$root_path\build"
}

New-Item -Force "$root_path\build" -ItemType Directory
$build_path = Resolve-Path "$root_path\build"

New-Item -Force "$build_path\main.lua" -ItemType File
$main_path = Resolve-Path "$build_path\main.lua"

function Include-Raw-Directory {
  param (
    $path
  )

  New-Item -Force "$build_path\$path" -ItemType Directory

  $filters = "*.xml", "*.anm2", "*.png", "*.wav"
  foreach ($filter in $filters) {
    Copy-Item "$root_path\$path" -Recurse -Filter "$filter" -Destination "$build_path"
  }
}

Include-Raw-Directory -path "content"
Include-Raw-Directory -path "resources"

function Include-Source-File {
  param (
    $path
  )

  Get-Content -Encoding utf8  "$root_path\$path" | Out-File -Append -Encoding utf8 "$main_path"
}

function Include-Source-Directory {
  param (
    $path
  )

  $files = Get-ChildItem "$root_path\$path" -include *.lua -rec

  foreach ($file in $files) {
    $relative_path = $file.FullName.Substring($root_path.Length)

    "-- $relative_path" | Out-File -Append -Encoding utf8 "$main_path"
    "" | Out-File -Append -Encoding utf8 "$main_path"
    Get-Content -Encoding utf8 $file | Out-File -Append -Encoding utf8 "$main_path"
    "" | Out-File -Append -Encoding utf8 "$main_path"
    "----" | Out-File -Append -Encoding utf8 "$main_path"
    "" | Out-File -Append -Encoding utf8 "$main_path"
  }
}

Include-Source-File -path "src\support.lua"
Include-Source-Directory -path "src\items"
Include-Source-Directory -path "src\transformations"
Include-Source-File -path "src\main.lua"
