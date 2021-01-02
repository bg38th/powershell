Using module  .\TimeInterval.class.psm1

Clear-Host
#$ConstPath = "C:\Program Files (x86)\Minecraft Launcher\MinecraftLauncher.exe"
function GetScriptConf()
{
	if ( (Test-Path -Path Registry::HKEY_CURRENT_USER\Software\BGSoft) )
	{ 
		$rScriptConf = Get-Item -Path Registry::HKEY_CURRENT_USER\Software\BGSoft 
	}
	else 
	{ 
		$rScriptConf = New-Item -Path Registry::HKEY_CURRENT_USER\Software\BGSoft 
	}

	if ( -not (Test-Path -Path Registry::HKEY_CURRENT_USER\Software\BGSoft\TIME)) 
	{ 
		New-Item -Path Registry::HKEY_CURRENT_USER\Software\BGSoft\TIME 
	}

	return "Registry::" + $rScriptConf 

}