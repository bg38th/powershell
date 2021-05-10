class SystemFunc {
	static LockWorkstation() {
		rundll32.exe user32.dll, LockWorkStation;
	}

	static BlockUser($username) {
		Disable-LocalUser -Name $username 
	}

	static UnBlockUser($username) {
		Enable-LocalUser -Name $username 
	}

	static [bool]GetUsersStates($username) {
		
		try {
			Get-LocalUser $username -ErrorAction Stop | Out-Null;
			$SysUser = Get-LocalUser -Name $username;
			return $SysUser.enabled;
		}
		catch {
			return $false;
		}
	}
}