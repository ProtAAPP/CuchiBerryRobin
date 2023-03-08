function Get-Base32 {
    [CmdletBinding()]    param(        [Parameter(Position = 0, ValueFromPipeline = $true)]       [ValidateNotNullOrEmpty()]	[byte[]] $InputObject,	[Parameter(Mandatory=$false)]	[Alias("EnablePadding")]	[bool]$pad   = $True	     )
    Process {        foreach ($item  in $InputObject) {            $dataArray += $item        }    }
    Begin {        $dataArray = @()}
    End {
    	    $byteArrayAsBinaryString = -join $dataArray.ForEach{	    [Convert]::ToString($_, 2).PadLeft(8, '0')	    }
        $byteArrayAsBinaryString = $($byteArrayAsBinaryString+("0000".Substring(0,5-($byteArrayAsBinaryString.length%5))))
	 $x = [regex]::Replace($byteArrayAsBinaryString, '.{5}', {    		param($Match)    		'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'[[Convert]::ToInt32($Match.Value, 2)]	    })
	    Write-Output "$x$padding"
    }
}


[System.Text.Encoding]::ASCII.GetBytes("I am a teapot, hear me pour! Glug, glug, glug.")  | Get-Base32 