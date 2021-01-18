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

class RemoteRegistry
{
	[Microsoft.Win32.RegistryKey]$oRemoteRegistry;

	RemoteRegistry()
	{
		$Computer = [RegistryConfig]::RemoteComp;
		$this.oRemoteRegistry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('CurrentUser', $Computer)
	}

	[void]SetBoolValue([string]$remoteKey, [string]$VarName, [bool]$Value)
	{
		$RegKey = $this.oRemoteRegistry.OpenSubKey($remoteKey.Replace("Registry::", "").Replace("HKEY_CURRENT_USER\", ""), $true)
		$RegKey.SetValue($VarName, $Value, [Microsoft.Win32.RegistryValueKind]::DWORD)
	}
}

class RegistryConfig
{
	hidden [string]$BaseKeyPath = 'Registry::HKEY_CURRENT_USER\Software\BGSoft';
	hidden [string]$BaseMasksJSON = '["*Minecraft*"]';
	
	static [string]$RemoteComp = "WS-LENA";

	[string] $ScriptConf;
	[string] $TimeConf;
	[string[]] $Masks;
	[ProcessConf[]] $ProcessConf;
	[bool]$DoHomeWork;
	[bool]$ParentControlTimeState;
	[bool]$ParentControlSystemIsOn;

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

		function GetHomeWorkMark()
		{
			$DoHomework = Get-ItemProperty -Path $this.ScriptConf -name "DoHomework" -ErrorAction silentlycontinue;
			if ( $null -eq $DoHomework -or $DoHomework -eq "")
			{ $DoHomework = New-ItemProperty -Path $this.ScriptConf-name "DoHomework" -Value 0; }

			return $DoHomework.DoHomework;
		}

		function GetActiveTimeParentControl()
		{
			$ParentControl = Get-ItemProperty -Path $this.TimeConf -name "ParentControlTimeState" -ErrorAction silentlycontinue;
			if ( $null -eq $ParentControl -or $ParentControl -eq "")
			{ $ParentControl = New-ItemProperty -Path $this.TimeConf-name "ParentControlTimeState" -Value 0; }

			return $ParentControl.ParentControlTimeState;
		}
		
		function GetActiveSystemParentControl()
		{
			$ParentControlActive = Get-ItemProperty -Path $this.ScriptConf -name "ParentControlSystemIsOn";
			if ( $null -eq $ParentControlActive -or $ParentControlActive -eq "")
			{ $ParentControlActive = New-ItemProperty -Path $this.ScriptConf-name "ParentControlSystemIsOn" -Value 0; }
			
			return $ParentControlActive.ParentControlSystemIsOn;
		}
		
		$this.ScriptConf = GetScriptConf $this.BaseKeyPath;
		$this.TimeConf = $this.ScriptConf + '\TIME';
		$this.Masks = GetMask;
		$this.DoHomeWork = GetHomeWorkMark;
		$this.ParentControlTimeState = GetActiveTimeParentControl;
		$this.ParentControlSystemIsOn = GetActiveSystemParentControl;

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

	[Bool]GetDoHomework()
	{
		$rHWMark = Get-ItemProperty -Path $this.ScriptConf -name 'DoHomework' -ErrorAction silentlycontinue
		if ( $null -eq $rHWMark -or $rHWMark -eq "" )
		{
			$this.DoHomeWork = $false;
		}
		else
		{
			$this.DoHomeWork = [bool]$rHWMark.DoHomework;
		}

		return $this.DoHomeWork;
	}

	[void]SetDoHomework([bool]$mark)
	{
		$this.DoHomeWork = $mark;
		Set-ItemProperty -Path $this.ScriptConf -Name "DoHomework" -Value $mark;
		$remoteRegistry = [RemoteRegistry]::new();
		$remoteRegistry.SetBoolValue($this.ScriptConf, "DoHomework", $mark);
	}

	[bool]ToggleDoHomework([bool]$NewMark)
	{
		$curMark = $this.GetDoHomework();
		if ($curMark -xor $NewMark)
		{
			$this.SetDoHomework($NewMark);
			return $true;
		}

		return $false;
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
		
	[bool]GetParentControlTimeState()
	{
		$ParentControl = Get-ItemProperty -Path $this.TimeConf -name "ParentControlTimeState";
		if ( $null -eq $ParentControl -or $ParentControl -eq "")
		{
			$this.ParentControlTimeState = $false;
		}
		else
		{
			$this.ParentControlTimeState = $ParentControl.ParentControlTimeState;
		}
		
		return $this.ParentControlTimeState;
	}
	
	[void]SetParentControlTimeState([bool]$state)
	{
		$this.ParentControlTimeState = $state;
		Set-ItemProperty -Path $this.TimeConf -Name "ParentControlTimeState" -Value $state;
	}

	[bool]ToggleParentControlTimeState([bool]$NewState)
	{
		$curState = $this.GetParentControlTimeState();
		if ($curState -xor $NewState)
		{
			$this.SetParentControlTimeState($NewState);
			return $true;
		}

		return $false;
	}

	[bool]GetParentControlSystemActive()
	{
		$ParentControlActive = Get-ItemProperty -Path $this.ScriptConf -name "ParentControlSystemIsOn";
		if ( $null -eq $ParentControlActive -or $ParentControlActive -eq "")
		{
			$this.ParentControlSystemIsOn = $false;
		}
		else
		{
			$this.ParentControlSystemIsOn = $ParentControlActive.ParentControlSystemIsOn;
		}
		
		return $this.ParentControlSystemIsOn;
	}

	[void]SetParentControlSystemActive([bool]$is_on)
	{
		$this.ParentControlSystemIsOn = $is_on;
		Set-ItemProperty -Path $this.ScriptConf -Name "ParentControlSystemIsOn" -Value $is_on;
		$remoteRegistry = [RemoteRegistry]::new();
		$remoteRegistry.SetBoolValue($this.ScriptConf, "ParentControlSystemIsOn", $is_on);
	}

	[bool]ToggleParentControlSystemActive([bool]$NewActiveState)
	{
		$curState = $this.GetParentControlSystemActive();
		if ($curState -xor $NewActiveState)
		{
			$this.SetParentControlSystemActive($NewActiveState);
			return $true;
		}

		return $false;
	}

	[void]ParentControlActiveToOn()
	{
		$this.SetParentControlSystemActive($true);
	}

	[void]ParentControlActiveToOff()
	{
		$this.SetParentControlSystemActive($false);
	}

	static [void]SetRemoteParam()
	{

	}
}