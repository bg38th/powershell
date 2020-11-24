$ConstPath = "C:\Program Files (x86)\Minecraft Launcher\MinecraftLauncher.exe"

$FilePath = Split-Path $ConstPath
$FileName = Split-Path $ConstPath -Leaf
$ConfFilePath = $FilePath + '\check.cnf'
if (Test-Path $ConfFilePath)
{
	$Conf = Get-Content -Path $ConfFilePath
	$SourceFileName = if ($Conf -is [array]) { $Conf[0] }Else { $Conf }
	$SourcePath = $FilePath + '\' + $SourceFileName
	if (Test-Path $SourcePath)
	{
		Rename-Item -Path $SourcePath -NewName $FileName
		Remove-Item $ConfFilePath
	}	
}