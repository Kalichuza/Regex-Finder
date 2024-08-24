# Find-Regex Module

The `Find-Regex` module is a PowerShell tool designed to search for files, folders, or specific patterns within file names or contents using regular expressions. It is a versatile tool that can help you locate specific data across directories and subdirectories based on powerful and flexible pattern matching.

## Installation

To install the `Find-Regex` module, simply download the `.psm1` file and import it into your PowerShell session:

```powershell
Import-Module .\Find-Regex.psm1
```

## Usage

The `Find-Regex` function provides various options to search files, folders, or file names based on regular expressions. Below are the available parameters and their descriptions:

### Parameters

- **`RegexPattern`** (Mandatory): The regular expression pattern to search for.
- **`DirectoryPath`** (Mandatory): The directory to start searching in.
- **`File`** (Switch): Search within file contents.
- **`Folder`** (Switch): Search within folder names.
- **`FileName`** (Switch): Search within file names.
- **`AutoContinue`** (Switch): Automatically continue the search without prompting for user input.
- **`LogFile`**: The path to a log file where matches will be recorded.
- **`ErrorLogFile`**: The path to an error log file where errors will be recorded.
- **`ExcludePattern`**: A pattern to exclude from the search.
- **`MaxDepth`**: Maximum depth of subdirectory traversal.
- **`TimeLimit`**: The maximum time to spend on the search.

### Examples

Below are examples of how to use the `Find-Regex` tool for different types of searches.

### Example 1: Search for a Specific Word in File Contents

Search for the word `ERROR` in all files under the `C:\Logs` directory:

```powershell
Find-Regex -RegexPattern "\bERROR\b" -DirectoryPath "C:\Logs" -File
```

### Example 2: Search for a Word in File Names

Search for files with `CONFIDENTIAL` in their names within the `C:\Users` directory:

```powershell
Find-Regex -RegexPattern "CONFIDENTIAL" -DirectoryPath "C:\Users" -FileName
```

### Example 3: Search for a Pattern in Folder Names

Search for folders with names ending in `_backup` within the `C:\Projects` directory:

```powershell
Find-Regex -RegexPattern "_backup$" -DirectoryPath "C:\Projects" -Folder
```

### Example 4: Search for a Specific String in File Contents Across Subdirectories

Search for the string `Database Connection Failed` in all `.log` files, and automatically continue searching without prompting:

```powershell
Find-Regex -RegexPattern "Database Connection Failed" -DirectoryPath "C:\Logs" -File -AutoContinue
```

### Example 5: Exclude Certain Files from the Search

Search for the string `Timeout` in `.log` files under `C:\Logs`, but exclude any file names containing `old`:

```powershell
Find-Regex -RegexPattern "Timeout" -DirectoryPath "C:\Logs" -File -ExcludePattern "old"
```

### Example 6: Search with Logging to a File

Search for the pattern `CRITICAL ERROR` and log all matches to `C:\Logs\critical_errors.log`:

```powershell
Find-Regex -RegexPattern "CRITICAL ERROR" -DirectoryPath "C:\Logs" -File -LogFile "C:\Logs\critical_errors.log"
```

### Example 7: Recursive Search with Maximum Depth

Search for `TODO` comments in code files under `C:\Projects`, but only traverse 2 levels of subdirectories:

```powershell
Find-Regex -RegexPattern "TODO" -DirectoryPath "C:\Projects" -File -MaxDepth 2
```

### Example 8: Search with a Time Limit

Search for the word `ERROR` in log files, but stop the search after 5 minutes:

```powershell
Find-Regex -RegexPattern "\bERROR\b" -DirectoryPath "C:\Logs" -File -TimeLimit ([TimeSpan]::FromMinutes(5))
```

