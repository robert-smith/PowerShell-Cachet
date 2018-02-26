function New-CachetIncident {
    <#
    .Synopsis
     Creates a new Cachet incident.

    .Description
     Creates a new Cachet incident.

    .Parameter Name
     The name of the incident.

    .Parameter Message
     The incident's message.

    .Parameter Status
     The incident's state.

    .Parameter Visible
     Specifies whether the incident is visible to the public or only logged on users.
    
    .Parameter CachetServer
     The hostname of the Cachet server.

    .Parameter ComponentName
     The exact name of the Cachet component.

    .Parameter ComponentStatus
     The status of the component affected by the incident.

    .Parameter Notify
     Specifies whether a notification will be sent to subscribers.
    
    .Parameter APIToken
     The API token key found within a Cachet user's profile.

    .Example
     # Sets the 'Internet' component to 'MajorOutage'.
     Set-CachetComponentStatus -CachetServer Cachet01 -ComponentName Internet -Status MajorOutage -APIToken FmzZg9GGQoanGnBbuyNT
    #>
    param (
        [string]$Server,
        [string]$Name,
        [string]$Message,
        [ValidateSet('Scheduled','Investigating','Identified','Watching','Fixed')]
        $Status,
        [ValidateSet(0,1)]
        [int]$Visible = 1,
        $ComponentName,
        [ValidateSet('Operational','PerformanceIssues','PartialOutage','MajorOutage')]
        $ComponentStatus,
        [ValidateSet('true','false')]
        $Notify,
        [string]$APIToken
    )
    
    $component = Get-CachetInfo -CachetServer $Server -Info components -APIToken $APIToken | Where-Object -FilterScript {$_.Name -eq $ComponentName}

    if ($component) {

        $iStatId = Get-CachetStatusId -StatusName $Status
        $cStatId = Get-CachetStatusId -StatusName $ComponentStatus

        $Body = @{
            name = $Name;
            message = $Message;
            status = $iStatId;
            visible = $Visible;
            component_id = $component.id;
            component_status = $cStatId
            }

        $splat = @{
            'Server' = $Server
            'Resource' = 'Incidents'
            'Body' = $Body;
            'Method' = 'Post';
            'ApiToken' = $APIToken
        }

        Invoke-CachetRequest @splat
    }

    else {
        Write-Warning -Message "Component $ComponentName could not be found."
    }
}