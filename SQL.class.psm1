Using module  .\SystemFunc.class.psd1

class SimpleTimeInterval {
	[string]$start;
	[string]$end;

	SimpleTimeInterval([string]$start, [string]$end) {
		$this.start = $start;
		$this.end = $end;
	}
}

class DayTimeProfile {
	[int]$day;
	[SimpleTimeInterval[]]$times;
}

class UserState {
	[string]$username;
	[bool]$lock;

	UserState([string]$username, [Bool]$lock) {
		$this.username = $username;
		$this.lock = $lock;
	}
}

class ProcessConf {
	[int]$ID;
	[string]$ProcessPath;
	[string]$NativeFileName;
	[string]$MaskFileName;

	ProcessConf([int]$ID, [string]$sProcessPath, [string]$sNativeFileName, [string]$sMaskFileName) {
		$this.ID = $ID;
		$this.ProcessPath = $sProcessPath;
		$this.NativeFileName = $sNativeFileName;
		$this.MaskFileName = $sMaskFileName;
	}

	ProcessConf([int]$ID, [string]$sProcessPath, [string]$sNativeFileName) {
		$this.ID = $ID;
		$this.ProcessPath = $sProcessPath;
		$this.NativeFileName = $sNativeFileName;
	}

	[string]SetMaskFileName() {
		$sNewFileName = -join (((48..57) + (65..90) + (97..122)) * 80 | Get-Random -Count 16 | ForEach-Object { [char]$_ }) + ".txt"
		$this.MaskFileName = $sNewFileName;

		return $sNewFileName;
	}
}

class StorageConfig {
	hidden [string]$type = 'sql';

	hidden [string]$sServerAddr = '192.168.98.247';
	hidden [string]$sServerPort = '3307';
	hidden [string]$sDataBase = 'bgsoft';
	hidden [string]$sUser = 'bgsoft';
	hidden [string]$sPwd = 'KbcnUytd!1';
	hidden [MySql.Data.MySqlClient.MySqlConnection] $SQLConnection;

	hidden [string] $sys_computername = $env:ComputerName;
	hidden [string] $sys_username = $env:UserName;
	hidden [string] $username = "lena";
	hidden [string] $user_id;

	[MySql.Data.MySqlClient.MySqlCommand] $SQLCommand;
	[DayTimeProfile[]]$TimeConfiguration;
	[string[]] $Masks;
	[string[]] $BlockedHosts;
	[ProcessConf[]] $ProcessConf;
	[UserState[]]$users;
	[bool]$DoHomeWork;
	[bool]$ParentControlTimeState;
	[bool]$ParentControlSystemIsOn;

	StorageConfig() {

		function GetConnection($addr, $port, $db, $user, $pswd) {
			$sConnectionString = "server=" + $addr + ";Port=" + $port + ";uid=" + $user + ";pwd=" + $pswd + ";database=" + $db
			return [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString = $sConnectionString }
		}

		function GetSQLCommand($conn) {
			$SQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
			$SQLCommand.Connection = $conn
			$conn.Open()

			return $SQLCommand
		}

		function GetUserID() {
			$this.SQLCommand.CommandText = "select id from users where name = '" + $this.username + "'";
			$RS = $this.SQLCommand.ExecuteReader();
			$iUserID = $null
			if ($RS.Read()) {
				$iUserID = $RS["id"] ;
			}
			$RS.Close()
			return $iUserID
		}

		function GetMask() {
			$this.SQLCommand.CommandText = "select template from masks where active = 1 and user_id = " + $this.user_id;
			$RS = $this.SQLCommand.ExecuteReader();

			$masks = @()
			while ($RS.Read()) {
				$masks += $RS["template"] ;
			}
			$RS.Close()

			return $masks;
		}

		function GetHomeWorkMark() {
			$this.SQLCommand.CommandText = "select value from flags where user_id = " + $this.user_id + " and name = 'homework'";
			$RS_scalar = $this.SQLCommand.ExecuteScalar();
			return [bool]$RS_scalar;
		}

		function GetActiveSystemParentControl() {
			$this.SQLCommand.CommandText = "select value from flags where user_id = " + $this.user_id + " and name = 'parentcontrol'";
			$RS_scalar = $this.SQLCommand.ExecuteScalar();
			return [bool]$RS_scalar;

		}

		function GetActiveTimeParentControl() {
			$this.SQLCommand.CommandText = "select value from flags where user_id = " + $this.user_id + " and name = 'timestate'";
			$RS_scalar = $this.SQLCommand.ExecuteScalar();
			return [bool]$RS_scalar;

		}

		function GetHideProcesses() {
			$this.SQLCommand.CommandText = "select * from hide_programs where user_id = " + $this.user_id + " and ws = '" + $this.sys_computername + "'";
			$RS = $this.SQLCommand.ExecuteReader();
			$HideProc = @()
			while ($RS.Read()) {
				$HideProc += [ProcessConf]::new($RS["id"], $RS["path"], $RS["filename"], $RS["hidename"]); ;
			}
			$RS.Close()

			return $HideProc

		}

		function GetUsersStates() {
			$this.SQLCommand.CommandText = "select * from users";
			$RS = $this.SQLCommand.ExecuteReader();
			$users = @()
			while ($RS.Read()) {
				$username = $RS["name"];
				$real_state = [SystemFunc]::GetUsersStates($username);
				if ($null -eq $real_state) {
					continue;
				}

				$config_lock = $RS["is_lock"];
				if ($config_lock -xor -not $real_state) {
					if ($config_lock) {
						[SystemFunc]::BlockUser($username);
					}
					else {
						[SystemFunc]::UnBlockUser($username);
					}
				}
				$users += [UserState]::new($username, $config_lock); ;
			}
			$RS.Close()

			return $users

		}

		function GetBlockedHosts() {
			$this.SQLCommand.CommandText = "select * from block_hosts where user_id = " + $this.user_id ;
			$RS = $this.SQLCommand.ExecuteReader();
			$BockHosts = @()
			while ($RS.Read()) {
				$BockHosts += $RS["host"] ;
			}
			$RS.Close()

			return $BockHosts
		}

	$this.SQLConnection = GetConnection $this.sServerAddr $this.sServerPort $this.sDataBase $this.sUser $this.sPwd;
	$this.SQLCommand = GetSQLCommand $this.SQLConnection;
	$this.user_id = GetUserID;
	$this.users = GetUsersStates;

	$this.Masks = GetMask;
	$this.DoHomeWork = GetHomeWorkMark;

	$this.ParentControlTimeState = GetActiveTimeParentControl;
	$this.ParentControlSystemIsOn = GetActiveSystemParentControl;
	$this.ProcessConf = GetHideProcesses;
	$this.BlockedHosts = GetBlockedHosts;
	$this.UpdateTimeConfiguration();

}

[string] GetType() {
	return $this.type;
}

[ProcessConf]GetProcessConf([string]$sFullProcessPath) {
	foreach ($ItemProcessConf in $this.ProcessConf) {
		if ($ItemProcessConf.ProcessPath -eq $sFullProcessPath) {
			return $ItemProcessConf;
		}
	}

	return $null;
}

[ProcessConf]SetProcessConf([string]$sFullProcessPath) {
	function GetFromArray($arr, $id) {
		foreach ($elem in $arr) {
			if ($elem.ID -eq $id) {
				return $elem;
			}
		}
		return $null;
	}

	$sFileName = Split-Path $sFullProcessPath -Leaf

	$this.SQLCommand.CommandText = "select set_hide_program(" + $this.user_id + ", '" + $this.sys_computername + "', '" + ($sFullProcessPath -replace "\\", "\\\\") + "', '" + $sFileName + "')";
	$num = $this.SQLCommand.ExecuteScalar();

	$oProcessConf = [ProcessConf]::new($num, $sFullProcessPath, $sFileName);
	$curProcessConf = GetFromArray $this.ProcessConf $num
	if ($null -eq $curProcessConf) {
		$this.ProcessConf += $oProcessConf;
		return $oProcessConf;
	}
	else {
		return $curProcessConf;
	}

}
	
[string]SetMaskFileName([ProcessConf]$oProcessConf) {
	$sNewFileName = $oProcessConf.SetMaskFileName()
	$oProcessConf.MaskFileName = $sNewFileName;
		
	$this.SQLCommand.CommandText = "UPDATE hide_programs SET hidename = '" + $sNewFileName + "' where id = " + $oProcessConf.ID;
	$this.SQLCommand.ExecuteNonQuery();

	return $sNewFileName;
}

[void]RemoveProcessConf([ProcessConf]$ProcessConf) {
		
	$ID = $ProcessConf.ID;
	$this.SQLCommand.CommandText = "DELETE FROM hide_programs where id = " + $ID;
	$this.SQLCommand.ExecuteNonQuery();

	$this.ProcessConf = $this.ProcessConf | Where-Object { $_.ID -ne $ID }
}

[Bool]GetDoHomework() {
	$this.SQLCommand.CommandText = "select value from flags where user_id = " + $this.user_id + " and name = 'homework'";
	$RS_scalar = $this.SQLCommand.ExecuteScalar();
	$this.DoHomeWork = [bool]$RS_scalar;
	return $this.DoHomeWork;
}

[bool]SetDoHomework([bool]$mark) {
	$this.DoHomeWork = $mark;
	if ($mark) { $mark_sql = 1 }else { $mark_sql = 0 }
	$this.SQLCommand.CommandText = "UPDATE flags SET value = '" + $mark_sql + "' where user_id = " + $this.user_id + " and name = 'homework'";
	return $this.SQLCommand.ExecuteNonQuery();
}

[bool]ToggleDoHomework([bool]$NewMark) {
	$curMark = $this.GetDoHomework();
	if ($curMark -xor $NewMark) {
		$this.SetDoHomework($NewMark);
		return $true;
	}

	return $false;
}

[bool]GetParentControlTimeState() {
	$this.SQLCommand.CommandText = "select value from flags where user_id = " + $this.user_id + " and name = 'timestate'";
	$RS_scalar = $this.SQLCommand.ExecuteScalar();
	$this.ParentControlTimeState = [bool]$RS_scalar;
		
	return $this.ParentControlTimeState;
}
	
[bool]SetParentControlTimeState([bool]$state) {
	$this.ParentControlTimeState = $state;
	if ($state) { $state_sql = 1 }else { $state_sql = 0 }
	$this.SQLCommand.CommandText = "UPDATE flags SET value = '" + $state_sql + "' where user_id = " + $this.user_id + " and name = 'timestate'";
	return $this.SQLCommand.ExecuteNonQuery();
}

[bool]ToggleParentControlTimeState([bool]$NewState) {
	$curState = $this.GetParentControlTimeState();
	if ($curState -xor $NewState) {
		$this.SetParentControlTimeState($NewState);
		return $true;
	}

	return $false;
}

[void]UpdateTimeConfiguration() {
	$this.SQLCommand.CommandText = "select d.id day_id from days d order by d.id";
	$DayRS = $this.SQLCommand.ExecuteReader();
	$day_ids = @();
	while ($DayRS.Read()) {
		$day_ids += $DayRS["day_id"];
	}
	$DayRS.Close();
		
	foreach ($day_id in $day_ids) {
		$cutDayProfile = [DayTimeProfile]::new();
		$cutDayProfile.day = $day_id;
		$this.SQLCommand.CommandText = "
SELECT
	t.interval_id
    ,CONCAT(lpad(i.start_hour, 2, 0), ':', lpad(i.start_minute, 2, 0)) as start
    ,CONCAT(lpad(i.end_hour, 2, 0), ':', lpad(i.end_minute, 2, 0)) as end
FROM
	timeline t
		join intervals i on t.interval_id = i.id
where
	1=1
	and t.user_id = " + $this.user_id + "
	and t.day_id = " + $day_id + "
ORDER BY
	t.day_id
	,i.start_hour
	,i.start_minute
";
		$IntervalRS = $this.SQLCommand.ExecuteReader();
		while ($IntervalRS.Read()) {
			$cutDayProfile.times += [SimpleTimeInterval]::new($IntervalRS["start"], $IntervalRS["end"])
		}
		$IntervalRS.Close();

		$this.TimeConfiguration += $cutDayProfile;
	}
}

[DayTimeProfile[]]GetTimeConfiguration() {
	return $this.TimeConfiguration;
}

}