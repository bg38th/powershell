function GetScriptConf()
{
	if ( (Test-Path -Path Registry::HKEY_CURRENT_USER\Software\BGSoft) )
	{ $rScriptConf = Get-Item -Path Registry::HKEY_CURRENT_USER\Software\BGSoft }
	else 
	{ $rScriptConf = New-Item -Path Registry::HKEY_CURRENT_USER\Software\BGSoft }

	return "Registry::" + $rScriptConf 

}

function SetHomeworkMark([string]$sCurConf)
{
	Set-ItemProperty -Path $sCurConf -name DoHomework -Value 1 -ErrorAction silentlycontinue
}

$rScriptConf = GetScriptConf
SetHomeworkMark $rScriptConf