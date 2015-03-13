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

function Stop-Execution {
    <#
    .SYNOPSIS
    Stops execution of the script. 

    .DESCRIPTION
    In console it will run 'exit 1' to ensure proper exit code is returned. In other environments (e.g. ISE) it will just throw an exception.

    .EXAMPLE
    Stop-Execution
    #>

    [CmdletBinding()]
    [OutputType([void])]
    param()

    if ($Global:ProgressErrorMessage) {
        Write-ProgressExternal -Message $Global:ProgressErrorMessage -MessageType Problem
    }

    if ($Global:PSCIGlobalConfiguration.ExitImmediatelyOnError) {
        exit 1
    } else {
        throw "Execution stopped due to an error or on demand."
    }
}