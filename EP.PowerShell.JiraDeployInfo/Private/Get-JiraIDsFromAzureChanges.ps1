function Get-JiraIDsFromAzureChanges {
    param (
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $SystemAccessToken,

        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $AzureEnvironmentReleasesUrl,
        
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $AzureReleaseChangesUrl
    )

    $jiraIds = @()
    Get-AzureReleaseDiff -SystemAccessToken $SystemAccessToken -AzureEnvironmentReleasesUrl $AzureEnvironmentReleasesUrl -AzureReleaseChangesUrl $AzureReleaseChangesUrl | ForEach-Object {
        Find-JiraIDs ($_) | ForEach-Object {
            $jiraIds += $_.Value.ToUpper()
        }
    }
    $jiraIds | Sort-object | Get-Unique -AsString
}