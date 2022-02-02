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
					$oBlock = Get-ItemProperty -Path $rScriptConf -Name $block;
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

	[bool]CheckURLBlocklist([string]$Value) {
		return $this.List;
	}

}