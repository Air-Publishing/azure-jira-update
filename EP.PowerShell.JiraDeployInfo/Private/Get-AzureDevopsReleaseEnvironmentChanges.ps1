function Get-AzureDevopsReleaseEnvironmentChanges {
    param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [string] $SystemAccessToken,

        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $AzureEnvironmentReleasesUrl,

        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $AzureReleaseChangesUrl
    )

    $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($SystemAccessToken)"))
    Write-Debug $AzureEnvironmentReleasesUrl
    
    $response = Invoke-RestMethod -Uri $AzureEnvironmentReleasesUrl -Headers @{Authorization = "Basic $token" } -Method Get
    $releaseIds = $response.value | ForEach-Object { $_.release.id }
    Write-Debug ("[Release IDs] " + $releaseIds)

    $releaseCount = $releaseIds.count
    $thisReleaseId = $releaseIds[0]
    $previousReleaseId = If ($releaseCount -eq 1) { $thisReleaseId } Else { $releaseIds[1] }
    $releaseDiffUrl = $AzureReleaseChangesUrl -f $thisReleaseId, $previousReleaseId
    Write-Debug $releaseDiffUrl
    
    $releaseDiffResponse = Invoke-RestMethod -Uri $releaseDiffUrl -Headers @{Authorization = "Basic $token" } -Method Get
    $releaseDiffResponse.value | ForEach-Object { $_.message }
}