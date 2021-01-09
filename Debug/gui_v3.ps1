Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

Class WindowView : System.Windows.Forms.Form
{

	WindowView()
	{
		$this.ClientSize = '300,150'
		$this.Text = 'Test de Form'
		$this.TopMost = $false

		$Button1 = New-Object system.Windows.Forms.Button
		$Button1.text = "Close"
		$Button1.width = 60
		$Button1.height = 30
		$Button1.Font = 'Microsoft Sans Serif,10'
		$Button1.add_Click($this.monBoutonFunc_Click())

		$this.Controls.AddRange(@($Button1))
	}

	[Void] monBoutonFunc_Click()
	{
		[System.Windows.Forms.MessageBox]::Show("Hello World." , "My Dialog Box")
		# $this.monBoutonFunc_Click()
	}
}

$Form1 = [WindowView]::new()
$Form1.Add_Shown( { $Form1.Activate() })
$Form1.ShowDialog()