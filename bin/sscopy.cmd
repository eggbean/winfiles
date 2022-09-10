@echo off

echo.
echo SScopy v1.3  Copyright Synapse Syndrome 2009
REM dependencies:  xxcopy.exe, editpad.cmd
echo.

if [%1] == [] goto :help
if [%1] == [/?] goto :help
if /i %1 == /log goto :openlog
if [%3] == [] goto :copy
if /i %3 == /move goto :move
goto :eof

:copy
xxcopy "%~1\" "%~2\" /BB /Po0 /E /H /R /Q3 /oE3 /oS3 /oX3 /TC /PD0 /ED0 /PBH /oA"%USERPROFILE%\My Documents\XXCOPY Log.log"
goto :eof

:move
xxcopy "%~1\" "%~2\" /BB /Po0 /E /H /R /Q3 /oE3 /oS3 /oX3 /TC /RCY /PD0 /ED0 /PBH /oA"%USERPROFILE%\My Documents\XXCOPY Log.log"
goto :eof

:openlog
editpad "%USERPROFILE%\My Documents\XXCOPY Log.log"
goto :eof

:help
echo Usage: sscopy ^<source^> ^<destination^> [/move]
echo        sscopy /log
goto :eof

:: Make a switch to give a CHOICE menu, for more advanced copies

REM  Exit codes
REM
REM     0     No error, Successful operation
REM    1-32   DATMAN software package error code
REM    33     Aborted by user
REM    34     Illegal command parameter
REM    35     Invalid DOS version
REM    36     The current directory is invalid
REM    37     Resident DATMAN wrong version
REM    38     Cannot create the destination directory
REM    40     Some fatal error has occurred
REM    41     Invalid source specifier
REM    42     Invalid destination specifier
REM    43     Invalid exclusion item specifier
REM    44     Disk Full
REM    45     Share violation error
REM    46     Conditional termination
REM    47     Path name exceeds the file system's limit
REM    48     Cannot overwrite read-only file
REM    49     Problem in network
REM   100     No files were found to copy
REM  101-254  # errors in file copy (1-154, biased by 100)
REM    255    # errors exceeding 154 files
REM 

