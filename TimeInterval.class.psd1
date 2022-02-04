@{
	RootModule             = '.\TimeInterval.class.psm1'
	GUID                   = 'c6017123-da9e-421a-a3cd-5448cf024800'
	ModuleVersion          = "1.0.0.0"
	Author                 = "Boris Gordon"
	Copyright              = "38th.ru"
	PowerShellVersion      = "5.0"
	DotNetFrameworkVersion = "4.0"
	FunctionsToExport      = "CheckWorkTime"
	RequiredModules        = @(
		@{
			ModuleName    = ".\Registry.class.psd1"; 
			ModuleVersion = "1.0.0.0"; 
			Guid          = "2dc64c35-9152-413a-ba22-ca11837a041d"
		},
		@{
			ModuleName    = ".\SQL.class.psd1"; 
			ModuleVersion = "1.0.0.0"; 
			Guid          = "b529f59a-2bc5-4c8c-9a39-debc47603201";
		}
	)
}