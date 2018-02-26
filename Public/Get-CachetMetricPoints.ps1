function Get-CachetMetricPoints {
    <#
    .Synopsis
     Gets the current points for a metric.

    .Description
     Gets the current points for a metric.

    .Parameter CachetServer
     The hostname of the Cachet server.

    .Parameter MetricID
     The ID number of the Cachet metric.
    
    .Parameter APIToken
     The API token key found within a Cachet user's profile.

    .Example
     # Sets the 'Internet' component to 'MajorOutage'.
     Get-CachetMetricPoints -CachetServer Cachet01 -MetricID 1 -APIToken FmzZg9GGQoanGnBbuyNT
    #>
    param (
        [Parameter(Mandatory=$true)]    
        [string]$Server = 'localhost',
        [Parameter(Mandatory=$true)]
        [int]$ID,
        [Parameter(Mandatory=$true)]
        [string]$APIToken
    )

    $splat = @{
        'Server' = $Server
        'Resource' = 'MetricPoints'
        'ID' = $ID
        'Method' = 'Get';
        'ApiToken' = $APIToken
    }

    Invoke-CachetRequest @splat
}