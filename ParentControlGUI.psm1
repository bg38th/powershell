Using module  .\Registry.class.psm1

@{
    ModuleVersion          = "1.0.0.0"
    Author                 = "Boris Gordon"
    PowerShellVersion      = "7.0"
    DotNetFrameworkVersion = "4.0"
    GUID                   = 'ed77f60a-eabb-4a86-bed9-acaa5ce28abe'
    CompanyName            = 'BGSoft'
    Copyright              = '(c) BGSoft. All rights reserved.'
    # Description = ''
    # PowerShellHostName = ''
    PowerShellHostVersion  = '7.0'
    FunctionsToExport      = @(
        'Show'
        , 'doCheckBox'
    )
    VariablesToExport      = '*'
}

Add-Type -AssemblyName System.Windows.Forms;
[System.Windows.Forms.Application]::EnableVisualStyles();
class ParentControlGUI : System.Windows.Forms.Form
{
    ParentControlGUI()
    {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Application]::EnableVisualStyles()

        $this.ClientSize = New-Object System.Drawing.Point(200, 200)
        $this.text = "Управление ParentControl"
        $this.TopMost = $false

        $cbDoHomeWork = New-Object system.Windows.Forms.CheckBox
        $cbDoHomeWork.text = "Задания выполнены"
        $cbDoHomeWork.AutoSize = $true
        $cbDoHomeWork.width = 195
        $cbDoHomeWork.height = 20
        $cbDoHomeWork.location = New-Object System.Drawing.Point(13, 49)
        $cbDoHomeWork.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

        $cbDisableParentControl = New-Object system.Windows.Forms.CheckBox
        $cbDisableParentControl.text = "Отключить ParentControl"
        $cbDisableParentControl.AutoSize = $true
        $cbDisableParentControl.width = 195
        $cbDisableParentControl.height = 20
        $cbDisableParentControl.location = New-Object System.Drawing.Point(13, 81)
        $cbDisableParentControl.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

        $this.Controls.AddRange(@($cbDoHomeWork, $cbDisableParentControl))

        $cbDoHomeWork.Add_Click( $this.doCheckBox($cbDoHomeWork));
        $cbDisableParentControl.Add_Click( $this.doCheckBox($cbDisableParentControl));
    }

    [void]Show()
    {
        [void]$this.Form.ShowDialog()
    }

    [void]doCheckBox($curCheckBox)
    {
        $oThis = $curCheckBox;
        Write-Host $curCheckBox.Text ---> $curCheckBox.CheckState ---> $curCheckBox.Checked;
    }
}