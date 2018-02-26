function Get-CachetComponent {
    <#
    .Synopsis
     Gets all or a specified Cachet component.

    .Description
     Gets all or a specified Cachet component.

    .Parameter CachetServer
     The hostname of the Cachet server.

    .Parameter ID
     The ID number of a Cachet component.
    
    .Parameter APIToken
     The API token key found within a Cachet user's profile.

    .Example
     # Sets the 'Internet' component to 'MajorOutage'.
     Get-CachetComponent -CachetServer Cachet01 -ID 1 -APIToken FmzZg9GGQoanGnBbuyNT
    #>
    param (
        [Parameter(Mandatory=$true)]    
        [string]$Server = 'localhost',
        [int]$ID,
        [Parameter(Mandatory=$true)]
        [string]$APIToken
    )

    $splat = @{
        'Server' = $Server
        'Resource' = 'Components'
        'Method' = 'Get';
        'ApiToken' = $APIToken
    }

    if ($ID) {
        Write-Verbose 'Adding ID to splat' -Verbose
        $splat.ID = $ID
    }

    Invoke-CachetRequest @splat
}