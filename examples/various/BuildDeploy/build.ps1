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

<#
.SYNOPSIS
Starts the build process. 

.DESCRIPTION
It imports PSCI library and packages projects according to the commands in the 'try' block. The packages will be stored at $PackagesPath.

.PARAMETER ProjectRootPath
Base directory of the project, relative to the directory where this script resides. It is used as a base directory for other directories.
  
.PARAMETER PSCILibraryPath
Base directory where PSCI library resides, relative to $ProjectRootPath.

.PARAMETER PackagesPath
Path to the directory where packages will be created, relative to $ProjectRootPath.

.PARAMETER DeployConfigurationPath
Path to the directory where configuration files reside, relative to $ProjectRootPath. By default '<script directory>\deploy'.

.PARAMETER Tasks
List of tasks (function names) to invoke for this build. If this is not specified, default task will be invoked (Build-All).

.PARAMETER Version
Version number of the current build.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]
    $ProjectRootPath = '..', # Modify this path according to your project structure. This is relative to the directory where build.ps1 resides ($PSScriptRoot).
    
    [Parameter(Mandatory=$false)]
    [string]
    $PSCILibraryPath = '..\..\PSCI', # Modify this path according to your project structure. This is absolute or relative to $ProjectRootPath.

    [Parameter(Mandatory=$false)]
    [string]
    $PackagesPath = 'bin', # Modify this path according to your project structure. This is absolute or relative to $ProjectRootPath.

    [Parameter(Mandatory=$false)]
    [string]
    $DeployConfigurationPath = '', # Modify this path according to your project structure. This is absolute or relative to $ProjectRootPath (by default '<script directory>\deploy')
    [Parameter(Mandatory=$false)]
    [string[]]
    $Tasks, # This can be used to run partial builds (if not empty, specified functions will be run instead of Build-All)
    
    [Parameter(Mandatory=$false)]
    [string]
    $Version # This should be passed from your CI server
)

$global:ErrorActionPreference = 'Stop'

try {
    ############# PSCI initialization
    Push-Location -Path $PSScriptRoot

    $PSCIResolvedPath = ''
    if ($PSCILibraryPath) { 
        if (![System.IO.Path]::IsPathRooted($PSCILibraryPath)) {
            $PSCILibraryPath = Join-Path -Path $ProjectRootPath -ChildPath $PSCILibraryPath
        }
        if (Test-Path -LiteralPath "$PSCILibraryPath\PSCI.psd1") {
            $PSCIResolvedPath = "$PSCILibraryPath\PSCI.psd1"
        } else {
            Write-Host -Object "Cannot find PSCI library at '$PSCILibraryPath' (current dir: '$PSScriptRoot')."
     
        }
    }

    if (!$PSCIResolvedPath -and (Test-Path -LiteralPath "$PSScriptRoot\packages\PSCI")) {
        $PSCIResolvedPath = Get-ChildItem -Path "$PSScriptRoot\packages\PSCI" -Include 'PSCI.psd1' -File -Recurse -Depth 2 | Select-Object -ExpandProperty FullName -First 1
    }

    if (!$PSCIResolvedPath) {
        if ((Get-Module -Name PSCI -ListAvailable)) {
            Write-Host -Object "PSCI found installed as global module - importing."
            Import-Module -Name PSCI
            $PSCIResolvedPath = ''
        } else {
            Write-Host -Object "Downloading PSCI from Powershell Gallery."
            if (!(Get-PackageProvider | Where-Object { $_.Name -eq 'NuGet' })) {
                Install-PackageProvider -Name NuGet -force | Out-Null
            }
            Import-PackageProvider -Name NuGet -force | Out-Null
            if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            }
            [void](New-Item -Path "$PSScriptRoot\packages" -ItemType Directory -ErrorAction SilentlyContinue)
            Save-Module -Name 'PSCI' -LiteralPath "$PSScriptRoot\packages"
            $PSCIResolvedPath = Get-ChildItem -Path "$PSScriptRoot\packages\PSCI" -Include 'PSCI.psd1' -File -Recurse -Depth 2 | Select-Object -ExpandProperty FullName -First 1
        }
    }

    if ($PSCIResolvedPath) {
        $PSCIResolvedPath = (Resolve-Path -Path $PSCIResolvedPath).ProviderPath
        Write-Host -Object "PSCI library found at '$PSCIResolvedPath'."
        Import-Module -Name $PSCIResolvedPath -Force 
    }

    if (!(Get-Module -Name PSCI)) {
        Write-Host "Failed to find PSCI library and get it from Powershell Gallery. Please try changing `$PSCILibraryPath variable."
        exit 1 
    }

    ############# Running build
    try { 
        $PSCIGlobalConfiguration.LogFile = "$PSScriptRoot\build.log.txt"
        Remove-Item -LiteralPath $PSCIGlobalConfiguration.LogFile -ErrorAction SilentlyContinue

        Initialize-ConfigurationPaths -ProjectRootPath $ProjectRootPath -PackagesPath $PackagesPath -DeployConfigurationPath $DeployConfigurationPath
        if (!$Tasks) { 
            Remove-PackagesDir
        }

        <# 
          All powershell files available at 'build' directory will be included and custom functions will be invoked based on $Tasks variable.
          For example if $Tasks = 'Build-Package1', 'Build-Package2', functions 'Build-Package1' and 'Build-Package2' will be invoked.
          If $Tasks is null, default task will be invoked (Build-All).
          Any additional parameters in build.ps1 will be automatically passed to custom build functions.
        #>
        $cmdName = $PSCmdlet.MyInvocation.MyCommand.Path
        Write-Log -Info "Starting build at '$cmdName'" -Emphasize
        $buildParams = (Get-Command -Name $cmdName).ParameterSets[0].Parameters | Where-Object { $_.Position -ge 0 } | Foreach-Object { Get-Variable -Name $_.Name }

        Start-Build -BuildParams $buildParams -ScriptsDirectory 'build' -DefaultTask 'Build-All'
    } catch {
        Write-ErrorRecord -ErrorRecord $_
    }
} finally {
    Pop-Location
}