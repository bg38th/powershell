@{
	RootModule             = '.\Registry.class.psm1'
	ModuleVersion          = "1.0.0.0"
	Author                 = "Boris Gordon"
	Copyright              = "38th.ru"
	PowerShellVersion      = "7.0"
	DotNetFrameworkVersion = "4.0"
	GUID                   = '2dc64c35-9152-413a-ba22-ca11837a041d'
	VariablesToExport      = '*'
	FunctionsToExport      = @(
		"GetDoHomework"
		, "SetDoHomework"
		, "ToggleDoHomework"
		, "ClearDoHomework"
		, "GetProcessConf"
		, "SetProcessConf"
		, "SetMaskFileName"
		, "RemoveProcessConf"
		, "GetTimeConfigJSON"
		, "GetParentControlTimeState"
		, "SetParentControlTimeState"
		, "ToggleParentControlTimeState"
		, "GetParentControlSystemActive"
		, "SetParentControlSystemActive"
		, "ParentControlActiveToOn"
		, "ParentControlActiveToOff"
	)
}