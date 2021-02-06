#connection
$driver = "MariaDB ODBC 3.1 Driver"
 
$User = "bgsoft"
$Password = "KbcnUytd!1"
$DBName = "bgsoft"
$Server = "192.168.98.247"
$Port = 3307

# Connect to the database
$Connection = New-Object System.Data.ODBC.ODBCConnection
$Connection.connectionstring = "DRIVER={MariaDB ODBC 3.1 Driver};" +
"Server = $Server;" +
"Database = $DBName;" +
"UID = $User;" +
"PWD= $Password;" +
"Option = 3";

$Connection.connectionstring = "DSN=mariadb"  
$Connection.Open()
 

$Query = "select * from users"
$Command = New-Object System.Data.ODBC.ODBCCommand($Query,$Connection)
$Reply = $Command.executescalar()

Write-Host $Reply
