@{
	RootModule             = '.\SQL.class.psm1'
	ModuleVersion          = "1.0.0.0"
	Author                 = "Boris Gordon"
	Copyright              = "38th.ru"
	PowerShellVersion      = "7.0"
	DotNetFrameworkVersion = "4.0"
	GUID                   = 'b529f59a-2bc5-4c8c-9a39-debc47603201'
	VariablesToExport      = '*'
	RequiredAssemblies     = @("C:\Windows\System32\MySql.NETCORE\MySql.Data.dll")
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