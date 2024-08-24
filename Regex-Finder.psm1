function Find-Regex {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$RegexPattern,

        [Parameter(Mandatory = $true)]
        [string]$DirectoryPath,

        [switch]$File,

        [switch]$Folder,

        [switch]$FileName,

        [switch]$Prompt,

        [switch]$AutoContinue,

        [Parameter()]
        [string]$LogFile,

        [Parameter()]
        [string]$ErrorLogFile,

        [Parameter()]
        [string]$ExcludePattern,

        [Parameter()]
        [int]$MaxDepth = [int]::MaxValue,

        [Parameter()]
        [nullable[TimeSpan]]$TimeLimit = $null
    )

    begin {
        $global:matchCount = 0
        $global:errorCount = 0
        $startTime = Get-Date
    }

    process {
        # Get items in the current directory
        $items = Get-ChildItem -Path $DirectoryPath -Recurse:$false -Force -ErrorAction SilentlyContinue

        foreach ($item in $items) {
            try {
                # Apply exclusion pattern
                if ($ExcludePattern -and $item.FullName -match $ExcludePattern) {
                    continue
                }

                # Check for max depth
                if ($MaxDepth -le 0) { return }

                # Match file, folder, or file name based on the provided switches
                $isMatch = $false
                if ($File -and $item.Attributes -match 'Archive') {
                    if ($item.FullName -match $RegexPattern) {
                        Write-Host "File match: $($item.FullName)" -ForegroundColor Yellow
                        $isMatch = $true
                    }
                } elseif ($Folder -and $item.Attributes -match 'Directory') {
                    if ($item.FullName -match $RegexPattern) {
                        Write-Host "Folder match: $($item.FullName)" -ForegroundColor Yellow
                        $isMatch = $true
                    }
                } elseif ($FileName -and $item.Name -match $RegexPattern) {
                    Write-Host "File name match: $($item.FullName)" -ForegroundColor Yellow
                    $isMatch = $true
                } elseif (-not $File -and -not $Folder -and -not $FileName) {
                    if ($item.FullName -match $RegexPattern) {
                        Write-Host "Match: $($item.FullName)" -ForegroundColor Yellow
                        $isMatch = $true
                    }
                }

                # Log matches
                if ($isMatch) {
                    $global:matchCount++
                    if ($LogFile) {
                        Add-Content -Path $LogFile -Value "Match found: $($item.FullName)"
                    }

                    # Default: Stop on first match
                    if (-not $Prompt -and -not $AutoContinue) {
                        return
                    }

                    # Prompt the user if a match is found and -Prompt is used
                    if ($Prompt) {
                        $response = Read-Host "Match found. Do you want to continue searching? (Y/N) Exclude this pattern from further search? (E)"
                        if ($response -eq 'N') {
                            return
                        } elseif ($response -eq 'E') {
                            $ExcludePattern = [regex]::Escape($item.FullName)
                        }
                    }
                }

            } catch {
                $global:errorCount++
                $errorMessage = "Error accessing: $($item.FullName). $_"
                Write-Host $errorMessage -ForegroundColor Red
                if ($ErrorLogFile) {
                    Add-Content -Path $ErrorLogFile -Value $errorMessage
                }
            }

            # Check elapsed time
            if ($TimeLimit -ne $null -and (Get-Date) -gt ($startTime + $TimeLimit.Value)) {
                return
            }
        }

        # Recurse into subdirectories if user chooses to continue
        foreach ($subdir in $items | Where-Object { $_.PSIsContainer }) {
            Find-Regex -RegexPattern $RegexPattern -DirectoryPath $subdir.FullName -File:$File -Folder:$Folder -FileName:$FileName -Prompt:$Prompt -AutoContinue:$AutoContinue -LogFile $LogFile -ErrorLogFile $ErrorLogFile -ExcludePattern $ExcludePattern -MaxDepth ($MaxDepth - 1) -TimeLimit $TimeLimit
        }
    }

    end {
        if ($global:matchCount -gt 0 -or $global:errorCount -gt 0) {
            Write-Host "Search complete. Matches found: $global:matchCount, Errors encountered: $global:errorCount" -ForegroundColor Green
        }
    }
}

Export-ModuleMember -Function Find-Regex
