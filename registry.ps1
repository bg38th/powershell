Clear-Host
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

function GetProcess([string]$sMask)
{
	$PathS = @()
	foreach ($mainItem in Get-Process -Name $sMask )
	{
		$IDs += $mainItem.Id
		$ProcName = $mainItem.MainModule.ModuleName
		$cmdLine = Get-CimInstance Win32_Process -Filter "name = '$ProcName'" | Select-Object CommandLine
		$Name = $cmdLine[0].CommandLine.Replace('"', '')
		if (-not ($Name -in $PathS))
		{
			$PathS += $Name
		}
	}
	return $PathS[0].Replace('"', '').Trim()
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
		$sFilePath = Split-Path $sFullProcessPath
		Set-ItemProperty -Path $oConf -Name "filePath" -Value $sFilePath
	}

	return $oConf
}

function SetFCriptFileName([string]$rProcessConf)
{
	$sNewFileName = -join (((48..57) + (65..90) + (97..122)) * 80 | Get-Random -Count 16 | % { [char]$_ }) + ".txt"
	$sNewFileName = Set-ItemProperty -Path $rProcessConf -Name "newFileName" -Value $sNewFileName

	return $sNewFileName
}

function GetCriptFileName([string]$rProcessConf)
{
	$sFileName = Get-ItemProperty -Path $rProcessConf -Name "newFileName"

	return $sFileName
}

$rScriptConf = GetScriptConf

$sCurMask = GetMask $rScriptConf

$sFullProcessPath = GetProcess $sCurMask

if ($sFullProcessPath -ne $null)
{

	$sFilePath = Split-Path $sFullProcessPath
	#$sFileName = Split-Path $sFullProcessPath -Leaf

	$rProcessConf = GetProcessConf $rScriptConf $sFullProcessPath
	$sNewFileName = SetFCriptFileName $rProcessConf

	Write-Host $sFullProcessPath
}
