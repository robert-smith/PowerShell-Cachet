function Add-CachetMetricPoints {
    <#
    .Synopsis
     Add a Metric Point to a Metric.

    .Description
     Add a Metric Point to a Metric.

    .Parameter CachetServer
     The hostname of the Cachet server.

    .Parameter Metric
     The exact name of the Cachet metric.

    .Parameter Value
     The number to add to the metric.
    
    .Parameter APIToken
     The API token key found within a Cachet user's profile.

    .Example
     # Sets the 'Internet' component to 'MajorOutage'.
     Set-CachetComponentStatus -CachetServer Cachet01 -ComponentName Internet -Status MajorOutage -APIToken FmzZg9GGQoanGnBbuyNT
    #>
    param (
        [string]$Server = 'localhost',
        [int]$ID,
        [double]$Value,
        [string]$APIToken
    )

    $splat = @{
        'Server' = $Server
        'Resource' = 'MetricPoints'
        'ID' = $ID
        'Method' = 'Post';
        'Body' = @{
            value = $Value
        }
        'ApiToken' = $APIToken
    }
    
    Invoke-CachetRequest @splat
}