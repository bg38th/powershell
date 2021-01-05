@{
	ModuleVersion          = "1.0.0.0"
	Author                 = "Boris Gordon"
	Copyright              = "38th.ru"
	PowerShellVersion      = "7.0"
	DotNetFrameworkVersion = "4.0"
	GUID                   = '2dc64c35-9152-413a-ba22-ca11837a041d'
	FunctionsToExport      = @("CheckDoHomework", "ClearDoHomework")
}

class RegistryConfig
{
	hidden [string]$BaseKeyPath = 'Registry::HKEY_CURRENT_USER\Software\BGSoft';
	
	[string] $ScriptConf;
	[string] $Mask;
	[Object[]] $ProcessConf;
	[bool] $HasProcessConf;

	RegistryConfig()
	{
		function GetScriptConf([string]$BaseKey)
		{
			$bHasMainKey = Test-Path -Path $BaseKey;
			$sTimeKey = $BaseKey + '\TIME';
			$bHasTimeKey = Test-Path -Path $sTimeKey;

			if ( $bHasMainKey )
			{ 
				$rScriptConf = Get-Item -Path $BaseKey 
			}
			else 
			{ 
				$rScriptConf = New-Item -Path $BaseKey 
			}

			if ( -not ($bHasTimeKey)) 
			{ 
				New-Item -Path $sTimeKey
			}

			return "Registry::" + $rScriptConf 
		}

		function GetMask()
		{
			$curMaskProperty = Get-ItemProperty -Path $this.ScriptConf -name Mask -ErrorAction silentlycontinue
			if ( $null -eq $curMaskProperty -or $curMaskPropert -eq "")
			{ $curMaskProperty = New-ItemProperty -Path $this.ScriptConf-name Mask -Value "*Minecraft*" }
		
			return $curMaskProperty.Mask
		}
		
		$this.ScriptConf = GetScriptConf $this.BaseKeyPath
		$this.Mask = GetMask
	
		$this.HasProcessConf = $false;
		foreach ($rChildPart in Get-ChildItem $this.ScriptConf | Where-Object { $_.PSChildName -like "PROF_*" })
		{
			$this.ProcessConf += @{sPath = "Registry::" + $rChildPart };
			$this.HasProcessConf = $true
		}
	}

	[Boolean]CheckDoHomework()
	{
		$rHWMark = Get-ItemProperty -Path $this.ScriptConf -name DoHomework -ErrorAction silentlycontinue
		if ( $null -eq $rHWMark -or $rHWMark -eq "" )
		{
			return 0
		}
		else
		{
			return $rHWMark.DoHomework
		}
	}

	[void]ClearDoHomework()
	{
		Remove-ItemProperty -Path $this.ScriptConf -name DoHomework -ErrorAction silentlycontinue
	}

}