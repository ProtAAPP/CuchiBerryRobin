#FIRMA codigo
#OPENSSL en path
#private.key es la privada
#private.der es la publica


$texto="Calc.exe"
$archivoTemporal = [System.IO.Path]::GetTempFileName() 
$archivoTemporal64 = [System.IO.Path]::GetTempFileName() 


echo -n "$texto" | openssl pkeyutl -sign  -inkey private.key -out $archivoTemporal 
#openssl base64 -in $archivoTemporal -out $archivoTemporal64 -A
$Firma=Get-Content -Path $archivoTemporal -raw -ReadCount 0




$Firma64=[Convert]::ToBase64String([IO.File]::ReadAllBytes($archivoTemporal))

#test encodeco
[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String([Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Firma))))

Write-Host "TEXTO EN BASE 64 FIRMADO:"  $Firma64


#Descifrado
[IO.File]::WriteAllBytes($archivoTemporal64, [Convert]::FromBase64String($Firma64))
$Firma64d=Get-Content -Path $archivoTemporal64 -raw -ReadCount 0

$descifrado= openssl pkeyutl -verifyrecover  -inkey private.der -in $archivoTemporal 
Write-Host "TEXTO DESCIFRADO:" $descifrado

openssl pkeyutl -verifyrecover  -inkey private.der -in $archivoTemporal64 