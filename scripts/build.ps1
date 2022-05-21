$script_path = Split-Path $MyInvocation.MyCommand.Path -Parent

$root_path = Resolve-Path "${script_path}\.."

$source_path = Resolve-Path "${root_path}\src"

if (Test-Path "${root_path}\build") {
  Remove-Item -Recurse -Force "${root_path}\build"
}

New-Item -Force "${root_path}\build" -ItemType Directory

$build_path = Resolve-Path "${root_path}\build"

New-Item -Force "${build_path}\content" -ItemType Directory

Copy-Item "${root_path}\content"   -Recurse -Filter "*.xml"  -Destination "$build_path"
Copy-Item "${root_path}\content" -Recurse -Filter "*.anm2" -Destination "$build_path"
Copy-Item "${root_path}\content" -Recurse -Filter "*.png"  -Destination "$build_path"
Copy-Item "${root_path}\content" -Recurse -Filter "*.wav"  -Destination "$build_path"

New-Item -Force "${build_path}\resources" -ItemType Directory

Copy-Item "${root_path}\resources"   -Recurse -Filter "*.xml"  -Destination "$build_path"
Copy-Item "${root_path}\resources" -Recurse -Filter "*.png"  -Destination "$build_path"
Copy-Item "${root_path}\resources" -Recurse -Filter "*.anm2" -Destination "$build_path"
Copy-Item "${root_path}\resources" -Recurse -Filter "*.wav"  -Destination "$build_path"

New-Item -Force "${build_path}\main.lua" -ItemType File

$main_path = Resolve-Path "${build_path}\main.lua"

Get-Content -Encoding utf8  "${source_path}\support.lua" | Out-File -Append -Encoding utf8 "${main_path}"

$items = Get-ChildItem "${source_path}\items" -include *.lua -rec

foreach ($item in $items) {
  $relative_path = $item.FullName.Substring($root_path.Length)
  "-- ${relative_path}" | Out-File -Append -Encoding utf8 "${main_path}"
  "" | Out-File -Append -Encoding utf8 "${main_path}"
  Get-Content -Encoding utf8 $item | Out-File -Append -Encoding utf8 "${main_path}"
  "" | Out-File -Append -Encoding utf8 "${main_path}"
  "----" | Out-File -Append -Encoding utf8 "${main_path}"
  "" | Out-File -Append -Encoding utf8 "${main_path}"
}

$transformations = Get-ChildItem "${source_path}\transformations" -include *.lua -rec

foreach ($transformation in $transformations) {
  $relative_path = $transformation.FullName.Substring($root_path.Length)
  "-- ${relative_path}" | Out-File -Append -Encoding utf8 "${main_path}"
  "" | Out-File -Append -Encoding utf8 "${main_path}"
  Get-Content -Encoding utf8 $transformation | Out-File -Append -Encoding utf8 "${main_path}"
  "" | Out-File -Append -Encoding utf8 "${main_path}"
  "----" | Out-File -Append -Encoding utf8 "${main_path}"
  "" | Out-File -Append -Encoding utf8 "${main_path}"
}

Get-Content -Encoding utf8  "${source_path}\main.lua" | Out-File -Append -Encoding utf8 "${main_path}"
