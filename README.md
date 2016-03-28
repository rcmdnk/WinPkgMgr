# WinPkgMgr

Windows Package Manager with [PackageManagement](https://technet.microsoft.com/en-us/library/mt422622.aspx).

Packages are stored in the package management file,
and you can install packages in the file with one command.

The file can be managed with cloud storage (e.g. Dropbox) or GitHub repository.

# pkg.txt example

    adobereader                    chocolatey
    autohotkey                     chocolatey
    autohotkey.install             chocolatey
    autohotkey.portable            chocolatey
    Cygwin                         chocolatey
    dropbox                        chocolatey
    Evernote                       chocolatey
    Firefox                        chocolatey
    flashplayerplugin              chocolatey
    git                            chocolatey
    git.install                    chocolatey
    GoogleChrome                   chocolatey
    GoogleJapaneseInput            chocolatey
    lhaplus                        chocolatey
    MobaXTerm                      chocolatey
    putty                          chocolatey
    putty.portable                 chocolatey
    skype                          chocolatey
    teamviewer                     chocolatey
    vim                            chocolatey

# Requirement

* [PackageManagement](https://technet.microsoft.com/en-us/library/mt422622.aspx)

It is pre-installed in Windows 10.

For older Windows version, download PackageManagement PowerShell Modules Preview from
[Download PackageManagement PowerShell Modules Preview from Official Microsoft Download Center](https://www.microsoft.com/en-us/download/details.aspx?id=49186).

* Enable to run scripts

Launch PowerShell as administrator ("Run as administrator"),
and execute:

    > Set-ExecutionPolicy RemoteSigned

> [Set-ExecutionPolicy](https://technet.microsoft.com/ja-jp/library/hh849812.aspx)


# Install

Copy/Download [PkgMgr.ps1](https://raw.githubusercontent.com/rcmdnk/WinPkgMgr/master/bin/PkgMgr.ps1)
and place it in $PATH, or call it directly in PowerShell.

# Usage

    PkgMgr.ps1 [[-command] <String>] [[-providers] <Array>] [[-pkgFile] <String>] [[-repo] <String>] [<CommonParameters>]

Command  | Description
:--------| :----------
init     | Initialize the package management file with installed packages.
install  | Install all packages in the package management file.
show     | Show the package management file place and packages in the file.
set_repo | Set GitHub repository for the package management file.
pull     | Pull GitHub repository.
push     | Push GitHub repository.
update   | (pull +) install + init (+ push). `pull`, `push` only when GitHub repository is used.

Option   | Description
:--------| :----------
providers| Provider names to get packages for `init` (msu, msi, Programs, Chocolatey, NuGet, PowerShellGet). Multiple providers can be set like `-providers Chocolatey, NuGet`.
pkgFile  | Package management file (default: 'C:\Users\<user>\Documents\pkg.txt'). Default value can be changed by the environmental value of $PkgMgrFile.
repo     | GitHub repository for `set_repo` command.

## Make package list at current machine and apply to the new machine

In the machine which you are currently using,
initialize the package management file with:

    > PkgMgr.ps1 init

Then **C:\Users\<user>\Documents\pkg.txt** is created with a packages list.

Copy pkg.txt to your new machine and place it to
**C:\Users\<user>\Documents\pkg.txt**, then

    > PkgMgr.ps1 install

or

    > PkgMgr.ps1 install -pkgFile Path\To\pkgFile

All packages in the package management file will be installed in your new machine.

## Manage with Dropbox

You can use a cloud storage like Dropbox to synchronize your package management file.

Write out packages:

    > PkgMgr.ps1 init -pkgMgr $HOME\Documents\Dropbox\pkg.txt

Install packages:

    > PkgMgr.ps1 install -pkgMgr $HOME\Documents\Dropbox\pkg.txt

If you execute `update` regularly in several machines,
all machines can have same packages.

> [Weekend Scripter: Use the Windows Task Scheduler to Run a Windows PowerShell Script | Hey, Scripting Guy! Blog](https://blogs.technet.microsoft.com/heyscriptingguy/2012/08/11/weekend-scripter-use-the-windows-task-scheduler-to-run-a-windows-powershell-script/)

Or you can set the environment variable.
Add

    $PkgMgrFile = C:\Users\<user>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

in **C:\Users\<user>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1**.

Then, you can use `PkgMgr.ps1` w/o `-pkgMgr`.

## Manage with GitHub repository

Prepare GitHub repository like [WinPkgMgrFile](https://github.com/rcmdnk/WinPkgMgrFile),
which can be empty repository.

Prepare your git environment so that you can push your update.

* [Git for Windows](https://git-for-windows.github.io/)
* [GitHub Desktop - Simple collaboration from your desktop](https://desktop.github.com/)
* You can also setup ssh-key with [Cygwin](https://www.cygwin.com/).

Then, set a repository like

    > PkgMgr.ps1 set_repo -repo rcmdnk/WinPkgMgr

**C:\Users\<user>\Documents\pkg.txt** will have a content like:

    git:repository rcmdnk/WinPkgMgrFile

and repository will be clone in
**C:\Users\<user>\Documents\rcmdnk\WinPkgMgrFile**.

If the repository already has **pkg.txt**, do

    > PkgMgr.ps1 install

If it is a first time, do

    > PkgMgr.ps1 init
    > PkgMgr.ps1 push

This will update the repository in GitHub.

If you execute `update` regularly in several machines,
all machines can have same packages
and the repository is kept up-to-date.

> [Weekend Scripter: Use the Windows Task Scheduler to Run a Windows PowerShell Script | Hey, Scripting Guy! Blog](https://blogs.technet.microsoft.com/heyscriptingguy/2012/08/11/weekend-scripter-use-the-windows-task-scheduler-to-run-a-windows-powershell-script/)

# Full HELP

    PS C:\> Get-Help -full PkgMgr.ps1
    NAME
        PkgMgr.ps1

    SYNOPSIS
        Windows Package Manager with PackageManagement.

    SYNTAX
        PkgMgr.ps1 [[-command] <String>] [[-providers] <Array>] [[-pkgFile] <String>] [[-repo] <String>] [<CommonParameters>]

    DESCRIPTION
        Windows Package Manager with PackageManagement using "pkg.config" file.

    PARAMETERS
        -command <String>
            command (init | install | show | set_repo | pull | push | update)

            init     : Initialize the package management file with installed packages.
            install  : Install all packages in the package management file.
            show     : Show the package management file place and packages in the file.
            set_repo : Set GitHub repository for the package management file.
            pull     : Pull GitHub repository.
            push     : Push GitHub repository.
            update   : (pull +) install + init (+ push)

            Required?                    false
            Position?                    1
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?  false

        -providers <Array>
            Provider names to get packages for init (msu | msi | Programs | Chocolatey | NuGet | PowerShellGet)

            Required?                    false
            Position?                    2
            Default value                @('chocolatey')
            Accept pipeline input?       false
            Accept wildcard characters?  false

        -pkgFile <String>
            Package management file (default: 'C:\Users\<user>\Documents\pkg.txt')
            Default value can be changed by the environmental value of $PkgMgrFile.

            Required?                    false
            Position?                    3
            Default value                "$HOME\Documents\pkg.txt"
            Accept pipeline input?       false
            Accept wildcard characters?  false

        -repo <String>
            Repository at 'set_repo', otherwise ignored.

            Required?                    false
            Position?                    4
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?  false

        <CommonParameters>
            This cmdlet supports the common parameters: Verbose, Debug,
            ErrorAction, ErrorVariable, WarningAction, WarningVariable,
            OutBuffer, PipelineVariable, and OutVariable. For more information, see
            about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

    INPUTS

    OUTPUTS

    NOTES

            Author  : rcmdnk
            Date    : 13/Mar/2016
            Version : 0.0.1

        -------------------------- EXAMPLE 1 --------------------------

        PS C:\>PkgMgr.ps1 init -provider Chocolatey, NuGet

        -------------------------- EXAMPLE 2 --------------------------

        PS C:\>PkgMgr.ps1 install -pkgFile C:\Users\rcmdnk\Documents\Dropbox\pkg.txt

        -------------------------- EXAMPLE 3 --------------------------

        PS C:\>PkgMgr.ps1 set_repo -repo rcmdnk/WimPkgMgrFile

        -------------------------- EXAMPLE 4 --------------------------

        PS C:\>PkgMgr.ps1 update

    RELATED LINKS
        https://github.com/rcmdnk/WinPkgMgr
