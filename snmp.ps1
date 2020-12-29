Clear-Host

$SNMP = New-Object -ComObject olePrn.OleSNMP
$SNMP.Open('192.168.98.1', "public", 2, 3000)
# $SNMP.Set(".1.3.6.1.4.1.14988.1.1.8.1.1.3.2", 1)
# $SNMP.Set(".1.3.6.1.4.1.14988.1.1.8.1.1.3.3", 1)
$SNMP.Get(".1.3.6.1.4.1.14988.1.1.18.1.1.2.2")
$SNMP.Get(".1.3.6.1.4.1.14988.1.1.18.1.1.2.3")

