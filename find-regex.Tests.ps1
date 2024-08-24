# find-regex.Tests.ps1

Describe 'Find-Regex Function Tests' {
    
    # This block runs before all tests
    BeforeAll {
        # Set up a test directory and files
        $testDir = "C:\TestFindRegex"
        if (-Not (Test-Path -Path $testDir)) {
            New-Item -Path $testDir -ItemType Directory -Force | Out-Null
        }

        # Create files for testing
        New-Item -Path "$testDir\match.log" -ItemType File -Force | Out-Null
        New-Item -Path "$testDir\nomatch.txt" -ItemType File -Force | Out-Null
        New-Item -Path "$testDir\error.txt" -ItemType File -Force | Out-Null
        New-Item -Path "$testDir\subdir" -ItemType Directory -Force | Out-Null
        New-Item -Path "$testDir\subdir\submatch.log" -ItemType File -Force | Out-Null
    }

    # Test case: Output match to console
    It 'Should output the match to the console' {
        $output = & {
            Find-Regex -RegexPattern 'match' -DirectoryPath $testDir -File -AutoContinue
        } | Out-String
        
        $output | Should -Contain "File match: $testDir\match.log"
    }

    # Test case: Create log file when match is found
    It 'Should create the log file when a match is found' {
        $logFile = "$testDir\logfile.txt"
        Find-Regex -RegexPattern 'match' -DirectoryPath $testDir -File -LogFile $logFile -AutoContinue

        Test-Path -Path $logFile | Should -Be $true
        Get-Content -Path $logFile | Should -Contain "Match found: $testDir\match.log"
    }

    # Test case: Handle no matches and no log file creation
    It 'Should handle no matches and not create a log file' {
        $logFile = "$testDir\logfile_nomatch.txt"
        Find-Regex -RegexPattern 'nomatchpattern' -DirectoryPath $testDir -File -LogFile $logFile -AutoContinue

        Test-Path -Path $logFile | Should -Be $false
    }

    # Test case: Handle errors and log them to an error log file
    It 'Should log the error to the error log file' {
        $errorLogFile = "$testDir\error_log.txt"
        Find-Regex -RegexPattern 'error' -DirectoryPath $testDir -File -ErrorLogFile $errorLogFile -AutoContinue

        Test-Path -Path $errorLogFile | Should -Be $true
        $errorContent = Get-Content -Path $errorLogFile
        $errorContent | Should -Contain "Error accessing: $testDir\error.txt"
    }

    # Test case: Output errors to the console
    It 'Should output the error to the console' {
        $output = & {
            Find-Regex -RegexPattern 'error' -DirectoryPath $testDir -File -AutoContinue
        } | Out-String

        $output | Should -Contain "Error accessing: $testDir\error.txt"
    }

    # Test case: Find matches in subdirectories
    It 'Should find matches in subdirectories' {
        $logFile = "$testDir\subdir_log.txt"
        Find-Regex -RegexPattern 'submatch' -DirectoryPath $testDir -File -LogFile $logFile -AutoContinue

        Test-Path -Path $logFile | Should -Be $true
        Get-Content -Path $logFile | Should -Contain "Match found: $testDir\subdir\submatch.log"
    }

    # Test case: AutoContinue functionality
    It 'Should not prompt when AutoContinue is specified' {
        $output = & {
            Find-Regex -RegexPattern 'match' -DirectoryPath $testDir -File -AutoContinue
        } | Out-String

        $output | Should -Contain "File match: $testDir\match.log"
    }

    # This block runs after all tests
    AfterAll {
        # Cleanup test directory
        Remove-Item -Path $testDir -Recurse -Force
    }
}
