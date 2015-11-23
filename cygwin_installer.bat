@ECHO OFF
REM -- Author: Joetww@gmail.com (Taiwan/mandarin)
REM -- Automates prepare Cygwin Download package...
REM -- 參考來源: https://github.com/rtwolf/auto-cygwin-install
REM -- 參考來源：https://raw.githubusercontent.com/weikinhuang/dotfiles/master/dotenv/other/setup-cygwin.cmd



SETLOCAL

NET SESSION >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    ECHO Administrator PRIVILEGES Detected! 
) ELSE (
   echo ######## ########  ########   #######  ########  
   echo ##       ##     ## ##     ## ##     ## ##     ## 
   echo ##       ##     ## ##     ## ##     ## ##     ## 
   echo ######   ########  ########  ##     ## ########  
   echo ##       ##   ##   ##   ##   ##     ## ##   ##   
   echo ##       ##    ##  ##    ##  ##     ## ##    ##  
   echo ######## ##     ## ##     ##  #######  ##     ## 
   echo.
   echo.
   echo ####### ERROR: ADMINISTRATOR PRIVILEGES REQUIRED #########
   echo This script must be run as administrator to work properly!  
   echo If you're seeing this after clicking on a start menu icon, then right click on the shortcut and select "Run As Administrator".
   echo ##########################################################
   echo.
   PAUSE
   EXIT /B 1
)

REM -- Change to the directory of the executing batch file
CD %~dp0

REM -- Configure our paths
SET SITE=http://ftp.ntu.edu.tw/pub/cygwin/
SET LOCALDIR=%CD%

IF "%PROCESSOR_ARCHITECTURE%" == "x86" (
	SET SETUP_LAUNCHER=setup-x86.exe
	SET ROOTDIR=C:\cygwin
) else (
	SET SETUP_LAUNCHER=setup-x86_64.exe
	SET ROOTDIR=C:\cygwin64
)

REM -- STARTING SCRIPT
set DLOAD_SCRIPT=download.vbs
REM -- pure batch downloader: https://semitwist.com/articles/article/view/downloading-files-from-plain-batch-with-zero-dependencies
REM -- Windows has no built-in wget or curl, so generate a VBS script to do it:
REM -------------------------------------------------------------------------
ECHO Option Explicit                                                    >  %DLOAD_SCRIPT%
ECHO Dim args, http, fileSystem, adoStream, url, target, status         >> %DLOAD_SCRIPT%
ECHO.                                                                   >> %DLOAD_SCRIPT%
ECHO Set args = Wscript.Arguments                                       >> %DLOAD_SCRIPT%
ECHO Set http = CreateObject("WinHttp.WinHttpRequest.5.1")              >> %DLOAD_SCRIPT%
ECHO url = args(0)                                                      >> %DLOAD_SCRIPT%
ECHO target = args(1)                                                   >> %DLOAD_SCRIPT%
ECHO WScript.Echo "Getting '" ^& target ^& "' from '" ^& url ^& "'..."  >> %DLOAD_SCRIPT%
ECHO.                                                                   >> %DLOAD_SCRIPT%
ECHO http.Open "GET", url, False                                        >> %DLOAD_SCRIPT%
ECHO http.Send                                                          >> %DLOAD_SCRIPT%
ECHO status = http.Status                                               >> %DLOAD_SCRIPT%
ECHO.                                                                   >> %DLOAD_SCRIPT%
ECHO If status ^<^> 200 Then                                            >> %DLOAD_SCRIPT%
ECHO 	WScript.Echo "FAILED to download: HTTP Status " ^& status       >> %DLOAD_SCRIPT%
ECHO 	WScript.Quit 1                                                  >> %DLOAD_SCRIPT%
ECHO End If                                                             >> %DLOAD_SCRIPT%
ECHO.                                                                   >> %DLOAD_SCRIPT%
ECHO Set adoStream = CreateObject("ADODB.Stream")                       >> %DLOAD_SCRIPT%
ECHO adoStream.Open                                                     >> %DLOAD_SCRIPT%
ECHO adoStream.Type = 1                                                 >> %DLOAD_SCRIPT%
ECHO adoStream.Write http.ResponseBody                                  >> %DLOAD_SCRIPT%
ECHO adoStream.Position = 0                                             >> %DLOAD_SCRIPT%
ECHO.                                                                   >> %DLOAD_SCRIPT%
ECHO Set fileSystem = CreateObject("Scripting.FileSystemObject")        >> %DLOAD_SCRIPT%
ECHO If fileSystem.FileExists(target) Then fileSystem.DeleteFile target >> %DLOAD_SCRIPT%
ECHO adoStream.SaveToFile target                                        >> %DLOAD_SCRIPT%
ECHO adoStream.Close                                                    >> %DLOAD_SCRIPT%
ECHO.                                                                   >> %DLOAD_SCRIPT%
REM -------------------------------------------------------------------------

IF NOT EXIST "%SETUP_LAUNCHER%" cscript //Nologo "%DLOAD_SCRIPT%" http://cygwin.com/%SETUP_LAUNCHER% "%SETUP_LAUNCHER%"

REM -- cleanup temp files
del "%DLOAD_SCRIPT%"

REM -- These are the packages we will install (in addition to the default packages)
SET PACKAGES=mc,cygrunsrv,openssh,autossh,mintty,wget,ctags,diffutils,git,git-completion,git-svn,stgit,mercurial
SET PACKAGES=%PACKAGES%,curl,mysql,nc,unzip,zip,w3m,vim,vim-common,tmux,php,ImageMagick,procps
SET PACKAGES=%PACKAGES%,bash-completion,bc,ca-certificates,cygutils-extra,gnupg,inetutils,nc,nc6,ncurses

REM -- These are necessary for apt-cyg install, do not change. Any duplicates will be ignored.
SET PACKAGES=%PACKAGES%,wget,tar,gawk,bzip2,subversion

SET UNWANT_PACKAGES=vim-minimal

SET /P METHOD="download or install (type download or install): "

2>NUL CALL :CASE_%METHOD% # jump to :CASE_download, :CASE_install, etc.
IF ERRORLEVEL 1 CALL :DEFAULT_CASE # if label doesn't exist

ENDLOCAL

ECHO Done.
PAUSE
EXIT /B 0

:CASE_download
	ECHO *** DOWNLOADING DEFAULT PACKAGES
	%SETUP_LAUNCHER% --quiet-mode --no-desktop --download --no-verify ^
	-s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%" ^
	--remove-packages %UNWANT_PACKAGES%
	ECHO.
	ECHO.
	ECHO *** DOWNLOADING CUSTOM PACKAGES
	%SETUP_LAUNCHER% --quiet-mode --no-desktop --download --no-verify ^
	-s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%" ^
	--remove-packages %UNWANT_PACKAGES% -P %PACKAGES%
	GOTO END_CASE
:CASE_install
	ECHO *** INSTALLING DEFAULT PACKAGES
	%SETUP_LAUNCHER% --quiet-mode --no-desktop --local-install --no-verify ^
	-s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%" ^
	--remove-packages %UNWANT_PACKAGES%
	ECHO.
	ECHO.
	ECHO *** INSTALLING CUSTOM PACKAGES
	%SETUP_LAUNCHER% --quiet-mode --no-desktop --local-install --no-verify ^
	-s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%" ^
	--remove-packages %UNWANT_PACKAGES% -P %PACKAGES%
	
	ECHO apt-cyg installing.
	set PATH=%ROOTDIR%\bin;%PATH%
	"%ROOTDIR%\bin\bash.exe" --login -c "/usr/bin/lynx -source https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg > apt-cyg"
	"%ROOTDIR%\bin\bash.exe" --login -c "/usr/bin/install apt-cyg /bin"
	"%ROOTDIR%\bin\bash.exe" --login -c "cp /usr/share/vim/vim74/vimrc_example.vim ~/.vimrc"
	
	assoc .sh=bashscript
	ftype bashscript="%ROOTDIR%\bin\mintty.exe" /bin/bash -li "%%1" %%*

	GOTO END_CASE
:DEFAULT_CASE
	ECHO Unknown method "%METHOD%"
	GOTO END_CASE
:END_CASE
	VER > NUL # reset ERRORLEVEL
	GOTO :EOF # return from CALL
	
