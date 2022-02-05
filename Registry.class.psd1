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
	RequiredModules        = @(
		@{
			ModuleName    = ".\SQL.class.psd1"; 
			ModuleVersion = "1.0.0.0"; 
			Guid          = "b529f59a-2bc5-4c8c-9a39-debc47603201";
		}
	)
}