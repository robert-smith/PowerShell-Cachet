function Invoke-CachetRequest {
    [CmdletBinding()]
    param (
        [string]$Server,
        [string]$Method,
        [string]$ID = $null,
        [hashtable]$Body,
        [string]$ApiToken
    )

    dynamicparam {
        $ParameterName = 'Resource'
            
        # Create the dictionary 
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 2

        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)

        # Generate and set the ValidateSet 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($Settings.URIs.Keys)

        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)

        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }

    begin {
        # Bind the parameter to a friendly variable
        $Resource = $PsBoundParameters[$ParameterName]
        <#
        if (-not $ID) {
            Write-Verbose 'Removing ID'
            Set-Variable -Name ID -Value $null -Force
        }
        #>
    }

    process {
        $splat = @{
            'Method' = $Method
            'Uri' = $Settings.URIs.$Resource -f $Server, $ID
            'Headers' = @{
                'X-Cachet-Token'=$ApiToken
                'Content-Type'='application/json'
            }
        }
        if ($Method -ne 'GET') {
            $json = ConvertTo-Json -InputObject $Body
            $splat.Body = $json
        }
        $result = Invoke-RestMethod @splat

        if (-not ($result.GetType().Name -eq 'PSCustomObject')) {
            # Remove arguments with empty names as they will cause the conversion from json to an object to fail
            $result = $result -replace ',"tags":{"":""}' | ConvertFrom-Json
        }
        #return
        $result.Data
    }
}