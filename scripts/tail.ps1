$documents = [Environment]::GetFolderPath("MyDocuments")

Get-Content "$documents\My Games\Binding of Isaac Repentance\log.txt" -Tail 10 -Wait
