$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Exclude *.tests.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Exclude *.tests.ps1 -ErrorAction SilentlyContinue )
$Settings = @( Get-ChildItem -Path $PSScriptRoot\Config\*.psd1 -ErrorAction SilentlyContinue)

Foreach($import in @($Public + $Private))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
} #End of function foreach

foreach ($file in $Settings) {
    $splat = @{
        BindingVariable = $file.BaseName
        BaseDirectory = $file.DirectoryName
        FileName = $file.Name
    }
    Import-LocalizedData @splat
    Export-ModuleMember -Variable $file.BaseName
} #End of variable foreach

Export-ModuleMember -Function $Public.BaseName