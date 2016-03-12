# PkgMgr: Windows Package Manager with PackageManagement.

#The MIT License (MIT)
#
#Copyright (c) 2016 rcmdnk
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

<#
  .SYNOPSIS
  Windows Package Manager with PackageManagement.
  .DESCRIPTION
  Windows Package Manager with PackageManagement using "pkg.config" file.
  .LINK
  https://github.com/rcmdnk/WinPkgMgr
  .NOTES
  Author  : rcmdnk
  Date    : 13/Mar/2016
  Version : 0.0.1
  .PARAMETER command
  command (init | install | show | set_repo | pull | push | update)

  init     : Initialize the package management file with installed packages.
  install  : Install all packages in the package management file.
  show     : Show the package management file place and packages in the file.
  set_repo : Set GitHub repository for the package management file.
  pull     : Pull GitHub repository.
  push     : Push GitHub repository.
  update   : (pull +) install + init (+ push)
  .PARAMETER providers
  Provider names to get packages for init (msu | msi | Programs | Chocolatey | NuGet | PowerShellGet)
  .PARAMETER pkgFile
  Package management file (default: 'C:\Users\<user>\Documents\pkg.txt')
  Default value can be changed by the environmental value of $PkgMgrFile.
  .PARAMETER repo
  Repository at 'set_repo', otherwise ignored.
  .EXAMPLE
  PkgMgr.ps1 init -provider Chocolatey, NuGet
  .EXAMPLE
  PkgMgr.ps1 install -pkgFile C:\Users\rcmdnk\Documents\Dropbox\pkg.txt
  .EXAMPLE
  PkgMgr.ps1 set_repo -repo rcmdnk/WimPkgMgrFile
  .EXAMPLE
  PkgMgr.ps1 update
#>

[CmdletBinding()]
Param([string] $command='',
      [array] $providers=@('chocolatey'),
      [string] $pkgFile="$HOME\Documents\pkg.txt",
      [string] $repo="")

Write-Verbose ""
Write-Verbose "*** Using provider : $providers"
Write-Verbose "*** Using pkgFile  : $pkgFile"
Write-Verbose "*** Command        : $command"
Write-Verbose ""

# Other script variables
$pkgCntFile = $pkgFile
$packages = @{}

function Check-File($file){
  if($DebugPreference -eq "SilentlyContinue"){
    if(Test-Path -PathType Container $file){
      Write-Error "$file is folder, please check your package management file."
      exit
    }
    New-Item -Force -ItemType Directory $(Split-Path $file) > $null
    if(-not (Test-Path -PathType Leaf $file)){
      New-Item -ItemType File $file > $null
    }
  }
}

function Write-File($file, $out){
  Check-File $file
  if($DebugPreference -eq "SilentlyContinue"){
    Write-Output "$out"| Out-File -FilePath $file -Encoding Ascii
  }else{
    Write-Output ""
    Write-Output "Write to $file"
    Write-Output "$out"
    Write-Output ""
  }
}

function Read-Packages($file=$pkgFile){
  $script:repo = ""
  return Read-Packages-Core $file
}

function Read-Packages-Core($file=$pkgFile){
  $packages = @{}
  Check-File $file
  foreach($l in Get-Content $file){
    if($l -match "^ *#"){
      continue
    }
    if($l -match "#"){
      $l = $l.Split("#")[0]
    }
    $values = -split $l
    if($values.Length -lt 2){
      Write-Warning "Wrong line: $l, ignore"
      continue
    }
    if($values[0] -eq "git:repository"){
      $script:repo = $values[1]
      $dir = "$(Split-Path $file)\$($values[1].Replace("/", "\"))"
      $script:pkgCntFile = "$dir\pkg.txt"
      if(-not (Test-Path $dir)){
        return @{}
      }
      return Read-Packages-Core $script:pkgCntFile
    }
    $packages[$values[0]] = $values[1]
  }
  return $packages
}

function Show-Packages {
  $packages = Read-Packages
  ""
  if($script:pkgCntFile -eq $script:pkgFile){
    "Package management file: $script:pkgFile"
  }else{
    "Package management file: $script:pkgFile"
    "Using git repository file: $script:pkgCntFile"
  }
  ""
  "{0, -30} {1, -30}" -f "Package", "Provider"
  "{0, -30} {1, -30}" -f "-------", "--------"
  foreach($k in $packages.keys){
    "{0, -30} {1, -30}" -f $k, $packages[$k]
  }
  ""
}

function Get-Packages {
  $packages = @{}
  foreach($provider in $providers){
    foreach($p in Get-Package -ProviderName $provider| % {$_.Name}){
      $packages[$p] = $provider
    }
  }
  $packages
}

function Save-Packages {
  $packages_notuse = Read-Packages
  $packages = Get-Packages
  $output = ""
  foreach($k in echo $packages.keys|sort){
    if("$output" -eq ""){
      $output = "{0, -30} {1}" -f $k, $packages[$k]
    }else{
      $output += "`n{0, -30} {1}" -f $k, $packages[$k]
    }
  }
  Write-Verbose ""
  Write-Verbose $output
  Write-Verbose ""
  Write-File $pkgCntFile $output
}

function Install-Packages {
  $installedPackages = Get-Packages
  $packages = Read-Packages
  foreach($k in $packages.keys){
    if($installedPackages.keys -contains $k){
      continue
    }

    Write-Verbose $("Install-Package {0} -ProviderName {1}" -f $k, $packages[$k])
    if("$DebugPreference" -eq "SilentlyContinue"){
      Install-Package $k -ProviderName $packages[$k]
    }
  }
}

function Check-Git {
  $git_cmd = gcm git 2> $null
  if("$git_cmd" -eq ""){
    $git_path = $Env:Path | Select-String "Git"
    if("$git_path" -eq ""){
      Write-Verbose 'Set Git Path to $Env:Path'
      $Env:Path += ";${Env:ProgramFiles(x86)}\Git\bin;$Env:ProgramFiles\Git\bin\"
    }
    $git_cmd = gcm git 2> $null
    $git_install = $FALSE
    if("$git_cmd" -eq ""){
      $choco_provider = Get-PackageProvider Chocolatey 2> $null
      if("$choco_provider" -eq ""){
        Write-Verbose 'Get-PackageProvider Chocolatey -ForceBootstrap'
        Get-PackageProvider Chocolatey -ForceBootstrap > $null
      }
      $git_install = $TRUE
      Write-Verbose 'Install-Package git -ProviderName chocolatey'
      Install-Package git -ProviderName chocolatey
    }
    $git_cmd = gcm git 2> $null
    if("$git_cmd" -eq ""){
      Write-Error "Could not find nor install git."
      if($git_install){
        Write-Error "    Install-Package git -providerName chocolatey"
        Write-Error "was tried, but failed."
      }
      exit
    }
  }
}

function Set-Repository {
  if($repo -eq ""){
    $repo = Read-Host "Please enter your repository"
  }
  if($repo -eq ""){
    exit
  }
  Write-Verbose "Set repository as $repo"
  Write-File $pkgFile "git:repository $repo"
  $dir = "$(Split-Path $pkgFile)\$($repo.Replace("/", "\"))"
  Write-Verbose "Make directory of $(Split-Path $dir)"
  New-Item -Force -ItemType Directory $(Split-Path $dir) > $null
  if(-not (Test-Path $dir)){
    Check-Git
    Write-Verbose "git clone 'git@github.com:$repo' '$dir'"
    git clone "git@github.com:$repo" "$dir"
    if(-not $?){
      Write-Error @"
      Failed to execute a command:
> git clone 'git@github.com:$repo' '$dir'
Please check $repo and git environments.
"@
      exit
    }
  }
  $script:pkgCntFile = "$dir\pkg.txt"
}

function Git-Command ($git_command) {
  if(($git_command -ne "pull") -And ($git_command -ne "push")){
    Write-Error "Git-Command arguments must be 'pull' or 'push'"
    exit
  }
  $packages_notuse = Read-Packages
  if($repo -eq ""){
    Write-Warning "Repository is not used."
    exit
  }
  Check-Git
  $dir = "$(Split-Path $pkgCntFile)"
  Push-Location $dir
  Write-Verbose "git $git_command"
  git $git_command
  if(-not $?){
    Write-Error @"
    Failed to execute a command:
> git $git_command
Please check $repo and git environments.
"@
    Pop-Location
    exit
  }
  Pop-Location
}

function Update-Packages {
  $packages = Read-Packages
  if($repo -ne ""){
    Git-Command "pull"
  }
  Install-Packages
  Save-Packages
  if($repo -ne ""){
    Git-Command "push"
  }
}

switch($command){
  "init"{
    Save-Packages
  }"show"{
    Show-Packages
  }"install"{
    Install-Packages
  }"set_repo"{
    Set-Repository
  }"pull"{
    Git-Command "pull"
  }"push"{
    Git-Command "push"
  }"update"{
    Update-Packages
  }default{
    Write-Error "Command '$command' is not available. Use 'init', 'show', 'install' or 'set_repo'"
  }
}
