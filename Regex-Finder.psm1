# Regex-Finder.psm1

function Find-Regex {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$RegexPattern,

        [Parameter(Mandatory = $true)]
        [string]$DirectoryPath,

        [switch]$File,

        [switch]$Folder,

        [switch]$FileName
    )

    process {
        # Get all items recursively
        $items = Get-ChildItem -Path $DirectoryPath -Recurse -Force

        # Filter based on the parameters
        foreach ($item in $items) {
            if ($File -and $item.Attributes -match 'Archive') {
                if ($item.FullName -match $RegexPattern) {
                    Write-Output "File match: $($item.FullName)"
                }
            } elseif ($Folder -and $item.Attributes -match 'Directory') {
                if ($item.FullName -match $RegexPattern) {
                    Write-Output "Folder match: $($item.FullName)"
                }
            } elseif ($FileName -and $item.Name -match $RegexPattern) {
                Write-Output "File name match: $($item.FullName)"
            } elseif (-not $File -and -not $Folder -and -not $FileName) {
                if ($item.FullName -match $RegexPattern) {
                    Write-Output "Match: $($item.FullName)"
                }
            }
        }
    }
}

Export-ModuleMember -Function Find-Regex
