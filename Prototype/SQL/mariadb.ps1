Install-Module MariaDBCmdlets

$user = "bgsoft"
$Password = "KbcnUytd!1"
$Database = "bgsoft"
$Server = "192.168.98.247"
$Port = 3307

$mariadb = Connect-MariaDB -User $User -Password $Password -Database $Database -Server $Server -Port $Port;
#$data = Select-MariaDB -Connection $mariadb -Table "users";
$data = Invoke-MariaDB -Connection $mariadb -Query 'SELECT * FROM Orders WHERE ShipCountry = @ShipCountry' -Params @{ShipCountry = 'USA' };
$columns = ($data | Get-Member -MemberType NoteProperty | Select-Object -Property fullname).fullname
