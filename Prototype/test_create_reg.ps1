$BaseKey = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\URLBlocklist'
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

$rScriptConf = 'Registry::' + $rScriptConf;

$Blocks = Get-Item -Path $rScriptConf -ErrorAction silentlycontinue;
if ( $null -ne $Blocks -and $Blocks -ne "") {
	foreach ($block in $Blocks.Property) {
		$oBlock = Get-ItemProperty -Path $rScriptConf -Name $block;
		$Value = $oBlock | Select-Object -ExpandProperty $block;
		Write-Host $Value
	}
}

