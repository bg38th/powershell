Using module  .\TimeInterval.class.psm1
Using module  .\Registry.class.psm1
Clear-Host

$SNMP = New-Object -ComObject olePrn.OleSNMP
$SNMP.Open('192.168.98.1', "public", 2, 3000)

$oRegConfig = [RegistryConfig]::new();

$oIntervalConfig = [TimeIntervalProcessor]::new($oRegConfig);
$bIntervalActive = $oIntervalConfig.CheckWorkTime($null);
# $bIntervalActive = $oIntervalConfig.CheckWorkTime("07.01.2021 21:01");
$bParentControlStateUp = ($bIntervalActive -and -not ($oRegConfig.CheckDoHomework()));
if ($bParentControlStateUp)
{
	#Rule ON
	if ($oRegConfig.ToggleParentControlState($bParentControlStateUp))
	{
		$SNMP.Get(".1.3.6.1.4.1.14988.1.1.18.1.1.2.3")
		Write-Host Parent Control UP
		New-WinEvent -ProviderName 'Microsoft-Windows-PowerShell' -Id 4101 -Payload @('Управление Mikrotik', 'Parent Control', '!!! UP !!!')
	}
}
else
{
	#Rule OFF
	if ($oRegConfig.ToggleParentControlState($bParentControlStateUp))
	{
		$SNMP.Get(".1.3.6.1.4.1.14988.1.1.18.1.1.2.2")
		Write-Host Parent Control DOWN
		New-WinEvent -ProviderName 'Microsoft-Windows-PowerShell' -Id 4100 -Payload @('Управление Mikrotik', 'Parent Control', '!!! DOWN !!!');
	}
}


if (-not $bIntervalActive)
{
	$oRegConfig.ClearDoHomework();
}