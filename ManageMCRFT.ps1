Clear-Host
#$ConstPath = "C:\Program Files (x86)\Minecraft Launcher\MinecraftLauncher.exe"
class TimeIntervalConfig
{
	$Config

	hidden [string]$DefaultIntervalJSON = '[
   {num: 1, start: "00:00", end: "06:45"},
   {num: 2, start: "00:15", end: "14:10"},
   {num: 3, start: "19:00", end: "21:00"},
   {num: 4, start: "22:00", end: "24:00"}
]'
	hidden [string]$constConfigJSON = '[
   {day: 0, times: ["default_3"]},
   {day: 1, times: ["default_2", "default_3"]},
   {day: 2, times: [{start: "00:00", end: "06:45"},"default_3"]},
   {day: 3, times: ["default_2", "default_3"]},
   {day: 4, times: ["default_2", "default_3"]},
   {day: 5, times: ["default_2"]}
]'

	<#
 	[string] GetDefaultRegistryJSON([string]$sCurConf)
	{
		[string]$TimeConfigPath = $sCurConf + + "\TIME"
		[string]$DefaultJSON = Get-ItemProperty -Path $TimeConfigPath -name DefaultInterval -ErrorAction silentlycontinue
		if ( $null -eq $DefaultJSON)
		{ $DefaultJSON = New-ItemProperty -Path $TimeConfigPath -name DefaultInterval -Value $this.DefaultIntervalJSON }
	
		return $DefaultJSON.DefaultInterval
	}
	
	[string] GetConfigRegistryJSON([string]$sCurConf)
	{
		[string]$TimeConfigPath = $sCurConf + + "\TIME"
		[string]$ConfigJSON = Get-ItemProperty -Path $TimeConfigPath -name Config -ErrorAction silentlycontinue
		if ( $null -eq $ConfigJSON)
		{ $ConfigJSON = New-ItemProperty -Path $TimeConfigPath -name Config -Value $this.constConfigJSON }
	
		return $ConfigJSON.Config
	}
 #>
	TimeIntervalConfig([string]$sCurConf)
	{
		function GetRegistryJSON([string]$sCurConf, [string]$Var, [string]$Default)
		{
			[string]$TimePath = $sCurConf + "\TIME"
			$VarJSON = Get-ItemProperty -Path $TimePath -name $Var -ErrorAction silentlycontinue
			if ( $null -eq $VarJSON -or $VarJSON -eq "")
			{ $VarJSON = New-ItemProperty -Path $TimePath -name $Var -PropertyType MultiString -Value $Default }
		
			[string]$sRet = $VarJSON | Get-ItemPropertyValue -name $Var;
			return $sRet
		}
		
		$TimeDefault = GetRegistryJSON $sCurConf "DefaultInterval" $this.DefaultIntervalJSON  | ConvertFrom-Json;
		$this.Config = GetRegistryJSON $sCurConf "Config" $this.constConfigJSON | ConvertFrom-Json;
		for ($i = 0; $i -lt $this.Config.length ; $i++)
		{
			for ($j = 0; $j -lt $this.Config[$i].times.length ; $j++ )
			{
				If ($this.Config[$i].times[$j].GetType().Name -eq "String" -and $this.Config[$i].times[$j] -like "default_*")
				{
					$numStr = $this.Config[$i].times[$j] -replace "default_", ""
					$num = [convert]::ToInt32($numStr, 10)
					$curDefaultInterval = $TimeDefault.where( { $_.num -eq $num })
					# $this.Config[$i].times[$j] = @{start = $curDefaultInterval.start; end = $curDefaultInterval.end };
					$curTime = '{start: ' + $curDefaultInterval.start + ', end: ' + $curDefaultInterval.end + '}';
					$this.Config[$i].times[$j] = $curTime | ConvertFrom-Json;
				}
			}
		}
	}
}

function CheckWorkTime($timeConfig)
{
	$curDay = Get-Date #-Date "16.12.2020 19:01"
	$curTime = Get-Date -Date $curDay -Format t

	$curConfItem = GetCurConfItem $curDay $timeConfig
	if ($curConfItem.Count -ne 0)
	{
		$curInterval = $curConfItem.where( { ($curTime -ge $_.start) -and ($curTime -le $_.end) })
		if ($curInterval.Count -ne 0)
		{
			return $true
		}
	}

	return $false
}

function GetCurConfItem($curDay, $timeConfig)
{
	$curConfItem = $constConfig.where( { $_.day -eq $curDay.DayOfWeek })
	return $curConfItem.times
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
	$sNewFileName = -join (((48..57) + (65..90) + (97..122)) * 80 | Get-Random -Count 16 | % { [char]$_ }) + ".txt"
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

$oIntervalConfig = [TimeIntervalConfig]::new($rScriptConf);
$intervalConfig = $oIntervalConfig.Config;

$retBool = CheckWorkTime $intervalConfig 

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
		$res = Rename-Item -Path $SourcePath -NewName $FileName.fileName

		Remove-Item $rChildPart

		Write-Host $FileName.fileName + " восстановлен"
	}
}

if (-not $retBool)
{
	ClearDoHomework $rScriptConf
}
