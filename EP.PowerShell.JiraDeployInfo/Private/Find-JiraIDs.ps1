function Find-JiraIDs {
    param (
        $message
    )
    $pattern = '[A-Za-z]{2,10}-\d{1,4}'
    $values = [regex]::Matches($message, $pattern) | Select-Object value 
    Write-Host ("[JIRA IDs] " + $values)
    $values
}
