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