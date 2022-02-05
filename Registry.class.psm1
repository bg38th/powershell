Using module  .\SQL.class.psd1
class URLBlock {
	[string]$key;
	[string]$rule;

	URLBlock([string]$key, [string]$rule) {
		$this.key = $key;
		$this.rule = $rule;
	}
}
class URLBlocklist {

	hidden [string]$BaseKeyPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\URLBlocklist';
	hidden [string[]]$arrHosts = @('youtube.com', 'youtube.ru');

	[URLBlock[]]$List;
	[string] $curPath;

	URLBlocklist() {
		function GetScriptConf([string]$BaseKey) {
			$bHasMainKey = Test-Path -Path $BaseKey;
			
			if ( $bHasMainKey ) { 
				$rScriptConf = Get-Item -Path $BaseKey 
			}
			else { 
				$arrPath = $BaseKey.Split("\");
				for ($i = 1; $i -lt $arrPath.Length; $i++) {
					$curKey = $arrPath[0..$i] -join "\";
					if ( -not (Test-Path -Path $curKey) ) {
						$rScriptConf = New-Item -Path $curKey;
					}
				}
			}

			return "Registry::" + $rScriptConf;
		}

		function GetBlockList() {
			$Blocks = Get-Item -Path $this.curPath -ErrorAction silentlycontinue;
			$curList = [System.Collections.ArrayList]::new();
			if ( $null -ne $Blocks -and $Blocks -ne "") {
				foreach ($block in $Blocks.Property) {
					$oBlock = Get-ItemProperty -Path $this.curPath -Name $block;
					$Value = $oBlock | Select-Object -ExpandProperty $block;
					[void]$curList.Add([URLBlock]::new($block, $Value));
				}
			}

			return $curList.ToArray();
		}

		$this.curPath = GetScriptConf $this.BaseKeyPath;
		$this.List = GetBlockList ;
	}

	[URLBlock[]]GetURLBlocklist() {
		return $this.List;
	}

	[bool]CheckURLBlocklist([StorageConfig]$oStoreConf) {
		# foreach ($sHost in $this.arrHosts) {
		foreach ($sHost in $oStoreConf.BlockedHosts) {
			$bThisHostHas = $false;
			foreach ($block in $this.List) {
				if ($sHost -eq $block.rule) {
					$bThisHostHas = $true;
					break;
				}
			}

			if (-not $bThisHostHas) {
				return $false;
			}
		}
		return $true;
	}

	[void]SetURLBlocklist([StorageConfig]$oStoreConf) {
		if ($this.List.length -ne 0) {
			$newArr = [System.Collections.ArrayList]::new($this.List);
			$MaxElem = $newArr | Measure-Object -Property key -Maximum;
			$iNewNum = $MaxElem.Maximum;
		}
		else {
			$newArr = [System.Collections.ArrayList]::new();
			$iNewNum = 0;
		}
		[string[]]$rules = $this.List | ForEach-Object { $PSItem.rule };
		[string[]]$ResArray = $oStoreConf.BlockedHosts | ? { $rules -notcontains $_ }
		foreach ($sHost in $ResArray) {
			$iNewNum++;
			[void]$newArr.Add([URLBlock]::new($iNewNum.ToString(), $sHost));
			Set-ItemProperty -Path $this.curPath -Name $iNewNum.ToString() -Value $sHost;
		}
		Get-Process -Name Chrome -ErrorAction Ignore -WarningAction Ignore | Stop-Process -Force | Clear-DnsClientCache 
	}

	[void]ClearURLBlocklist() {
		foreach ($block in $this.List) {
			Remove-ItemProperty -Path $this.curPath -Name $block.key -ErrorAction silentlycontinue
		}
		$this.List = @();
		Get-Process -Name Chrome -ErrorAction Ignore -WarningAction Ignore | Stop-Process -Force | Clear-DnsClientCache 
	}

}