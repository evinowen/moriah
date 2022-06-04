$script_path = Split-Path $MyInvocation.MyCommand.Path -Parent

$directories = "items", "trinkets", "cards", "transformations"

foreach ($directory in $directories) {
  $directory_path = "$script_path\..\json\$directory"

  Get-ChildItem "$directory_path" -include *.json -rec |
    ForEach-Object {
      $name = (Get-Item $_).BaseName
      $data = Get-Content -Encoding utf8 $_ | ConvertFrom-Json

      $type = $data.type
      $quality = "$([char]0x2605)" * $data.quality # Solid Star
      $unquality = "$([char]0x2606)" * (5 - $data.quality) # Empty Star

      $template_md = Get-Content -Encoding utf8 "$script_path\templates\$type.steam"
      $template_md = $template_md.Replace("%%%NAME%%%", $data.name)
      $template_md = $template_md.Replace("%%%NAME_UPPERCASE%%%", $data.name.ToUpper())
      $template_md = $template_md.Replace("%%%PORTRAIT%%%", $data.portrait)
      $template_md = $template_md.Replace("%%%QUOTE%%%", $data.quote)
      $template_md = $template_md.Replace("%%%DESCRIPTION%%%", $data.description)
      $template_md = $template_md.Replace("%%%QUALITY%%%", $quality + $unquality)

      $charge = ""

      if ($data.charge) {
        $charge_quantity = $data.charge.quantity
        $charge_type = $data.charge.type

        if ($charge_quantity -ne 1) {
          $charge_type = "${charge_type}s"
        }

        $charge = "$charge_quantity $charge_type"
      }

      $template_md = $template_md.Replace("%%%CHARGE%%%", $charge)

      $template_md = $template_md.Replace("%%%POOLS%%%", $data.pools -join "`n")
      $template_md = $template_md.Replace("%%%EFFECTS%%%", ($data.effects | ForEach-Object { " [*] $_" }) -join "`n")
      $template_md = $template_md.Replace("%%%GIF%%%", $data.gif)

      $template_md | Out-File -Encoding utf8 "$script_path\..\docs\$directory\$name.steam"
    }
}