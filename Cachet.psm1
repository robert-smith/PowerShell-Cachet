function Get-CachetInfo {
    <#
    .Synopsis
     Retrieves information from a Cachet server using the API.

    .Description
     Retrieves information from a Cachet server using the API. The JSON returned from the API call is converted into objects.

    .Parameter CachetServer
     The hostname of the Cachet server.

    .Parameter Info
     The specific part of Cachet that will be queried. Can only be one of the following: components, incidents, metric, or subscribers.

    .Parameter APIToken
     The API token key found within a Cachet user's profile.

    .Example
     # Get a list of all components
     Get-CachetInfo -CachetServer Cachet01 -Info components -APIToken FmzZg9GGQoanGnBbuyNT
    #>
    param (
        [string]$CachetServer,
        [ValidateSet('components','incidents','metrics','subscribers')]
        [string]$Info,
        [string]$APIToken
    )

    $splat = @{
    'Uri' = 'http://{0}/api/v1/{1}' -f $CachetServer,$Info;
    'Method' = 'Get';
    'Headers' = @{
        'X-Cachet-Token'=$APIToken;
        'Content-Type'='application/json'
        }
    }

    $results = Invoke-WebRequest @splat
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
    $deserializer = New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer
    $deserializer.MaxJsonLength = [int]::MaxValue
    $components = $deserializer.DeserializeObject($results.Content)
    $components.data.foreach{
        $obj = New-Object PSObject
        foreach ($item in $_.Keys) {
            $obj | Add-Member -MemberType NoteProperty -Name $item -Value $_.Item($item)
            }
        $obj
    }
}

function Get-CachetStatusId {
    <#
    .Synopsis
     Converts a Cachet status name to its id number.

    .Description
     Converts a Cachet status name to its id number.

    .Parameter StatusName
     The name of the Cachet status without spaces.

    .Example
     # Get the number id for the 'MajorOutage' status.
     Get-CachetStatusId -StatusName MajorOutage
    #>
    param (
        [ValidateSet(
            'Scheduled',
            'Investigating',
            'Identified',
            'Watching',
            'Fixed',
            'Operational',
            'PerformanceIssues',
            'PartialOutage',
            'MajorOutage')]
        [string]$StatusName
    )

    switch -Exact ($StatusName) {
        'Scheduled' {1}
        'Investigating' {2}
        'Identified' {3}
        'Watching' {4}
        'Fixed' {5}
        'Operational' {1}
        'PerformanceIssues' {2}
        'PartialOutage' {3}
        'MajorOutage' {4}
    }
        
}

function Set-CachetComponentStatus {
    <#
    .Synopsis
     Sets the status for a specified named component.

    .Description
     Sets the status for a specified named component. If the specified component does not exist, this command will do nothing and return a warning message.

    .Parameter CachetServer
     The hostname of the Cachet server.

    .Parameter ComponentName
     The exact name of the Cachet component.

    .Parameter Status
     The name of the status to which the component will be set.
    
    .Parameter APIToken
     The API token key found within a Cachet user's profile.

    .Example
     # Sets the 'Internet' component to 'MajorOutage'.
     Set-CachetComponentStatus -CachetServer Cachet01 -ComponentName Internet -Status MajorOutage -APIToken FmzZg9GGQoanGnBbuyNT
    #>
    param (
        [string]$CachetServer = 'localhost',
        [string]$ComponentName = 'localhost',
        [ValidateSet('Operational','PerformanceIssues','PartialOutage','MajorOutage')]
        [string]$Status,
        [string]$APIToken
    )
    
    $component = (Get-CachetInfo -CachetServer $CachetServer -Info components).Where{$_.name -eq $ComponentName}
    if ($component) {
        $statId = Get-CachetStatusId -StatusName $Status
        $splat = @{
            'Uri' = 'http://localhost/api/v1/components/{0}' -f $component.id;
            'Method' = 'Put';
            'Body' = '{{"status":{0}}}' -f $statId;
            'Headers' = @{
                'X-Cachet-Token'=$APIToken;
                'Content-Type'='application/json'
            }
        }
        Invoke-WebRequest @splat
    }
    else {
        Write-Warning -Message "Could not find component named $ComponentName."
    }
}

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
        [string]$CachetServer,
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
    
    $component = (Get-CachetInfo -CachetServer $CachetServer -Info components).Where{$_.name -eq $ComponentName}

    if ($component) {

        $iStatId = Get-CachetStatusId -StatusName $Status
        $cStatId = Get-CachetStatusId -StatusName $ComponentStatus

        $json = @{
            name = $Name;
            message = $Message;
            status = $iStatId;
            visible = $Visible;
            component_id = $component.id;
            component_status = $cStatId
            } | ConvertTo-Json

        $splat = @{
            'Body' = $json;
            'Method' = 'Post';
            'Uri' = 'http://{0}/api/v1/incidents' -f $CachetServer
            'Headers' = @{
                'X-Cachet-Token'=$APIToken;
                'Content-Type'='application/json'
            }
        }

        Invoke-WebRequest @splat
    }

    else {
        Write-Warning -Message "Component $ComponentName could not be found."
    }
}

Export-ModuleMember -Function * -Alias *