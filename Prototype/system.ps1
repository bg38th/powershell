Using module  ..\SystemFunc.class.psd1

#rundll32.exe user32.dll, LockWorkStation
#[SystemFunc]::LockWorkstation()
$xx = [SystemFunc]::GetUsersStates('lena');
Write-Host $xx