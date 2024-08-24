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
                $matchedText = $null
                if ($File -and $item.Attributes -match 'Archive') {
                    if ($item.FullName -match $RegexPattern) {
                        $isMatch = $true
                        $matchedText = $Matches[0]
                    }
                } elseif ($Folder -and $item.Attributes -match 'Directory') {
                    if ($item.FullName -match $RegexPattern) {
                        $isMatch = $true
                        $matchedText = $Matches[0]
                    }
                } elseif ($FileName -and $item.Name -match $RegexPattern) {
                    $isMatch = $true
                    $matchedText = $Matches[0]
                } elseif (-not $File -and -not $Folder -and -not $FileName) {
                    if ($item.FullName -match $RegexPattern) {
                        $isMatch = $true
                        $matchedText = $Matches[0]
                    }
                }

                # Log and print matches
                if ($isMatch) {
                    $global:matchCount++
                    if ($LogFile) {
                        Add-Content -Path $LogFile -Value "Match found: $($item.FullName)"
                    }

                    $highlightedPath = $item.FullName -replace [regex]::Escape($matchedText), "`e[36m$matchedText`e[0m"

                    Write-Host "File match: " -ForegroundColor Green -NoNewline
                    Write-Host "$highlightedPath" -NoNewline

                    # Prompt the user if a match is found
                    if (-not $AutoContinue) {
                        $response = Read-Host " Match found. Do you want to continue searching? (Y/N) Exclude this pattern from further search? (E)"
                        if ($response -eq 'N') {
                            return
                        } elseif ($response -eq 'E') {
                            $ExcludePattern = [regex]::Escape($item.FullName)
                        }
                    } else {
                        Write-Host ""
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
            Find-Regex -RegexPattern $RegexPattern -DirectoryPath $subdir.FullName -File:$File -Folder:$Folder -FileName:$FileName -AutoContinue:$AutoContinue -LogFile $LogFile -ErrorLogFile $ErrorLogFile -ExcludePattern $ExcludePattern -MaxDepth ($MaxDepth - 1) -TimeLimit $TimeLimit
        }
    }

    end {
        if ($global:matchCount -gt 0 -or $global:errorCount -gt 0) {
            Write-Host "Search complete. " -ForegroundColor Cyan -NoNewline
            Write-Host "Matches found: $global:matchCount, Errors encountered: $global:errorCount" -ForegroundColor Yellow
        }
    }
}

Export-ModuleMember -Function Find-Regex
