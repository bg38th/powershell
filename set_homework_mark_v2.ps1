function GetScriptConf($comp)
{
	$HasRegKey = Invoke-Command -ComputerName $comp -ScriptBlock { Test-Path -Path Registry::HKEY_CURRENT_USER\Software\BGSoft }

	if ($HasRegKey) 
	{ 
		$rScriptConf = Invoke-Command -ComputerName $comp -ScriptBlock { Get-Item -Path Registry::HKEY_CURRENT_USER\Software\BGSoft } 
	}
	else 
	{ 
		$rScriptConf = Invoke-Command -ComputerName $comp -ScriptBlock { New-Item -Path Registry::HKEY_CURRENT_USER\Software\BGSoft } 
	}

	#return "Registry::" + $rScriptConf 
	return $rScriptConf 
}
function SetHomeworkMark([string]$sCurConf, $Computer)
{
	$KeyName = "DoHomework"
	$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('CurrentUser', $Computer)
	$RegKey = $Reg.OpenSubKey($sCurConf.Replace("HKEY_CURRENT_USER\", ""), $true)
	#Write-Host $RegKey.GetValue($KeyName)
	$RegKey.SetValue($KeyName, 1, [Microsoft.Win32.RegistryValueKind]::DWORD)
	#Invoke-Command -ComputerName $Computer -ScriptBlock { Set-ItemProperty -Path Registry::HKEY_CURRENT_USER\Software\BGSoft -name DoHomework -Value 1 -ErrorAction silentlycontinue }
}

$RemoteComp = "WS-LENA"
$rScriptConf = GetScriptConf $RemoteComp
SetHomeworkMark $rScriptConf $RemoteComp
