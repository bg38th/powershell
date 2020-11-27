<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>
Unblock-File V:\Projects\GIT\Powershell\powershell\gui.ps1

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form = New-Object system.Windows.Forms.Form
$Form.ClientSize = New-Object System.Drawing.Point(544, 458)
$Form.text = "Настройка PSH"
$Form.TopMost = $false

$mask = New-Object system.Windows.Forms.TextBox
$mask.multiline = $true
$mask.width = 498
$mask.height = 20
$mask.location = New-Object System.Drawing.Point(13, 11)
$mask.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

$d1 = New-Object system.Windows.Forms.CheckBox
$d1.text = "Понедельник"
$d1.AutoSize = $false
$d1.width = 95
$d1.height = 20
$d1.location = New-Object System.Drawing.Point(13, 49)
$d1.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

$d2 = New-Object system.Windows.Forms.CheckBox
$d2.text = "Вторник"
$d2.AutoSize = $false
$d2.width = 95
$d2.height = 20
$d2.location = New-Object System.Drawing.Point(13, 81)
$d2.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

$d3 = New-Object system.Windows.Forms.CheckBox
$d3.text = "Среда"
$d3.AutoSize = $false
$d3.width = 95
$d3.height = 20
$d3.location = New-Object System.Drawing.Point(13, 112)
$d3.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

$d4 = New-Object system.Windows.Forms.CheckBox
$d4.text = "Четверг"
$d4.AutoSize = $false
$d4.width = 95
$d4.height = 20
$d4.location = New-Object System.Drawing.Point(13, 142)
$d4.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

$d5 = New-Object system.Windows.Forms.CheckBox
$d5.text = "Пятница"
$d5.AutoSize = $false
$d5.width = 95
$d5.height = 20
$d5.location = New-Object System.Drawing.Point(13, 174)
$d5.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

$d6 = New-Object system.Windows.Forms.CheckBox
$d6.text = "Суббота"
$d6.AutoSize = $false
$d6.width = 95
$d6.height = 20
$d6.location = New-Object System.Drawing.Point(13, 205)
$d6.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

$d0 = New-Object system.Windows.Forms.CheckBox
$d0.text = "Воскресенье"
$d0.AutoSize = $false
$d0.width = 95
$d0.height = 20
$d0.location = New-Object System.Drawing.Point(13, 238)
$d0.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

$Form.controls.AddRange(@($mask, $d1, $d2, $d3, $d4, $d5, $d6, $d0))

$d1.Add_DoubleClick( { SetTime })
$d2.Add_DoubleClick( { SetTime })
$d3.Add_DoubleClick( { SetTime })
$d4.Add_DoubleClick( { SetTime })
$d5.Add_DoubleClick( { SetTime })
$d6.Add_DoubleClick( { SetTime })
$d7.Add_DoubleClick( { SetTime })

function SetTime 
{
    Write-Host $_
}


#Write your logic code here

[void]$Form.ShowDialog()