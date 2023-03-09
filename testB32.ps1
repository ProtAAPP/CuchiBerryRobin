Import-Module ./Get-Base32.ps1
[System.Text.Encoding]::ASCII.GetBytes("I am a teapot, hear me pour! Glug, glug, glug.")  | Get-Base32 -EnablePadding $False 