$script_path = Split-Path $MyInvocation.MyCommand.Path -Parent

Get-Content -Encoding utf8  "${myInvocation}/../docs/main.md" | Out-File -Encoding utf8 "${myInvocation}/../README.md"

Get-ChildItem "${myInvocation}/../docs/items" -include *.md -rec |
  ForEach-Object { Get-Content -Encoding utf8 $_; ""} | Out-File -Append -Encoding utf8 "${myInvocation}/../README.md"
