

function Get-DeployedTickets {
Param
   (
       
        [string] $SystemAccessToken = $env:AzureToken,
        [string] $AzureChangeUrl = "https://vsrm.dev.azure.com/airpublishing/CaterCloud/_apis/Release/deployments?definitionId=${env:RELEASE_DEFINITIONID}&definitionEnvironmentId=${env:RELEASE_DEFINITIONENVIRONMENTID}&deploymentStatus=30&operationStatus=7960&latestAttemptsOnly=true&queryOrder=0&%24top=50&continuationToken=1154",
        [string] $TicketUrl =  "https://vsrm.dev.azure.com/airpublishing/${env:SYSTEM_TEAMPROJECTID}/_apis/Release/releases/{CURRENT}/changes?baseReleaseId={LAST}"
    )


    Write-Host "CHANGE URL:  ${AzureChangeUrl}"   
    Write-Host "TICKET URL:  ${TicketUrl}"
   
    $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($SystemAccessToken)"))
    $response = Invoke-RestMethod -Uri $AzureChangeUrl -Headers @{Authorization = "Basic $token" } -Method Get
    [int]$thisReleaseId   = $response.Value[0].release.id
    $sucessfulPreviousReleases = $response.Value  | Where-Object -FilterScript  {($_.deploymentStatus -EQ 'succeeded')   -and ($_.release.id -LT $thisReleaseId) } | Sort-Object -Property $_.release.id -Descending
    $lastReleaseId = $sucessfulPreviousReleases[0].release.id
    ##Write-Host "THIS RELEASE: $thisReleaseId LAST RELEASE:  $lastReleaseId"
    $TicketUrl = $TicketUrl.Replace("{CURRENT}","$thisReleaseId").Replace("{LAST}","$lastReleaseId")
    ##Write-Host $TicketUrl
    $ticketsResponse = (Invoke-RestMethod -Uri $TicketUrl -Headers @{Authorization = "Basic $token" } -Method Get).value | ForEach-Object { $_.message }
    $deployedTickets = $ticketsResponse | Select-String -Pattern 'CAT-([0-9]+)' -AllMatches | ForEach-Object { $_.matches } | ForEach-Object { $_.value } | Select-Object -Unique | Sort-Object
	$retVar = [string]::Join(",", $deployedTickets)
    ##Write-Host $retVar
    return $deployedTickets
}


###  USAGE DEPENDANT ON 3 ENV VARIABLES BEING SET     $env:AzureToken,  $env:ChangeUrl ,  $env:TicketUrl (these are set in the pipeline)
##$jiraIds = @()
##    $jiraIds +=  Get-DeployedTickets 

