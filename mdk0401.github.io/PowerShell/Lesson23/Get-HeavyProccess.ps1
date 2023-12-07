$n = 3


function Get-HeavyProcess {
   Get-Process | Sort-Object WS -Descending | Select-Object -First $n 
}

Get-HeavyProcess
