Using module  ..\ParentControlGUI.psm1
Add-Type -AssemblyName System.Windows.Forms

Clear-Host

$ParentControlGUI = [ParentControlGUI]::new();
$ParentControlGUI.Add_Shown( { $ParentControlGUI.Activate() })
$ParentControlGUI.showDialog()

Write-Host End!!