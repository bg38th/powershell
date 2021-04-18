Using module  .\TimeInterval.class.psd1
Using module  .\Registry.class.psd1
Using module  .\SQL.class.psd1
Clear-Host
function GetProcess([string[]]$arrMask) {
	$PathS = @()
	$IDs = @()
	foreach ($sMask in $arrMask) {
		foreach ($mainItem in Get-Process -Name $sMask ) {
			$IDs += $mainItem.Id
			$ProcName = $mainItem.MainModule.ModuleName
			$cmdLine = Get-CimInstance Win32_Process -Filter "name = '$ProcName'" | Select-Object CommandLine
			$Name = $cmdLine[0].CommandLine.Replace('"', '').Trim()
			if (-not ($Name -in $PathS)) {
				$PathS += $Name
			}
		}

		$IDs_slave = @()
		foreach ($itemProc in Get-CimInstance win32_process) {
			if ($itemProc.ParentProcessId -in $IDs) {
				$IDs_slave += $itemProc.ProcessId
			}

		}

		$IDs += $IDs_slave
	}
	return @{PathS = $PathS; IDs = $IDs }
}

function GetProcessConf([RegistryConfig]$oRegConf, [string]$sProcessPath) {
	$oProcessConf = $oRegConf.GetProcessConf($sProcessPath);
	if ($null -ne $oProcessConf) {
		return $oProcessConf
	}

	return $oRegConf.SetProcessConf($sProcessPath);
}

$oStoreConfig = [RegistryConfig]::new();

$oIntervalConfig = [TimeIntervalProcessor]::new($oRegConfig);
$bIntervalActive = $oIntervalConfig.CheckWorkTime($null);
# $bIntervalActive = $oIntervalConfig.CheckWorkTime("07.01.2021 21:01");
$bParentControlUp = ($bIntervalActive -and $oRegConfig.ParentControlSystemIsOn -and -not $oRegConfig.DoHomeWork);

if ($bParentControlUp) {
	$oProcesses = GetProcess $oRegConfig.Masks

	foreach ($item in $oProcesses.IDs) {
		Stop-Process -Id $item -Force
	}

	foreach ($sFullProcessPath in $oProcesses.PathS) {
		$oProcessConf = GetProcessConf $oStoreConfig $sFullProcessPath
		if (Test-Path $sFullProcessPath) {
			$sNewFileName = $oRegConfig.SetMaskFileName($oProcessConf);
			Rename-Item -Path $sFullProcessPath -NewName $sNewFileName
			Write-Host "Move: " $sFullProcessPath
		}
		else {
			Write-Host $sFullProcessPath " не найден"
		}
	}
}
else {
	foreach ($oChildPart in $oRegConfig.ProcessConf ) {
		$FilePath = Split-Path $oChildPart.ProcessPath;
		$SourcePath = $FilePath + '\' + $oChildPart.MaskFileName
		Rename-Item -Path $SourcePath -NewName $oChildPart.NativeFileName

		Write-Host $oChildPart.NativeFileName " восстановлен"

		$oRegConfig.RemoveProcessConf($oChildPart);
	}
}

if (-not $bIntervalActive) {
	$oRegConfig.ToggleDoHomework($false);
}
