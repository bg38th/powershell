@{
	RootModule             = '.\Registry.class.psm1'
	ModuleVersion          = "1.0.0.0"
	Author                 = "Boris Gordon"
	Copyright              = "38th.ru"
	PowerShellVersion      = "5.0"
	DotNetFrameworkVersion = "4.0"
	GUID                   = '2dc64c35-9152-413a-ba22-ca11837a041d'
	VariablesToExport      = '*'
	FunctionsToExport      = @(
		"GetURLBlocklist"
		, "CheckURLBlocklist"
		, "SetURLBlocklist"
		, "ClearURLBlocklist"
	)
}