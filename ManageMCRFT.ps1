Clear-Host
#$ConstPath = "C:\Program Files (x86)\Minecraft Launcher\MinecraftLauncher.exe"

function CheckWorkTime()
{
	$constConfig = @(
		@{day = 0; times = @(@{start = "19:00"; end = "21:00" }) },
		@{day = 1; times = @{start = "08:15"; end = "14:10" }, @{start = "19:00"; end = "21:00" } },
		@{day = 2; times = @{start = "08:15"; end = "13:10" }, @{start = "19:10"; end = "21:00" } },
		@{day = 3; times = @{start = "08:15"; end = "14:10" }, @{start = "19:00"; end = "21:00" } },
		@{day = 4; times = @{start = "08:15"; end = "14:10" }, @{start = "19:00"; end = "21:00" } },
		@{day = 5; times = @(@{start = "08:15"; end = "14:10" }) }
	)

	$curDay = Get-Date #-Date "23.11.2020 17:01"
	$curTime = Get-Date -Date $curDay -Format t

	$curConfItem = $constConfig.where( { $_.day -eq $curDay.DayOfWeek })
	if ($curConfItem.Count -ne 0)
	{
		$curInterval = $curConfItem.times.where( { ($curTime -ge $_.start) -and ($curTime -le $_.end) })
		if ($curInterval.Count -ne 0)
		{
			return $true
		}
	}

	return $false
}

function GetScriptConf()
{
	if ( (Test-Path -Path Registry::HKEY_CURRENT_USER\Software\BGSoft) )
	{ $rScriptConf = Get-Item -Path Registry::HKEY_CURRENT_USER\Software\BGSoft }
	else 
	{ $rScriptConf = New-Item -Path Registry::HKEY_CURRENT_USER\Software\BGSoft }

	return "Registry::" + $rScriptConf 

}

function GetMask([string]$sCurConf)
{
	$curMaskProperty = Get-ItemProperty -Path $sCurConf -name Mask -ErrorAction silentlycontinue
	if ($curMaskProperty -eq $null)
	{ $curMaskProperty = New-ItemProperty -Path $sCurConf -name Mask -Value "*Minecraft*" }

	return $curMaskProperty.Mask
}

function CheckDoHomework([string]$sCurConf)
{
	$rHWMark = Get-ItemProperty -Path $sCurConf -name DoHomework -ErrorAction silentlycontinue
	if ($rHWMark -eq $null)
	{
		return 0
	}
	else
	{
		return $rHWMark.DoHomework
	}
}

function ClearDoHomework([string]$sCurConf)
{
	$rHWMark = Remove-ItemProperty -Path $sCurConf -name DoHomework -ErrorAction silentlycontinue
}

function GetProcess([string]$sMask)
{
	$PathS = @()
	$IDs = @()
	foreach ($mainItem in Get-Process -Name $sMask )
	{
		$IDs += $mainItem.Id
		$ProcName = $mainItem.MainModule.ModuleName
		$cmdLine = Get-CimInstance Win32_Process -Filter "name = '$ProcName'" | Select-Object CommandLine
		$Name = $cmdLine[0].CommandLine.Replace('"', '').Trim()
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
	return @{PathS = $PathS; IDs = $IDs }
}

function GetProcessConf([string]$rScriptConf, [string]$sProcessPath)
{
	$bHasConf = $false
	$oConf = $null
	foreach ($rChildPart in Get-ChildItem $rScriptConf)
	{
		$rChildPart = "Registry::" + $rChildPart 
		if ((Get-ItemProperty -Path $rChildPart)."(default)" -eq $sProcessPath)
		{
			$bHasConf = $true
			$oConf = $rChildPart
		}
	}

	if (-not $bHasConf)
	{
		$iNewName = (Get-ChildItem $rScriptConf).Count
		$oConf = New-Item -Path ($rScriptConf + "\" + $iNewName)
		$oConf = "Registry::" + $oConf

		Set-Item -Path $oConf -Value $sProcessPath
		$sFileName = Split-Path $sFullProcessPath -Leaf
		Set-ItemProperty -Path $oConf -Name "fileName" -Value $sFileName
	}

	return $oConf
}

function SetCriptFileName([string]$rProcessConf)
{
	$sNewFileName = -join (((48..57) + (65..90) + (97..122)) * 80 | Get-Random -Count 16 | % { [char]$_ }) + ".txt"
	Set-ItemProperty -Path $rProcessConf -Name "newFileName" -Value $sNewFileName

	return $sNewFileName
}

function GetCriptFileName([string]$rProcessConf)
{
	$sFileName = Get-ItemProperty -Path $rProcessConf -Name "newFileName"

	return $sFileName.newFileName
}

$rScriptConf = GetScriptConf

$sCurMask = GetMask $rScriptConf

$retBool = CheckWorkTime

if ($retBool -and -not (CheckDoHomework $rScriptConf))
{
	$oProcesses = GetProcess $sCurMask

	foreach ($item in $oProcesses.IDs) 
	{
		Stop-Process -ID $item -Force
	}

	foreach ($sFullProcessPath in $oProcesses.PathS)
	{

		$rProcessConf = GetProcessConf $rScriptConf $sFullProcessPath

		$FilePath = Split-Path $sFullProcessPath
		if (Test-Path $sFullProcessPath)
		{
			$sNewFileName = SetCriptFileName $rProcessConf
			Rename-Item -Path $sFullProcessPath -NewName $sNewFileName
			Write-Host "Move: " + $sFullProcessPath
		}
		else 
		{
			Write-Host $sFullProcessPath + " не найден"
		}
	}
}
else 
{
	foreach ($rChildPart in Get-ChildItem $rScriptConf)
	{
		$rChildPart = "Registry::" + $rChildPart
		$sFullProcessPath = (Get-ItemProperty -Path $rChildPart)."(default)"
		$FilePath = Split-Path $sFullProcessPath
		$sCriptFileName = GetCriptFileName $rChildPart
		$SourcePath = $FilePath + '\' + $sCriptFileName
		$FileName = Get-ItemProperty -Path $rChildPart -Name "fileName" 
		$res = Rename-Item -Path $SourcePath -NewName $FileName.fileName

		Remove-Item $rChildPart

		Write-Host $FileName.fileName + " восстановлен"
	}
}

if (-not $retBool)
{
	ClearDoHomework $rScriptConf
}
