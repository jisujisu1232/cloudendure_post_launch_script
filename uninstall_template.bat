::It extracts software software GUID, then use the GUID to search the name and version
@echo ON
setlocal ENABLEDELAYEDEXPANSION


set x64reg=%SystemRoot%\Sysnative\reg.exe
set x86GUID=HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
set x64GUID=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
set MigrationResultFolderName=C:\AWSmigrationTemp\
set MigrationResultFileName=result.txt



REM #######   삭제 대상 별 변경 필요  ########

set SoftwareName=Bandizip

REM UninstallString 이 MsiExec 로 시작하는 경우 1
REM 아닌 경우 2
REM Reg 상에 MsiExec 와 다른 방식이 공존하는 경우가 있음.

set UninstallType=1
REM set UninstallType=2


set UninstallOptions=/SILENT /VERYSILENT

REM #######      END      ########








set UninstallType=%UninstallType: =%
if not defined SoftwareName (
    echo [Error]Software Name is Null
    goto:eof
)
set UninstallOptions=%UninstallOptions% /norestart /l* %MigrationResultFolderName%%SoftwareName: =_%.log

if not exist %MigrationResultFolderName% (
  mkdir %MigrationResultFolderName%
  echo [post script Result]> %MigrationResultFolderName%%MigrationResultFileName%
)

REM It's faster to first locate the software GUID, then search it's Name, Version & UninstallString
for /f "delims=" %%P in ('%x64reg% query "%x64GUID%" /s /f "%SoftwareName%" 2^>nul ^| findstr "HKEY_LOCAL_MACHINE"') do (
  %x64reg% query "%%P" /v "UninstallString" 2>nul && (
    for /f "tokens=2*" %%A in ('%x64reg% query "%%P" /v "UninstallString" 2^>nul ^|findstr "UninstallString"') do (
        set MsiStr=%%B
        set testMsiStr=!MsiStr:~0,7!
        if /I "%UninstallType%"=="1" (
            if /I "!testMsiStr!"=="MsiExec" (
                set isPass=True
            )
        )else (
            set isPass=True
        )
        if defined isPass (
            set MsiStr=!MsiStr:/I=/X!
            echo !MsiStr! !UninstallOptions!
            !MsiStr! !UninstallOptions!
            set ScriptResult=[Success]%SoftwareName% Uninstalled
            goto Success
		)
    )
  )
)

for /f "delims=" %%P in ('reg query "%x64GUID%" /s /f "%SoftwareName%" 2^>nul ^| findstr "HKEY_LOCAL_MACHINE"') do (
  reg query "%%P" /v "UninstallString" 2>nul && (
    for /f "tokens=2*" %%A in ('reg query "%%P" /v "UninstallString" 2^>nul ^|findstr "UninstallString"') do (
        set MsiStr=%%B
        set testMsiStr=!MsiStr:~0,7!
        if /I "%UninstallType%"=="exe" (
            set isPass=True
        )else (
            if /I "!testMsiStr!"=="MsiExec" (
                set isPass=True
            )
        )
        if defined isPass (
            set MsiStr=!MsiStr:/I=/X!
            echo !MsiStr! !UninstallOptions!
            !MsiStr! !UninstallOptions!
            set ScriptResult=[Success]%SoftwareName% Uninstalled
            goto Success
        )
    )
  )
)


for /f "delims=" %%P in ('reg query "%x86GUID%" /s /f "%SoftwareName%" 2^>nul ^| findstr "HKEY_LOCAL_MACHINE"') do (
  echo %%P
  reg query "%%P" /v "UninstallString" 2>nul && (
	for /f "tokens=2*" %%A in ('reg query "%%P" /v "UninstallString" 2^>nul ^|findstr "UninstallString"') do (
        set MsiStr=%%B
        set testMsiStr=!MsiStr:~0,7!
        if /I "%UninstallType%"=="exe" (
            set isPass=True
        )else (
            if /I "!testMsiStr!"=="MsiExec" (
                set isPass=True
            )
        )
        if defined isPass (
            set MsiStr=!MsiStr:/I=/X!
            echo !MsiStr! !UninstallOptions!
            !MsiStr! !UninstallOptions!
            set ScriptResult=[Success]%SoftwareName% Uninstalled
            goto Success
        )
	)
  )
)



echo %SoftwareName% not found
set ScriptResult=[Success]%SoftwareName% not found
goto:eof




:Success

echo %ScriptResult% >> %MigrationResultFolderName%%MigrationResultFileName%


goto:eof


endlocal
