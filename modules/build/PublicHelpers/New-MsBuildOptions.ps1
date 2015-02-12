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

function New-MsBuildOptions {
     <#
	.SYNOPSIS
	Creates a new object containing options for Invoke-MsBuild.

    .PARAMETER Targets
    List of msbuild targets to invoke.

    .PARAMETER Configuration
    Build configuration (e.g. Release)

    .PARAMETER MsBuildProperties
    List of additional properties to pass to msbuild.

    .PARAMETER VisualStudioVersion
    Can be used to select specific Visual Studio version. The newest available in the system will be used if not provided.
    It is used for convenience only to select proper MsBuildVersion (see $MsBuildVersion).
    VisualStudioVersion will take precedence over MsBuildVersion if both are specified.
    The newest available in the system will be used if both $VisualStudioVersion and $MsBuildVersion are not provided.

    .PARAMETER MsBuildVersion
    Version of MsBuild use. VisualStudioVersion will take precedence over MsBuildVersion if both are specified.
    The newest available in the system will be used if both $VisualStudioVersion and $MsBuildVersion are not provided.

    .PARAMETER MsBuildForceArchitecture
    If specified, the provided architecture will be forced (e.g. msbuild x86 will be used even though msbuild x64 is available).

    .EXAMPLE
    New-MsBuildOptions -Targets "Build" -Configuration "Release"

    #>
    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory=$false)]
        [string[]]
        $Targets = "Rebuild",

        [Parameter(Mandatory=$false)]
        [string]
        $Configuration = "Release",

        [Parameter(Mandatory=$false)]
        [hashtable]
        $MsBuildProperties = @{},

        [Parameter(Mandatory=$false)]
        [string]
        [ValidateSet("2013","2012","2010","")]
        $VisualStudioVersion,

        [Parameter(Mandatory=$false)]
        [string]
        [ValidateSet("12.0","4.0","3.5","2.0","")]
        $MsBuildVersion,

        [Parameter(Mandatory=$false)]
        [string]
        [ValidateSet("x86","x64","")]
        $MsBuildForceArchitecture

    )
    return [PSObject]@{
        Targets = $Targets;
        Configuration = $Configuration;
        MsBuildProperties = $MsBuildProperties;
        VisualStudioVersion = $VisualStudioVersion;
        MsBuildVersion = $MsBuildVersion
        MsBuildForceArchitecture = $MsBuildForceArchitecture;
    }
}
