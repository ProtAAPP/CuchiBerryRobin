#FIRMA codigo
#OPENSSL en path
#private.key es la privada
#private.der es la publica


$texto="Calc.exe"
$archivoTemporal = [System.IO.Path]::GetTempFileName() 
$archivoTemporal64 = [System.IO.Path]::GetTempFileName() 


echo -n "$texto" | openssl pkeyutl -sign  -inkey private.key -out $archivoTemporal 
openssl base64 -in $archivoTemporal -out $archivoTemporal64
$Firma=Get-Content -Path $archivoTemporal64


Write-Host "TEXTO EN BASE 64 FIRMADO" + $Firma


#Descifrado


$descifrado=openssl base64 -in $archivoTemporal64 -d | openssl pkeyutl -verifyrecover -in $archivoTemporal  -inkey private.der
Write-Host "TEXTO DESCIFRADO" + $descifrado