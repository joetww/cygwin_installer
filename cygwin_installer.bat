@ECHO OFF
REM -- Automates prepare Cygwin Download package...
REM -- Source: https://github.com/rtwolf/auto-cygwin-install

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
SET SITE=ftp://ftp.twaren.net/Unix/sourceware.org/cygwin/
SET LOCALDIR=%CD%
SET ROOTDIR=C:\cygwin64
SET SETUP_LAUNCHER=setup-x86_64.exe

REM -- These are the packages we will install (in addition to the default packages)
SET PACKAGES=mc,cygrunsrv,openssh,autossh,mintty,wget,ctags,diffutils,git,git-completion,git-svn,stgit,mercurial
SET PACKAGES=%PACKAGES%,curl,mysql,nc,unzip,zip,w3m,vim,vim-common,tmux,php,ImageMagick,procps

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
	%ROOTDIR%\bin\bash.exe -c "/usr/bin/lynx -source rawgit.com/transcode-open/apt-cyg/master/apt-cyg > apt-cyg"
	%ROOTDIR%\bin\bash.exe -c "/usr/bin/install apt-cyg /bin"
	%ROOTDIR%\bin\bash.exe -c "cp /usr/share/vim/vim74/vimrc_example.vim ~/.vimrc"
	
	assoc .sh=bashscript
	ftype bashscript="%ROOTDIR%\bin\mintty.exe" /bin/bash -li "%%1" %%*

	GOTO END_CASE
:DEFAULT_CASE
	ECHO Unknown method "%METHOD%"
	GOTO END_CASE
:END_CASE
	VER > NUL # reset ERRORLEVEL
	GOTO :EOF # return from CALL
	