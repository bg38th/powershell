$constConfig = @(
	@{day = 1; times = @{start = "08:15"; end = "14:10" }, @{start = "16:00"; end = "17:00" } },
	@{day = 2; times = @{start = "08:15"; end = "13:10" }, @{start = "16:00"; end = "17:00" } },
	@{day = 3; times = @{start = "08:15"; end = "14:10" }, @{start = "16:00"; end = "17:00" } },
	@{day = 4; times = @{start = "08:15"; end = "14:10" }, @{start = "16:00"; end = "17:00" } },
	@{day = 5; times = @{start = "08:15"; end = "14:10" }, @{start = "16:00"; end = "17:00" } }
)

$curDay = Get-Date -Date "23.11.2020 17:01"
$curTime = Get-Date -Date $curDay -Format t

$curConfItem = $constConfig.where( { $_.day -eq $curDay.DayOfWeek })
$retBool = $false
if ($curConfItem.Count -ne 0)
{
	$curInterval = $curConfItem.times.where( { ($curTime -ge $_.start) -and ($curTime -le $_.end) })
	if ($curInterval.Count -ne 0)
	{
		$retBool = $true
	}
}

if ($retBool)
{
	Write-Host $curDay $curTime
}
