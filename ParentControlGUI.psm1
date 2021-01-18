Using module  .\Registry.class.psd1

class ParentControlGUI : System.Windows.Forms.Form
{
    ParentControlGUI()
    {
        # Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Application]::EnableVisualStyles()

        $this.ClientSize = New-Object System.Drawing.Point(350, 160)
        $this.text = "Управление ParentControl"
        $this.TopMost = $false
        
        $oRegConfig = [RegistryConfig]::new();

        $cbDoHomeWork = New-Object system.Windows.Forms.CheckBox;
        $cbDoHomeWork.text = "Задания выполнены";
        $cbDoHomeWork.AutoSize = $true;
        $cbDoHomeWork.width = 195;
        $cbDoHomeWork.height = 20;
        $cbDoHomeWork.location = New-Object System.Drawing.Point(40, 39);
        $cbDoHomeWork.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10);
        $cbDoHomeWork.Checked = $oRegConfig.DoHomeWork;

        $cbDisableParentControl = New-Object system.Windows.Forms.CheckBox
        $cbDisableParentControl.text = "Отключить ParentControl"
        $cbDisableParentControl.AutoSize = $true
        $cbDisableParentControl.width = 195
        $cbDisableParentControl.height = 20
        $cbDisableParentControl.location = New-Object System.Drawing.Point(40, 81)
        $cbDisableParentControl.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
        $cbDisableParentControl.Checked = -not $oRegConfig.ParentControlSystemIsOn;

        $this.Controls.AddRange(@($cbDoHomeWork, $cbDisableParentControl))

        $cbDoHomeWork.Add_Click( { [ParentControlGUI]::doCheckBox('homework', $this); });
        $cbDisableParentControl.Add_Click( { [ParentControlGUI]::doCheckBox('system', $this); });
        
    }

    static [void]doCheckBox([string]$type, [system.Windows.Forms.CheckBox]$curCheckBox)
    {
        $oRegConfig = [RegistryConfig]::new();

        switch ($type)
        {
            'homework'
            {
                $checked = $curCheckBox.Checked;
                $oRegConfig.ToggleDoHomework($checked)
            }
            'system'
            {
                $checked = -not $curCheckBox.Checked;
                $oRegConfig.ToggleParentControlSystemActive($checked)
            }
        }
        Write-Host $curCheckBox.Text ---> $curCheckBox.CheckState ---> $curCheckBox.Checked;
    }

}