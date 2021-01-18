@{
	RootModule             = '.\ParentControlGUI.psm1'
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
	VariablesToExport      = '*'
	RequiredModules        = @(
		@{
			ModuleName    = ".\Registry.class.psd1"; 
			ModuleVersion = "1.0.0.0"; 
			Guid          = "2dc64c35-9152-413a-ba22-ca11837a041d";
		}
	)
	RequiredAssemblies     = @("System.Windows.Forms")
}
