@{
	RootModule             = '.\SystemFunc.class.psm1'
	ModuleVersion          = "1.0.0.0"
	Author                 = "Boris Gordon"
	Copyright              = "38th.ru"
	PowerShellVersion      = "7.0"
	DotNetFrameworkVersion = "4.0"
	GUID                   = '2542f7e6-65ba-4cc1-9221-1fa3681a4cd6'
	VariablesToExport      = '*'
	FunctionsToExport      = @(
		'LockWorkstation',
		'BlockUser',
		'UnBlockUser',
		'GetUsersStates'
	)
}