Clear-Host

$ProviderName = 'Microsoft-Windows-PowerShell'

$ID = 4100
$ContextInfo = 'ContextInfo'
$UserData = 'UserData'
$Payload = 'Payload'

New-WinEvent -ProviderName $ProviderName -Id $ID  -Payload @($ContextInfo, $UserData, $Payload)


