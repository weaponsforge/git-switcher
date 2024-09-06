::------------------------------------------------------------------------------
:: Change the git user.name and user.email
:: Deletes the user's git password from the Windows Credential Manager.
:: Succeeding git fetch/pull/push will prompt for the user's Git password or
::   Personal Access Token (PAT), storing it in the Windows Credential Manager
:: weaponsforge;20240905
::------------------------------------------------------------------------------

@echo off
GOTO Init


:: Check for required software (Git)
:Init
  :: Local temporary files
  set "LOCAL_SETTINGS_FILE=.settings"
  set "LOCAL_GIT_PROVIDER="
  set "envFile=.env"

  CALL :CheckInstalled git

  if %errorlevel%==0 (
    GOTO Main
  ) else (
    echo [ERROR]: GitBash is required to run this script.
    pause
  )
EXIT /B 0


:: Display the main menu
:Main
  :: Clear the input variables
  set "GIT_PROVIDER="
  set "GIT_USERNAME="
  set "GIT_EMAIL="
  set "GPG_KEY="
  set "READ_ERROR="

  set "doreset="
  set "targetname="
  set /A isInstalled=0
  set /A choice=1
  set /A gitrepository=4

  CALL :ReadUserPreferenceFile

  cls
  echo ----------------------------------------------------------
  echo VIEWING GIT SWITCHER OPTIONS
  echo ----------------------------------------------------------
  echo [1] View git user config
  echo [2] Edit git user config
  echo [3] Exit
  set /p choice="Select option:"

  (if %choice% EQU 1 (
    GOTO ViewUserConfig
  ) else if %choice% EQU 2 (
    GOTO PromptUserInput
  ) else if %choice% EQU 3 (
    EXIT /B 0
  ))
EXIT /B 0


:: Prompt for git config username and git provider
:PromptUserInput
  setlocal enabledelayedexpansion

  cls
  echo ----------------------------------------------------------
  echo EDIT GIT USER CONFIG DETAILS
  echo ----------------------------------------------------------

  set /p GIT_USERNAME="Enter git user.name:"

  echo.
  echo Which Git account would you like to edit?
  echo [1] Github
  echo [2] Gitlab
  echo [3] BitBucket
  echo [4] Exit
  set /p gitrepository="Select option:"

  (if %gitrepository% EQU 1 (
    set targetname=git:https://github.com
    set GIT_PROVIDER=github
  ) else if %gitrepository% EQU 2 (
    set targetname=git:https://gitlab.com
    set GIT_PROVIDER=gitlab
  ) else if %gitrepository% EQU 3 (
    set targetname=git:https://bitbucket.org
    set GIT_PROVIDER=bitbucket
  ) else (
    GOTO Main
  ))

  :: Read user git data from file
  CALL :ReadFile !GIT_PROVIDER! !GIT_USERNAME!

  :: Set new git global user config and reset Win Credential Store data
  :: if there are no errors reading the file
  echo.!READ_ERROR! | findstr [A-Za-z]>nul && (
    echo.
    echo %READ_ERROR%
    GOTO ProcessError
  ) || (
    CALL :ResetPassword
    GOTO SetUserConfig
  )
EXIT /B 0


:: Display the current git user config
:ViewUserConfig
  cls
  echo ----------------------------------------------------------
  echo GIT USER CONFIG DETAILS (global)
  echo ----------------------------------------------------------

  echo Git Provider: %LOCAL_GIT_PROVIDER%

  echo|set /p="Username: "
  git config --get user.name

  echo|set /p="Email: "
  git config --get user.email

  echo|set /p="GPG Key: "
  git config --get user.signingkey

  if "%LOCAL_GIT_PROVIDER%" NEQ "not yet set" (
    CALL :ViewWinCredConfig
  )

  echo.
  set /p choice=Press Enter to continue...
  GOTO Main
EXIT /B 0


:: Log the Windows Credential information of the active Git target
:ViewWinCredConfig
  (if "%LOCAL_GIT_PROVIDER%"=="github" (
    set targetname=git:https://github.com
  ) else if "%LOCAL_GIT_PROVIDER%"=="gitlab" (
    set targetname=git:https://gitlab.com
  ) else if "%LOCAL_GIT_PROVIDER%"=="bitbucket" (
    set targetname=git:https://bitbucket.org
  ))

  cmdKey /list:%targetname%
EXIT /B 0


:: Set the new git user config
:: Unsets the global commit.signingkey if its not provided
:SetUserConfig
  git config --global user.name "%GIT_USERNAME%"
  git config --global user.email "%GIT_EMAIL%"

  if defined GIT_SIGNING_KEY (
    git config --global user.signingkey %GIT_SIGNING_KEY%!

    :: Check if gpg is available
    CALL :CheckInstalled gpg

    if !errorlevel!==0 (
      git config --global commit.gpgsign true
    ) else (
      echo [INFO]: gpg program not found. Skipping commit.gpgsign configuration.
    )
  ) else (
    git config --global --unset user.signingkey
    git config --global --unset commit.gpgsign
  )

  CALL :WriteUserPreference

  echo.
  echo [SUCCESS]: New global Git user config set.
  GOTO ProcessError
EXIT /B 0


:: Delete the password for the newly-set git user so it will be
:: prompted on the next git operation
:ResetPassword
  echo.
  set /p doreset=Would you like to reset the password? [Y/n]:

  if /i "%doreset%"=="Y" (
    :: Delete Git credentials in the Windows Credential Manager
    for /f "delims=" %%i in ('cmdKey /delete:%targetname% 2^>^&1') do set "output=%%i"

    echo.
    echo Deleting %targetname% in the Windows Credential Manager...
    echo !output!

    echo The Git credentials were successfully deleted from the
    echo Windows Credential Manager, if they were present.
  )
EXIT /B 0


:: Read user data from the .env
:: @param 1: git provider name
:: @param 2: git user name
:ReadFile
  set "USER_DATA_STRING="
  set "READ_ERROR="
  set "gitProvider=%~1"
  set "gitUsername=%~2"

  for /f "tokens=*" %%a in ('findstr /r "%gitProvider%|%gitUsername%|" "%envFile%"') do (
    set USER_DATA_STRING="%%a"
  )

  if defined USER_DATA_STRING (
    for /f "tokens=1,2,3,4 delims=|" %%c in (!USER_DATA_STRING!) do (
      set GIT_EMAIL=%%e
      set GIT_SIGNING_KEY=%%f
    )

    if "!GIT_EMAIL!"=="" (
      set READ_ERROR=[ERROR]: git.email is undefined.
    )
  ) else (
    set READ_ERROR=[ERROR]: %gitProvider%/%gitUsername% - undefined Git account in the settings file.
  )
EXIT /B 0


:: Reads the local LOCAL_SETTINGS_FILE user-preference file into variables
:ReadUserPreferenceFile
  if exist %LOCAL_SETTINGS_FILE% (
    for /f "tokens=1,2 delims==" %%a in (%LOCAL_SETTINGS_FILE%) do (
      if "%%a"=="GIT_PROVIDER" (
        set LOCAL_GIT_PROVIDER=%%b
      )
    )
  ) else (
    set LOCAL_GIT_PROVIDER=not yet set
  )
EXIT /B 0


:: Writes new user-preference values to the LOCAL_SETTINGS_FILE file
:WriteUserPreference
  set hasblank=false
  if "%GIT_PROVIDER%"=="" set hasblank=true

  if %hasblank% == true (
    EXIT /B 0
  )

  if exist %LOCAL_SETTINGS_FILE% (
    del %LOCAL_SETTINGS_FILE%
  )

  echo GIT_PROVIDER=%GIT_PROVIDER%>>%LOCAL_SETTINGS_FILE%
EXIT /B 0


:: Checks if program is installed
:: Sets the global system variable errorlevel=0 if a program is installed, else 1
:: @param 1: executable program name
:CheckInstalled
  set "program=%~1"
  where %program% >nul 2>&1

  if %errorlevel% == 0 (
    echo [INFO]: %program% IS installed
    EXIT /B 0
  ) else (
    echo [INFO]: %program% not installed
    EXIT /B 1
  )
EXIT /B 0


:: Process warning messages
:ProcessError
  set /p choice=Press Enter to continue...
  GOTO Main
EXIT /B 0


:: Exit for critical errors
:ProcessExit
  set /p choice=Press Enter to continue...
EXIT /B 0
