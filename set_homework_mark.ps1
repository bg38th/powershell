function GetScriptConf()
{
	if ( (Test-Path -Path Registry::HKEY_CURRENT_USER\Software\BGSoft) )
	{ $rScriptConf = Get-Item -Path Registry::HKEY_CURRENT_USER\Software\BGSoft }
	else 
	{ $rScriptConf = New-Item -Path Registry::HKEY_CURRENT_USER\Software\BGSoft }

	#return "Registry::" + $rScriptConf 
	return $rScriptConf 

}

function SetHomeworkMark([string]$sCurConf)
{
	# $Server = "ws-lena"
	# $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('CurrentUser', $Server)
	# $RegKey = $Reg.OpenSubKey($sCurConf.Replace("HKEY_CURRENT_USER\", ""))
	# $RegValue = $RegKey.GetValue("DoHomework")
	Set-ItemProperty -Path $sCurConf -name DoHomework -Value 1 -ErrorAction silentlycontinue
}

#$rScriptConf = GetScriptConf
SetHomeworkMark "Software\BGSoft"