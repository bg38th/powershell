Using module  ..\SQL.class.psd1
Clear-Host
$oStoreConfig = [StorageConfig]::new();

$gettime = $oStoreConfig.GetTimeConfiguration();

Write-Host $gettime