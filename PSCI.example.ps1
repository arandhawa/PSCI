<#
The MIT License (MIT)

Copyright (c) 2015 Objectivity Bespoke Software Specialists

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

# This file can be used for testing PSCI usage
$global:ErrorActionPreference = "Stop"

$currentDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Import-Module -Name (Join-Path -Path $currentDir -ChildPath "PSCI.psm1") -Force

# If you uncomment this line, all log messages will be saved to C:\test.txt. See more PSCIGlobalConfiguration properties in PSCI.configuration.default.ps1.
$PSCIGlobalConfiguration.LogFile = 'C:\test.txt'

try {
	# Put your code here
	
	# Install-DscResources
} catch {
    Write-ErrorRecord
}