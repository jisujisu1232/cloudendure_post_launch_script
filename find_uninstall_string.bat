::It extracts software software GUID, then use the GUID to search the name and version
@echo off
setlocal ENABLEDELAYEDEXPANSION


set x64reg=%SystemRoot%\Sysnative\reg.exe
set x86GUID=HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
set x64GUID=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall

set SoftwareName=%1
set SoftwareName=%SoftwareName:"=%
echo %SoftwareName%

REM It's faster to first locate the software GUID, then search it's Name, Version & UninstallString
for /f "delims=" %%P in ('%x64reg% query "%x64GUID%" /s /f "%SoftwareName%" 2^>nul ^| findstr "HKEY_LOCAL_MACHINE"') do (
  %x64reg% query "%%P" /v "UninstallString" 2>nul && (
    for /f "tokens=2*" %%A in ('%x64reg% query "%%P" /v "UninstallString" 2^>nul ^|findstr "UninstallString"') do (
        set MsiStr=%%B
        echo !MsiStr!
    )
  )
)

if not defined MsiStr (
    for /f "delims=" %%P in ('reg query "%x64GUID%" /s /f "%SoftwareName%" 2^>nul ^| findstr "HKEY_LOCAL_MACHINE"') do (
      reg query "%%P" /v "UninstallString" 2>nul && (
        for /f "tokens=2*" %%A in ('reg query "%%P" /v "UninstallString" 2^>nul ^|findstr "UninstallString"') do (
            set MsiStr=%%B
            echo !MsiStr!
        )
      )
    )
)

if not defined MsiStr (
  for /f "delims=" %%P in ('reg query "%x86GUID%" /s /f "%SoftwareName%" 2^>nul ^| findstr "HKEY_LOCAL_MACHINE"') do (
	  echo %%P
	  reg query "%%P" /v "UninstallString" 2>nul && (
		for /f "tokens=2*" %%A in ('reg query "%%P" /v "UninstallString" 2^>nul ^|findstr "UninstallString"') do (
            set MsiStr=%%B
            echo !MsiStr!
		)
	  )
	)
)

if not defined MsiStr (
  echo "%SoftwareName% not found"
)
goto:eof


endlocal
