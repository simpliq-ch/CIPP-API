using namespace System.Net

Function Invoke-ExecBackendURLs {
    <#
    .FUNCTIONALITY
        Entrypoint
    .ROLE
        CIPP.AppSettings.Read
    #>
    [CmdletBinding()]
    param($Request, $TriggerMetadata)

    $APIName = $Request.Params.CIPPEndpoint
    Write-LogMessage -headers $Request.Headers -API $APINAME -message 'Accessed this API' -Sev 'Debug'

    $Subscription = ($env:WEBSITE_OWNER_NAME).split('+') | Select-Object -First 1
    $SWAName = $env:WEBSITE_SITE_NAME -replace 'cipp', 'CIPP-SWA-'
    # Write to the Azure Functions log stream.
    Write-Host 'PowerShell HTTP trigger function processed a request.'

    $RGName = $env:WEBSITE_RESOURCE_GROUP
    if (!$RGName) {
        $Owner = $env:WEBSITE_OWNER_NAME
        $RGName = $Owner -split '\+' | Select-Object -Last 1
        $RGName = $RGName -replace '-[^-]+$', ''
    }

    $results = [PSCustomObject]@{
        ResourceGroup      = "https://portal.azure.com/#@Go/resource/subscriptions/$Subscription/resourceGroups/$RGName/overview"
        KeyVault           = "https://portal.azure.com/#@Go/resource/subscriptions/$Subscription/resourceGroups/$RGName/providers/Microsoft.KeyVault/vaults/$($env:WEBSITE_SITE_NAME)/secrets"
        FunctionApp        = "https://portal.azure.com/#@Go/resource/subscriptions/$Subscription/resourceGroups/$RGName/providers/Microsoft.Web/sites/$($env:WEBSITE_SITE_NAME)/appServices"
        FunctionConfig     = "https://portal.azure.com/#@Go/resource/subscriptions/$Subscription/resourceGroups/$RGName/providers/Microsoft.Web/sites/$($env:WEBSITE_SITE_NAME)/configuration"
        FunctionDeployment = "https://portal.azure.com/#@Go/resource/subscriptions/$Subscription/resourceGroups/$RGName/providers/Microsoft.Web/sites/$($env:WEBSITE_SITE_NAME)/vstscd"
        SWADomains         = "https://portal.azure.com/#@Go/resource/subscriptions/$Subscription/resourceGroups/$RGName/providers/Microsoft.Web/staticSites/$SWAName/customDomains"
        SWARoles           = "https://portal.azure.com/#@Go/resource/subscriptions/$Subscription/resourceGroups/$RGName/providers/Microsoft.Web/staticSites/$SWAName/roleManagement"
        Subscription       = $Subscription
        RGName             = $RGName
        FunctionName       = $env:WEBSITE_SITE_NAME
        SWAName            = $SWAName
    }


    $body = @{Results = $Results }

    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [httpstatusCode]::OK
            Body       = $body
        })

}
