@{
	RootModule             = '.\SQL.class.psm1'
	ModuleVersion          = "1.0.0.0"
	Author                 = "Boris Gordon"
	Copyright              = "38th.ru"
	PowerShellVersion      = "5.0"
	DotNetFrameworkVersion = "4.0"
	GUID                   = 'b529f59a-2bc5-4c8c-9a39-debc47603201'
	VariablesToExport      = '*'
	RequiredAssemblies     = @("C:\Windows\System32\MySql.NETCORE\MySql.Data.dll")
	RequiredModules        = @(
		@{
			ModuleName    = ".\SystemFunc.class.psd1"; 
			ModuleVersion = "1.0.0.0"; 
			Guid          = "2542f7e6-65ba-4cc1-9221-1fa3681a4cd6";
		}
	)
	FunctionsToExport      = @(
		"GetType"
		, "GetProcessConf"
		, "SetProcessConf"
		, "SetMaskFileName"
		, "RemoveProcessConf"
		, "GetDoHomework"
		, "SetDoHomework"
		, "ToggleDoHomework"
		, "GetParentControlTimeState"
		, "SetParentControlTimeState"
		, "ToggleParentControlTimeState"
		, "GetTimeConfiguration"
	)
}