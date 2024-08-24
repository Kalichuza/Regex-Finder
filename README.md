# Regex-Finder

## Overview

`Regex-Finder` is a PowerShell module that provides a function `Find-Regex` to recursively search for files or folders by name using a regex pattern. The module includes options to narrow down the search based on file type, folder, or file name.

## Installation

To install the module, copy the `Regex-Finder` folder to one of your PowerShell module directories:
- `$HOME\Documents\WindowsPowerShell\Modules`
- `C:\Program Files\WindowsPowerShell\Modules`

## Usage

### Example 1: Search for Files by Name

```powershell
Find-Regex -RegexPattern "\bProject\b" -DirectoryPath "C:\Projects" -File
