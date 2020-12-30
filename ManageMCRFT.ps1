Using module  .\TimeInterval.psm1

Clear-Host
#$ConstPath = "C:\Program Files (x86)\Minecraft Launcher\MinecraftLauncher.exe"
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
	if ( $null -eq $curMaskProperty -or $curMaskPropert -eq "")
	{ $curMaskProperty = New-ItemProperty -Path $sCurConf -name Mask -Value "*Minecraft*" }

	return $curMaskProperty.Mask
}

function CheckDoHomework([string]$sCurConf)
{
	$rHWMark = Get-ItemProperty -Path $sCurConf -name DoHomework -ErrorAction silentlycontinue
	if ( $null -eq $rHWMark -or $rHWMark -eq "" )
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
	Remove-ItemProperty -Path $sCurConf -name DoHomework -ErrorAction silentlycontinue
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
	foreach ($rChildPart in Get-ChildItem $rScriptConf | Where-Object { $_.PSChildName -like "PROF_*" })
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
		$iNewName = (Get-ChildItem $rScriptConf | Where-Object { $_.PSChildName -like "PROF_*" }).Count
		$oConf = New-Item -Path ($rScriptConf + "\PROF_" + $iNewName)
		$oConf = "Registry::" + $oConf

		Set-Item -Path $oConf -Value $sProcessPath
		$sFileName = Split-Path $sFullProcessPath -Leaf
		Set-ItemProperty -Path $oConf -Name "fileName" -Value $sFileName
	}

	return $oConf
}

function SetCriptFileName([string]$rProcessConf)
{
	$sNewFileName = -join (((48..57) + (65..90) + (97..122)) * 80 | Get-Random -Count 16 | ForEach-Object { [char]$_ }) + ".txt"
	Set-ItemProperty -Path $rProcessConf -Name "newFileName" -Value $sNewFileName

	return $sNewFileName
}

function GetScriptFileName([string]$rProcessConf)
{
	$sFileName = Get-ItemProperty -Path $rProcessConf -Name "newFileName"

	return $sFileName.newFileName
}

$rScriptConf = GetScriptConf
$sCurMask = GetMask $rScriptConf

$oIntervalConfig = [TimeInterval]::new($rScriptConf);
$retBool = $oIntervalConfig.CheckWorkTime($null);

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
	foreach ($rChildPart in Get-ChildItem $rScriptConf | Where-Object { $_.PSChildName -like "PROF_*" })
	{
		$rChildPart = "Registry::" + $rChildPart
		$sFullProcessPath = (Get-ItemProperty -Path $rChildPart)."(default)"
		$FilePath = Split-Path $sFullProcessPath
		$sCriptFileName = GetScriptFileName $rChildPart
		$SourcePath = $FilePath + '\' + $sCriptFileName
		$FileName = Get-ItemProperty -Path $rChildPart -Name "fileName" 
		Rename-Item -Path $SourcePath -NewName $FileName.fileName

		Remove-Item $rChildPart

		Write-Host $FileName.fileName + " восстановлен"
	}
}

if (-not $retBool)
{
	ClearDoHomework $rScriptConf
}
