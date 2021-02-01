$Comp = "WS-LENA"

Invoke-Command -ComputerName $Comp -ScriptBlock { $code = @'
[DllImport("user32.dll")] public static extern void LockWorkStation();
'@
	$winApi = Add-Type -MemberDefinition $code -Name WinAPI -Namespace Extern -PassThru
	$winApi::LockWorkStation()
}