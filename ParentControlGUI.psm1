Using module  .\Registry.class.psd1

class ParentControlGUI : System.Windows.Forms.Form
{
    ParentControlGUI()
    {
        # Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Application]::EnableVisualStyles()

        $this.ClientSize = New-Object System.Drawing.Point(350, 200)
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

        $cbLockComp = New-Object System.Windows.Forms.Button
        $cbLockComp.text = "Блокировка компа"
        $cbLockComp.AutoSize = $true
        $cbLockComp.width = 195
        $cbLockComp.height = 20
        $cbLockComp.location = New-Object System.Drawing.Point(40, 122)
        $cbLockComp.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

        $cbUnLockComp = New-Object System.Windows.Forms.Button
        $cbUnLockComp.text = "Разблокировка компа"
        $cbUnLockComp.AutoSize = $true
        $cbUnLockComp.width = 195
        $cbUnLockComp.height = 20
        $cbUnLockComp.location = New-Object System.Drawing.Point(40, 163)
        $cbUnLockComp.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

        $this.Controls.AddRange(@($cbDoHomeWork, $cbDisableParentControl, $cbLockComp, $cbUnLockComp))

        $cbDoHomeWork.Add_Click( { [ParentControlGUI]::doCheckBox('homework', $this); });
        $cbDisableParentControl.Add_Click( { [ParentControlGUI]::doCheckBox('system', $this); });
        $cbLockComp.Add_Click( { [ParentControlGUI]::doButton('lock'); });
        $cbUnLockComp.Add_Click( { [ParentControlGUI]::doButton('unlock'); });
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

    static [void]doButton([string]$type)
    {
        $Comp = "WS-LENA"
        switch ($type)
        {
            'lock'
            {
                Invoke-Command -ComputerName $Comp -ScriptBlock { Disable-LocalUser -Name "lena" }
                Invoke-Command -ComputerName $Comp -ScriptBlock { Start-ScheduledTask -TaskName "\Local\lock" }
            }
            'unlock'
            {
                Invoke-Command -ComputerName $Comp -ScriptBlock { Enable-LocalUser -Name "lena" }
            }
        }
    }
}