function Get-AzureReleaseDiff {
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
    $release_ids = $response.value | ForEach-Object { $_.release.id }
    Write-Debug ("[Release IDs] " + $release_ids)

    $release_count = $release_ids.count
    $this_release_id = $release_ids[0]
    $previous_release_id = If ($release_count -eq 1) { $this_release_id } Else { $release_ids[1] }
    $release_diff_url = $AzureReleaseChangesUrl -f $this_release_id, $previous_release_id

    Write-Debug $release_diff_url

    $diff_response = Invoke-RestMethod -Uri $release_diff_url -Headers @{Authorization = "Basic $token" } -Method Get

    $build_changes = $diff_response.value | ForEach-Object { $_.message }

    Write-Debug ("[Build Changes] " + $build_changes)
    $build_changes
}