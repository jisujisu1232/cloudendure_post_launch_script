::It extracts software software GUID, then use the GUID to search the name and version
@echo off
setlocal ENABLEDELAYEDEXPANSION



REM #############################################################

REM    [Plan A]
REM    Execute from CloudEndure background service
REM       file pattern
REM            01.*.bat
REM    [Plan B]
REM    Execute from User
REM       file pattern
REM            02.*.bat

REM #############################################################


set postDir=C:\Program Files (x86)\CloudEndure\post_launch
set MigrationResultFolderName=C:\AWSmigrationTemp\
set moveFilePattern=02.*

if not exist %MigrationResultFolderName% (
  mkdir %MigrationResultFolderName%
)


FOR %%A IN ("%postDir%\%moveFilePattern%") DO (
    move "%%~A" "%MigrationResultFolderName%\"
)

goto:eof


endlocal
