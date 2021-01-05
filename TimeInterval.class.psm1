Using module  .\Registry.class.psm1

@{
	ModuleVersion          = "1.0.0.0"
	Author                 = "Boris Gordon"
	Copyright              = "38th.ru"
	PowerShellVersion      = "7.0"
	DotNetFrameworkVersion = "4.0"
	FunctionsToExport      = "CheckWorkTime"
}

class TimeInterval
{
	$Config

	hidden [string]$DefaultIntervalJSON = '[
   {num: 1, start: "00:00", end: "06:45"},
   {num: 2, start: "08:15", end: "14:10"},
   {num: 3, start: "19:00", end: "21:00"},
   {num: 4, start: "21:30", end: "23:59:59.9999999"},
   {num: 5, start: "22:30", end: "23:59:59.9999999"}
]'

	hidden [string]$constConfigJSON = '[
   {day: 0, times: ["default_1", "default_3", "default_4"]},
   {day: 1, times: ["default_1", "default_2", "default_3", "default_4"]},
   {day: 2, times: ["default_1", {start: "08:15", end: "14:10"},"default_3", "default_4"]},
   {day: 3, times: ["default_1", "default_2", "default_3", "default_4"]},
   {day: 4, times: ["default_1", "default_2", "default_3", "default_4"]},
   {day: 5, times: ["default_1", "default_2", "default_5"]},
   {day: 6, times: ["default_1", "default_5"]}
]'

	[bool]CheckWorkTime($curDayParam)
	{
		function GetCurConfItem($curDay, $timeConfig)
		{
			$curConfItem = $timeConfig.where( { $_.day -eq $curDay.DayOfWeek })
			return $curConfItem.times
		}
		
		if ( $null -eq $curDayParam )
		{
			$curDay = Get-Date;
		}
		else
		{
			$curDay = Get-Date -Date $curDayParam;
		}

		$curTime = Get-Date -Date $curDay -Format t

		$curConfItem = GetCurConfItem $curDay $this.Config
		if ($curConfItem.Count -ne 0)
		{
			$curInterval = $curConfItem.where( { ([datetime]$curTime -ge [datetime]$_.start) -and ([datetime]$curTime -le [datetime]$_.end) })
			if ($curInterval.Count -ne 0)
			{
				return $true
			}
		}

		return $false
	}
	
	TimeInterval([string]$sCurConf)
	{
		function GetRegistryJSON([string]$sCurConf, [string]$Var, [string]$Default)
		{
			[string]$TimePath = $sCurConf + "\TIME"
			$VarJSON = Get-ItemProperty -Path $TimePath -name $Var -ErrorAction silentlycontinue
			if ( $null -eq $VarJSON -or $VarJSON -eq "")
			{ $VarJSON = New-ItemProperty -Path $TimePath -name $Var -PropertyType MultiString -Value $Default }
		
			[string]$sRet = $VarJSON | Get-ItemPropertyValue -name $Var;
			return $sRet
		}
		
		$TimeDefault = GetRegistryJSON $sCurConf "DefaultInterval" $this.DefaultIntervalJSON  | ConvertFrom-Json;
		$this.Config = GetRegistryJSON $sCurConf "Config" $this.constConfigJSON | ConvertFrom-Json;
		for ($i = 0; $i -lt $this.Config.length ; $i++)
		{
			for ($j = 0; $j -lt $this.Config[$i].times.length ; $j++ )
			{
				If ($this.Config[$i].times[$j].GetType().Name -eq "String" -and $this.Config[$i].times[$j] -like "default_*")
				{
					$numStr = $this.Config[$i].times[$j] -replace "default_", ""
					$num = [convert]::ToInt32($numStr, 10)
					$curDefaultInterval = $TimeDefault.where( { $_.num -eq $num })
					# $this.Config[$i].times[$j] = @{start = $curDefaultInterval.start; end = $curDefaultInterval.end };
					$this.Config[$i].times[$j] = '{start: "' + $curDefaultInterval.start + '", end: "' + $curDefaultInterval.end + '"}' | ConvertFrom-Json;
				}
			}
		}
	}
}
   