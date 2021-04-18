Using module  .\Registry.class.psd1
Using module  .\SQL.class.psd1

class SimpleTimeInterval {
	[string]$start;
	[string]$end;
}

class DayTimeProfile {
	[int]$day;
	[SimpleTimeInterval[]]$times;
}

class TimeIntervalProcessor {
	[DayTimeProfile[]]$Config;

	hidden [string]$DefaultIntervalJSON = '[
   {num: 1, start: "00:00", end: "06:45"},
   {num: 2, start: "08:15", end: "14:10"},
   {num: 3, start: "17:30", end: "19:30"},
   {num: 4, start: "21:30", end: "23:59:59.9999999"},
   {num: 5, start: "22:30", end: "23:59:59.9999999"}
]'

	hidden [string]$constConfigJSON = '[
   {day: 0, times: ["default_1", "default_3", "default_4"]},
   {day: 1, times: ["default_1", "default_2", "default_3", "default_4"]},
   {day: 2, times: ["default_1", {start: "08:15", end: "13:10"},"default_3", "default_4"]},
   {day: 3, times: ["default_1", "default_2", "default_3", "default_4"]},
   {day: 4, times: ["default_1", "default_2", "default_3", "default_4"]},
   {day: 5, times: ["default_1", "default_2", "default_5"]},
   {day: 6, times: ["default_1", "default_5"]}
]'

	[bool]CheckWorkTime($curDayParam) {
		function GetCurConfItem($curDay, $timeConfig) {
			$curConfItem = $timeConfig.where( { $_.day -eq $curDay.DayOfWeek })
			return $curConfItem.times
		}
		
		if ( $null -eq $curDayParam ) {
			$curDay = Get-Date;
		}
		else {
			$curDay = Get-Date -Date $curDayParam;
		}

		$curTime = Get-Date -Date $curDay -Format t

		$curConfItem = GetCurConfItem $curDay $this.Config
		if ($curConfItem.Count -ne 0) {
			$curInterval = $curConfItem.where( { ([datetime]$curTime -ge [datetime]$_.start) -and ([datetime]$curTime -le [datetime]$_.end) })
			if ($curInterval.Count -ne 0) {
				return $true
			}
		}

		return $false
	}
	
	TimeIntervalProcessor([RegistryConfig]$oRegConf) {
		$TimeDefault = $oRegConf.GetTimeConfigJSON("DefaultInterval", $this.DefaultIntervalJSON) | ConvertFrom-Json;
		$TimeConfig = $oRegConf.GetTimeConfigJSON("Config", $this.constConfigJSON) | ConvertFrom-Json;
		foreach ($itemTimeProfile in $TimeConfig) {
			for ($j = 0; $j -lt $itemTimeProfile.times.length ; $j++ ) {
				If ($itemTimeProfile.times[$j].GetType().Name -eq "String" -and $itemTimeProfile.times[$j] -like "default_*") {
					$numStr = $itemTimeProfile.times[$j] -replace "default_", ""
					$num = [convert]::ToInt32($numStr, 10)
					$curDefaultInterval = $TimeDefault.where( { $_.num -eq $num })
					# $itemTimeProfile.times[$j] = @{start = $curDefaultInterval.start; end = $curDefaultInterval.end };
					$itemTimeProfile.times[$j] = '{start: "' + $curDefaultInterval.start + '", end: "' + $curDefaultInterval.end + '"}' | ConvertFrom-Json;
				}
			}
			$this.Config += $itemTimeProfile;
		}
	}
}
   