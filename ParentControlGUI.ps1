Using module  .\ParentControlGUI.psd1
Clear-Host

$ParentControlGUI = [ParentControlGUI]::new();
$ParentControlGUI.Add_Shown( { $ParentControlGUI.Activate() })
$ParentControlGUI.showDialog()
Write-Host Stop ParentControl Interface!!