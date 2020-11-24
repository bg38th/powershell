$ConstPath = "C:\Program Files (x86)\Minecraft Launcher\MinecraftLauncher.exe"
$ConstStartTime = "08:15"
$ConstEndTime = "14:10"
$ConstWekkWorkDay = @(1, 2, 3, 4, 5)

$dt = Get-Date -Format t
if (((Get-Date).DayOfWeek -in $ConstWekkWorkDay) -and ($dt -gt $ConstStartTime) -and ($dt -lt $ConstEndTime))
{
	$IDs = @()
	$PathS = @($ConstPath)

	foreach ($mainItem in Get-Process -Name *Minecraft* )
	{
		$IDs += $mainItem.Id
		$ProcName = $mainItem.MainModule.ModuleName
		$cmdLine = Get-WmiObject Win32_Process -Filter "name = '$ProcName'" | Select-Object CommandLine
		$Name = $cmdLine[0].CommandLine.Replace('"', '')
		if (-not ($Name -in $PathS))
		{
			$PathS += $Name
		}
	}
	$IDs_slave = @()
	foreach ($itemProc in Get-CimInstance win32_process)
	{
		if ($itemProc.ParentProcessId -in $IDs)
		{
			$IDs_slave += $itemProc.ProcessId
		}

	}
	$IDs += $IDs_slave

	foreach ($item in $IDs) 
	{
		Stop-Process -ID $item -Force
	}

	foreach ($FullPath in $PathS)
	{
		$FilePath = Split-Path $FullPath
		if (Test-Path $FullPath)
		{
			#$FileName = Split-Path $FullPath -Leaf

			$rndName = -join (((48..57) + (65..90) + (97..122)) * 80 | Get-Random -Count 16 | % { [char]$_ }) + ".txt"
			$ConfFilePath = $FilePath + '\check.cnf'
			#$NewFileName = $FilePath + '\' + $rndName
			if (-not (Test-Path $ConfFilePath))
			{
				New-Item -Path $ConfFilePath -ItemType File
			}
			Set-Content $ConfFilePath $rndName -Force
			Rename-Item -Path $FullPath -NewName $rndName
			Write-Host "Move: " + $FullPath
		}
		else 
		{
			Write-Host $FullPath + " не найден"
		}
	}
}
else 
{
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
}

