function Execute ($command) {
  Write-Host "> $command"
  Invoke-Expression $command
  Write-Host ""
}

Execute "Remove-Item -Force $HOME\Documents\pkg.txt"
Execute ".\bin\PkgMgr.ps1 init"
Execute ".\bin\PkgMgr.ps1 init"
Execute ".\bin\PkgMgr.ps1 show"
Execute ".\bin\PkgMgr.ps1 install"
Execute ".\bin\PkgMgr.ps1 update"
Execute ".\bin\PkgMgr.ps1 set_repo -repo rcmdnk/WinPkgMgrFile"
Execute "Remove-Item -Recurse -Force $HOME\Documents\rcmdnk"
Execute ".\bin\PkgMgr.ps1 set_repo -repo rcmdnk/WinPkgMgrFile"
Execute ".\bin\PkgMgr.ps1 pull"
Execute ".\bin\PkgMgr.ps1 push"
Execute ".\bin\PkgMgr.ps1 update"
