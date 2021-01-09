@{
	ModuleVersion          = "1.0.0.0"
	Author                 = "Boris Gordon"
	Copyright              = "38th.ru"
	PowerShellVersion      = "7.0"
	DotNetFrameworkVersion = "4.0"
	GUID                   = '2dc64c35-9152-413a-ba22-ca11837a041d'
	FunctionsToExport      = @(
		"CheckDoHomework"
		, "ClearDoHomework"
		, "GetProcessConf"
		, "SetProcessConf"
		, "SetMaskFileName"
		, "RemoveProcessConf"
		, "GetTimeConfigJSON"
		, "GetParentControlState"
		, "SetParentControlState"
		, "ToggleParentControlState"
	)
}

class ProcessConf
{
	[string]$ConfPath;
	[string]$ProcessPath;
	[string]$NativeFileName;
	[string]$MaskFileName

	ProcessConf([string]$sConfPath, [string]$sProcessPath, [string]$sNativeFileName, [string]$sMaskFileName)
	{
		$this.ConfPath = $sConfPath;
		$this.ProcessPath = $sProcessPath;
		$this.NativeFileName = $sNativeFileName;
		$this.MaskFileName = $sMaskFileName;
	}

	ProcessConf([string]$sConfPath, [string]$sProcessPath, [string]$sNativeFileName)
	{
		$this.ConfPath = $sConfPath;
		$this.ProcessPath = $sProcessPath;
		$this.NativeFileName = $sNativeFileName;
	}

	[string]SetMaskFileName()
	{
		$sNewFileName = -join (((48..57) + (65..90) + (97..122)) * 80 | Get-Random -Count 16 | ForEach-Object { [char]$_ }) + ".txt"
		$this.MaskFileName = $sNewFileName;

		return $sNewFileName;
	}
}

class RegistryConfig
{
	hidden [string]$BaseKeyPath = 'Registry::HKEY_CURRENT_USER\Software\BGSoft';
	hidden [string]$BaseMasksJSON = '["*Minecraft*"]';
	
	[string] $ScriptConf;
	[string] $TimeConf;
	[string[]] $Masks;
	[ProcessConf[]] $ProcessConf;
	[bool]$ParentControlState;

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
			$curMaskProperty = Get-ItemProperty -Path $this.ScriptConf -name "Masks" -ErrorAction silentlycontinue;

			if ( $null -eq $curMaskProperty -or $curMaskProperty -eq "")
			{ $curMaskProperty = New-ItemProperty -Path $this.ScriptConf-name "Masks" -Value $this.BaseMasksJSON; }
			
			if ($curMaskProperty.Masks -eq "")
			{ 
				Set-ItemProperty -Path $this.ScriptConf -Name "Masks" -Value $this.BaseMasksJSON; 
				return $this.BaseMasksJSON | ConvertFrom-Json;
			}

			return $curMaskProperty.Masks | ConvertFrom-Json;
		}

		function GetActiveParentControl()
		{
			$ParentControl = Get-ItemProperty -Path $this.TimeConf -name "ParentControlState" -ErrorAction silentlycontinue;
			if ( $null -eq $ParentControl -or $ParentControl -eq "")
			{ $ParentControl = New-ItemProperty -Path $this.TimeConf-name "ParentControlState" -Value 0; }

			return $ParentControl.ParentControlState;
		}
		
		$this.ScriptConf = GetScriptConf $this.BaseKeyPath;
		$this.TimeConf = $this.ScriptConf + '\TIME';
		$this.Masks = GetMask;
		$this.ParentControlState = GetActiveParentControl;

		foreach ($rChildPart in Get-ChildItem $this.ScriptConf | Where-Object { $_.PSChildName -like "PROF_*" })
		{
			$rChildPart = "Registry::" + $rChildPart.Name;
			$curKeyChildProcess = Get-ItemProperty -Path $rChildPart;
			$ChildProcessPath = $curKeyChildProcess."(default)";
			$sNativeFileName = [string]$curKeyChildProcess."fileName";
			$sMaskFileName = [string]$curKeyChildProcess."newFileName";
			$this.ProcessConf += [ProcessConf]::new($rChildPart, $ChildProcessPath, $sNativeFileName, $sMaskFileName);
		}
	}

	[ProcessConf]GetProcessConf([string]$sFullProcessPath)
	{
		foreach ($ItemProcessConf in $this.ProcessConf)
		{
			if ($ItemProcessConf.ProcessPath -eq $sFullProcessPath)
			{
				return $ItemProcessConf;
			}
		}

		return $null;
	}
	
	[ProcessConf]SetProcessConf([string]$sFullProcessPath)
	{
		$iNewCofNumber = $this.ProcessConf.Count;
		$sNewProctssConfPath = $this.ScriptConf + "\PROF_" + $iNewCofNumber;
		$sFileName = Split-Path $sFullProcessPath -Leaf
		New-Item -Path $sNewProctssConfPath;
		Set-Item -Path $sNewProctssConfPath -Value $sFullProcessPath
		Set-ItemProperty -Path $sNewProctssConfPath -Name "fileName" -Value $sFileName
		$oProcessConf = [ProcessConf]::new($sNewProctssConfPath, $sFullProcessPath, $sFileName);
		$this.ProcessConf += $oProcessConf;

		return $oProcessConf
	}

	[string]SetMaskFileName([ProcessConf]$oProcessConf)
	{
		$sNewFileName = $oProcessConf.SetMaskFileName()
		Set-ItemProperty -Path $oProcessConf.ConfPath -Name "newFileName" -Value $sNewFileName

		return $sNewFileName;
	}

	[void]RemoveProcessConf([ProcessConf]$ProcessConf)
	{
		
		$curConfPath = $ProcessConf.ConfPath;
		$this.ProcessConf = $this.ProcessConf | Where-Object { $curConfPath -notcontains $_.ConfPath };
		Remove-Item $curConfPath;
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

	[string]GetTimeConfigJSON([string]$VarName, [string]$Default)
	{
		$VarJSON = Get-ItemProperty -Path $this.TimeConf -name $VarName -ErrorAction silentlycontinue
		if ( $null -eq $VarJSON -or $VarJSON -eq "")
		{ $VarJSON = New-ItemProperty -Path $this.TimeConf -name $VarName -PropertyType MultiString -Value $Default }
	
		[string]$sRet = $VarJSON | Get-ItemPropertyValue -name $VarName;
		return $sRet
	}
	
	[bool]GetParentControlState()
	{
		$ParentControl = Get-ItemProperty -Path $this.TimeConf -name "ParentControlState";
		if ( $null -eq $ParentControl -or $ParentControl -eq "")
		{
			$this.ParentControlState = $false;
		}
		else
		{
			$this.ParentControlState = $ParentControl.ParentControlState;
		}
		
		return $this.ParentControlState;
	}
	
	[void]SetParentControlState([bool]$state)
	{
		$this.ParentControlState = $state;
		Set-ItemProperty -Path $this.TimeConf -Name "ParentControlState" -Value $state;
	}

	[bool]ToggleParentControlState([bool]$NewState)
	{
		$curState = $this.GetParentControlState();
		if ($curState -xor $NewState)
		{
			$this.SetParentControlState($NewState);
			return $true;
		}

		return $false;
	}

}