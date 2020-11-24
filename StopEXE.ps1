clear
#Get-Process -ComputerName ws-lena
$ConstPath = "C:\Program Files (x86)\Minecraft Launcher\MinecraftLauncher.exe"

$IDs = @()
$NameS = @()
$PathS = @($ConstPath)

foreach ($mainItem in Get-Process -Name *Minecraft* )
{
	$IDs += $mainItem.Id
	$ProcName = $mainItem.MainModule.ModuleName
	if (-not ($ProcName -in $NameS))
	{
		$NameS += $ProcName
		$cmdLine = Get-WmiObject Win32_Process -Filter "name = '$ProcName'" | Select-Object CommandLine
		$PathS += $cmdLine[0].CommandLine.Replace('"', '')
	
	}
}
$IDs_slave = @()
foreach ($itemProc in Get-CimInstance win32_process)
{
	if ($itemProc.ParentProcessId -in $IDs)
	{
		$IDs_slave += $itemProc.ProcessId
	}

}
$IDs += $IDs_slave

foreach ($item in $IDs) 
{
	Stop-Process -ID $item -Force
}

foreach ($FullPath in $PathS)
{
	$FilePath = Split-Path $FullPath
	#$FileName = Split-Path $FullPath -Leaf

	$rndName = -join (((48..57) + (65..90) + (97..122)) * 80 | Get-Random -Count 16 | % { [char]$_ }) + ".txt"
	$ConfFilePath = $FilePath + '\check.cnf'
	$NewFileName = $FilePath + '\' + $rndName
	if (-not (Test-Path $ConfFilePath))
	{
		New-Item -Path $ConfFilePath -ItemType File
	}
	Set-Content $ConfFilePath $rndName -Force
	Rename-Item -Path $FullPath -NewName $rndName
	
}

# { (Get-Process -Name *Minecraft* -id $_.ParentProcessId -ea Ignore) -eq $null } | Write-Host 
