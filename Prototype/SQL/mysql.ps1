#подключаем библиотеку MySql.Data.dll
Add-Type –Path "C:\Windows\System32\MySql.NETCORE\MySql.Data.dll"
# строка подключения к БД, server - имя севрера, uid - имя mysql пользователя, pwd- пароль, database - имя БД на сервере

$Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString = 'server=192.168.98.247;Port=3307;uid=bgsoft;pwd=KbcnUytd!1;database=bgsoft' }
$sql = New-Object MySql.Data.MySqlClient.MySqlCommand
$sql.Connection = $Connection
$sql.CommandText = "select * from flags";
$Connection.Open()
 
$RS = $sql.ExecuteReader();

while ($RS.Read()) {
	Write-Host $RS["name"] $RS["value"] ;
}


<#
 #формируем список пользователей с именами и email адресами
Import-Module activedirectory
$UserList = Get-ADUser -SearchBase ‘OU=Users,OU=London,DC=contoso,DC=ru’ -filter * -properties name, EmailAddress
ForEach ($user in $UserList) {
	$uname = $user.Name;
	$uemail = $user.EmailAddress;
	#записываем информацию о каждом пользователе в табдицу БД
	$sql.CommandText = "INSERT INTO users (Name,Email) VALUES ('$uname','$uemail')"
	$sql.ExecuteNonQuery()
}
$Reader.Close()
$Connection.Close() 
#>