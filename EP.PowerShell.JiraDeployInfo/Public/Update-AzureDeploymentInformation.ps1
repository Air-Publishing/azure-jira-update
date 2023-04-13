function Update-AzureDeploymentInformation {
    <#
    .SYNOPSIS
    Updates Jira deployment information based on Azure Devops changes.
    
    .DESCRIPTION
    Checks Azure DevOps changes to get a list of changes that have occured since last successful deployment. Any Jira looking ticket numbers are extracted. Jira is then updated with deployment information
    
    .PARAMETER JiraDomain
    The full domain name for your Jira instance. For example companyname.atlassian.net
    
    .PARAMETER AtlassianClientId
    OAuth Client ID for Atlassian which can be generated at https://companyname.atlassian.net/secure/admin/oauth-credentials - Defaults to $env:ATLASSIAN_CLIENT_ID if not set
    
    .PARAMETER AtlassianClientSecret
    OAuth Client Secret for Atlassian which can be generated at https://companyname.atlassian.net/secure/admin/oauth-credentials - Defaults to $env:ATLASSIAN_CLIENT_SECRET if not set
    
    .PARAMETER State
    The state to set the Jira deployment information to
    
    .PARAMETER EnvironmentType
    The deploy type to set the deployment information to.

    .PARAMETER DisplayName
    The Display Name used in Jira - Defaults to $env:BUILD_BUILDNUMBER
    
    .PARAMETER Label
    The Label Name used in Jira - Defaults to $env:BUILD_BUILDNUMBER
    
    .PARAMETER Url
    The URL that Jira links to - Defaults to $env:SYSTEM_COLLECTIONURI/$env:SYSTEM_TEAMPROJECT/_build/results?buildId=$($env:BUILD_BUILDID)
    
    .PARAMETER EnvironmentId
    The Environment ID that's sent to Jira - Defaults to $env:ENVIRONMENT_ID
    
    .PARAMETER EnvironmentDisplayName
    The Environment Display Name to show in Jira - Defaults to $env:ENVIRONMENT_NAME
    
    .PARAMETER PipelineId
    The PipelineId that's sent to Jira - Defaults to $env:SYSTEM_DEFINITIONID
    
    .PARAMETER PipelineDisplayName
    The Pipeline Display Name for show in Jira - Defaults to $env:BUILD_DEFINITIONNAME
    
    .PARAMETER PipelineUrl
    The Pipeline Url to show in Jira - Defaults to $env:SYSTEM_COLLECTIONURI/$env:SYSTEM_TEAMPROJECT/_build/?definitionId=$($env:SYSTEM_DEFINITIONID)
    
    .EXAMPLE
    Update-AzureDeploymentInformation -JiraDomain educationperfect.atlassian.net -State Unknown -Type Unmapped
    
    .NOTES
    This cmdlet is expected to run under an Azure DevOps deployment job.
    #>

    [CmdletBinding()]
    param (


        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $JiraDomain,

        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $AtlassianClientId = "$env:ATLASSIAN_CLIENT_ID", 

        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $AtlassianClientSecret = $env:ATLASSIAN_CLIENT_SECRET, 

        [ValidateSet("Unknown", "Pending", "InProgress", "Cancelled", "Failed", "RolledBack", "Successful")]
        [string] $State = "Unknown",

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName = $env:BUILD_BUILDNUMBER,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Label = $env:BUILD_BUILDNUMBER,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Url = "$env:SYSTEM_COLLECTIONURI/$env:SYSTEM_TEAMPROJECT/_build/results?buildId=$($env:BUILD_BUILDID)",

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $EnvironmentId = $env:RELEASE_ENVIRONMENTID,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $EnvironmentDisplayName = $env:RELEASE_ENVIRONMENTNAME,

        [ValidateSet("Unmapped", "Development", "Testing", "Staging", "Production")]
        [string] $EnvironmentType = "Unmapped",

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PipelineId = $env:SYSTEM_DEFINITIONID,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PipelineDisplayName = $env:BUILD_DEFINITIONNAME,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PipelineUrl = "$env:SYSTEM_COLLECTIONURI/$env:SYSTEM_TEAMPROJECT/_build/?definitionId=$($env:SYSTEM_DEFINITIONID)",
        
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ReleaseId = $env:RELEASE_RELEASEID,
        
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $SystemAccessToken = $env:SYSTEM_ACCESSTOKEN,

        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $AzureChangeUrl = "$env:SYSTEM_TASKDEFINITIONSURI/$env:SYSTEM_TEAMPROJECT/_traceability/runview/changes?currentRunId=$($env:BUILD_BUILDID)&__rt=fps",

        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $AzureEnvironmentReleasesUrl = "$env:SYSTEM_COLLECTIONURI/$env:SYSTEM_TEAMPROJECT/_apis/Release/deployments?definitionId=$($env:RELEASE_DEFINITIONID)&definitionEnvironmentId=$($env:RELEASE_DEFINITIONENVIRONMENTID)&deploymentStatus=succeeded&operationStatus=all&latestAttemptsOnly=true&queryOrder=descending&top=2",

        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string] $AzureReleaseChangesUrl = "$env:SYSTEM_COLLECTIONURI/$env:SYSTEM_TEAMPROJECT/_apis/Release/releases/{0}/changes?baseReleaseId={1}&top=2500"
    )

    $jiraIds = @()
    $jiraIds += (Get-JiraIDsFromAzureChanges -ReleaseId $ReleaseId -SystemAccessToken $SystemAccessToken -AzureEnvironmentReleasesUrl $AzureEnvironmentReleasesUrl -AzureReleaseChangesUrl $AzureReleaseChangesUrl)
    Write-Host ("[Jira IDs] " + $jiraIds)
    
    Write-Host 
    $splatVars = @{
        JiraDomain              = $JiraDomain
        AtlassianClientId       = $AtlassianClientId
        AtlassianClientSecret   = $AtlassianClientSecret
        Issues                  = $jiraIds
        State                   = $State
        Description             = "Azure DevOps"
        Label                   = $Label
        DisplayName             = $DisplayName
        Url                     = $Url
        
        EnvironmentId           = $EnvironmentId
        EnvironmentType         = $EnvironmentType
        EnvironmentDisplayName  = $EnvironmentDisplayName

        PipelineId              = $PipelineId
        PipelineDisplayName     = $PipelineDisplayName
        PipelineUrl             = $PipelineUrl

        Product                 = "Azure DevOps"
    }

    Add-JIRADeploymentInformation @splatVars
}