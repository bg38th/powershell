Using module  .\TimeInterval.class.psd1
# Using module  .\Registry.class.psd1
Using module  .\SQL.class.psd1
Clear-Host
$oStoreConfig = [StorageConfig]::new();

$SNMP = New-Object -ComObject olePrn.OleSNMP
$SNMP.Open('192.168.98.1', "public", 2, 3000)

$oIntervalConfig = [TimeIntervalProcessor]::new($oStoreConfig);
$bIntervalActive = $oIntervalConfig.CheckWorkTime($null);

$bParentControlTimeStateUp = ($bIntervalActive -and $oStoreConfig.ParentControlSystemIsOn -and -not $oStoreConfig.DoHomeWork);

if ($bParentControlTimeStateUp) {
	#Rule ON
	if ($oStoreConfig.ToggleParentControlTimeState($bParentControlTimeStateUp)) {
		$SNMP.Get(".1.3.6.1.4.1.14988.1.1.18.1.1.2.3")
		Write-Host Parent Control UP
		New-WinEvent -ProviderName 'Microsoft-Windows-PowerShell' -Id 4101 -Payload @('Управление Mikrotik. Parent Control.', '!!! UP !!!', '')
	}
}
else {
	#Rule OFF
	if ($oStoreConfig.ToggleParentControlTimeState($bParentControlTimeStateUp)) {
		$SNMP.Get(".1.3.6.1.4.1.14988.1.1.18.1.1.2.2")
		Write-Host Parent Control DOWN
		New-WinEvent -ProviderName 'Microsoft-Windows-PowerShell' -Id 4100 -Payload @('Управление Mikrotik. Parent Control.', '!!! DOWN !!!', '');
	}
}


if (-not $bIntervalActive) {
	$oStoreConfig.ToggleDoHomework($false);
}