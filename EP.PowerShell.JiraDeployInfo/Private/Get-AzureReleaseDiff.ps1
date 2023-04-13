function Get-AzureReleaseDiff {
    param (
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $ReleaseId,
        
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [string] $SystemAccessToken,

        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $AzureEnvironmentReleasesUrl,

        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $AzureReleaseChangesUrl
    )

    $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($SystemAccessToken)"))
    Write-Host $AzureEnvironmentReleasesUrl

    $response = Invoke-RestMethod -Uri $AzureEnvironmentReleasesUrl -Headers @{Authorization = "Basic $token" } -Method Get
    $release_ids = $response.value | ForEach-Object { $_.release.id }
    Write-Host ("[Release IDs] " + $release_ids)

    $release_count = $release_ids.count
    $previous_release_id = If ($release_count -eq 0) { $ReleaseId } Else { $release_ids[0] }
    $release_diff_url = $AzureReleaseChangesUrl -f $ReleaseId, $previous_release_id

    Write-Host $release_diff_url

    $diff_response = Invoke-RestMethod -Uri $release_diff_url -Headers @{Authorization = "Basic $token" } -Method Get

    $build_changes = $diff_response.value | ForEach-Object { $_.message }

    Write-Host ("[Build Changes] " + $build_changes)
    $build_changes
}