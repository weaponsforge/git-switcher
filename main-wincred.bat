::------------------------------------------------------------------------------
:: Upddates the global git user.name and user.email.
:: Manages git target credentials in the Windows Credential Manager:
:: - Deletes the user's active git password
:: - Sets the new git target with Personal Access Token (PAT)
::
:: Succeeding git fetch/pull/push will not prompt for the user's Git password or
::   Personal Access Token, since its stored in the Windows Credential Manager
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

  :: Constants
  set TARGET_GITHUB=git:https://github.com
  set TARGET_GITLAB=git:https://gitlab.com
  set TARGET_BITBUCKET=git:https://bitbucket.org
  set PLAT_GITHUB=github
  set PLAT_GITLAB=gitlab
  set PLAT_BITBUCKET=bitbucket

  :: Check required software
  CALL :CheckInstalled git
  set /A errCount += %errorlevel%

  CALL :CheckInstalled cmdKey
  set /A errCount += %errorlevel%

  if %errCount%==0 (
    GOTO Main
  ) else (
    echo [ERROR]: GitBash and Windows Credential Manager are required to run this script.
    pause
  )
EXIT /B 0


:: Display the main menu
:Main
  :: Clear the input variables
  set "GIT_PROVIDER="
  set "GIT_USERNAME="
  set "GIT_EMAIL="
  set "PERSONAL_ACCESS_TOKEN="
  set "GPG_KEY="

  set "targetname="
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
    CALL :SetWinCredTarget %PLAT_GITHUB%
  ) else if %gitrepository% EQU 2 (
    CALL :SetWinCredTarget %PLAT_GITLAB%
  ) else if %gitrepository% EQU 3 (
    CALL :SetWinCredTarget %PLAT_BITBUCKET%
  ) else (
    GOTO Main
  ))

  :: Read user git data from file
  CALL :ReadFile %GIT_PROVIDER% %GIT_USERNAME%

  :: Set new git global user config and reset Win Credential Store data
  :: if there are no errors reading the file
  if %errorlevel% == 1 (
    GOTO ProcessError
  ) else (
    CALL :ResetPassword

    :: Set the password in Windows Credential Manager if its present in the .env file
    if defined PERSONAL_ACCESS_TOKEN (
      CALL :SetPassword
    ) else (
      echo [INFO]: Personal Access Token not detected. Skipping set password...
    )

    if !errorlevel! == 0 (
      GOTO SetUserConfig
    ) else (
      pause
      GOTO Main
    )
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


:: Logs the Windows Credential information of the active Git target
:ViewWinCredConfig
  cmdKey /list:%targetname%
EXIT /B 0


:: Set the new git user config
:: Unsets the global commit.signingkey if its not provided
:SetUserConfig
  git config --global user.name "%GIT_USERNAME%"
  git config --global user.email "%GIT_EMAIL%"

  if defined GIT_SIGNING_KEY (
    :: Check if gpg is available
    CALL :CheckInstalled gpg

    if !errorlevel!==0 (
      git config --global user.signingkey %GIT_SIGNING_KEY%!
      git config --global commit.gpgsign true
      echo [INFO]: Setting the global git signing key and commit settings.
    ) else (
      echo [INFO]: gpg program not found. Skipping commit.gpgsign configuration.
    )
  ) else (
    git config --global --unset user.signingkey
    git config --global --unset commit.gpgsign
    echo [INFO]: GPG signing key not defined.
    echo [INFO]: Resetting global git signing key and commit settings.
  )

  CALL :WriteUserPreference

  echo.
  echo [SUCCESS]: New global Git user config set.
  GOTO ProcessError
EXIT /B 0


:: Deletes the password in the Windows Credential Manager
:: for the newly-set git user so it will be prompted on the next git operation
:ResetPassword
  set "doreset="

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


:: Sets a new target entry with password in the Windows Credential Manager
:SetPassword
  cmdKey /generic:%targetname% /user:%GIT_USERNAME% /pass:%PERSONAL_ACCESS_TOKEN%

 :: Check if the command failed
  if errorlevel 1 (
    echo [ERROR]: Credentials not set in Windows Credential Manager.
    EXIT /B 1
  ) else (
    echo [SUCCESS]: New Git credentials set in Windows Credential Manager.
  )
EXIT /B 0


:: Read user data from the .env
:: @param 1: git provider name
:: @param 2: git user name
:: @returns: Sets the global system variable errorlevel=1 on file reading errors, else 0
:ReadFile
  set "USER_DATA_STRING="
  set "gitProvider=%~1"
  set "gitUsername=%~2"
  set hasError=false

  for /f "tokens=*" %%a in ('findstr /r /c:"^%gitProvider%|%gitUsername%|" "%envFile%"') do (
    set USER_DATA_STRING="%%a"
  )

  if defined USER_DATA_STRING (
    for /f "tokens=1,2,3,4,5 delims=|" %%c in (!USER_DATA_STRING!) do (
      set GIT_EMAIL=%%e
      set GIT_SIGNING_KEY=%%f
      set PERSONAL_ACCESS_TOKEN=%%g
    )

    if "!GIT_EMAIL!"=="" (
      echo [ERROR]: git.email is required.
      set hasError=true
    )

    if "!GIT_SIGNING_KEY!"=="" (
      echo [WARNING]: git.signingkey is undefined.
    )

    if "!PERSONAL_ACCESS_TOKEN!"=="" (
      echo [WARNING]: Personal Access Token is undefined.
    )
  ) else (
    echo [ERROR]: %gitProvider%/%gitUsername% - undefined Git account in the settings file.
    set hasError=true
  )

  :: Reset the GIT_SIGNING_KEY if its value is "-"
  if "%GIT_SIGNING_KEY%"=="-" (
    set "GIT_SIGNING_KEY="
  )

  :: Set the errorlevel system variable to 1
  if %hasError% == true (
    EXIT /B 1
  )
EXIT /B 0


:: Reads the local LOCAL_SETTINGS_FILE user-preference file into variables
:: Initializes the Windows Credential Manager target from user preference file
:ReadUserPreferenceFile
  if exist %LOCAL_SETTINGS_FILE% (
    for /f "tokens=1,2 delims==" %%a in (%LOCAL_SETTINGS_FILE%) do (
      if "%%a"=="GIT_PROVIDER" (
        set LOCAL_GIT_PROVIDER=%%b
        CALL :SetWinCredTarget %%b
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
:: @param 1: executable program name
:: @returns: Sets the global system variable errorlevel=0 if a program is installed, else 1
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


:: Sets the Windows Credential Manager domain target
:: Sets the GIT_PROVIDER and targetname global variables
:: @param 1: Git provider platform (github|gitlab|bitbucket)
:SetWinCredTarget
  set "gitProvider=%~1"
  set GIT_PROVIDER=%gitProvider%

  (if "%GIT_PROVIDER%"=="%PLAT_GITHUB%" (
    set targetname=%TARGET_GITHUB%
  ) else if "%GIT_PROVIDER%"=="%PLAT_GITLAB%" (
    set targetname=%TARGET_GITLAB%
  ) else if "%GIT_PROVIDER%"=="%PLAT_BITBUCKET%" (
    set targetname=%TARGET_BITBUCKET%
  ))
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