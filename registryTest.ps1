$rScriptConf = "Registry::HKEY_CURRENT_USER\Software\BGSoft"

foreach ($rChildPart in Get-ChildItem $rScriptConf | Where-Object { $_.PSChildName -like "PROF_*" })
{
	$rChildPart = "Registry::" + $rChildPart 


}