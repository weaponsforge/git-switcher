::------------------------------------------------------------------------------
:: Change the git user.name and user.email
:: Deletes the user's git password from the Windows Credential Manager.
:: Succeeding git fetch/pull/push will prompt for the user's Git password or
::   Personal Access Token (PAT), storing it in the Windows Credential Manager
:: weaponsforge;20240905
::------------------------------------------------------------------------------

@echo off
GOTO Main


:: Display the main menu
:Main
  :: Clear the input variables
  set "GIT_PROVIDER="
  set "GIT_USERNAME="
  set "GIT_EMAIL="
  set "GPG_KEY="
  set "doreset="
  set "targetname="
  set /A choice=1
  set /A gitrepository=4

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
    GOTO SetUserConfig
  ) else if %choice% EQU 3 (
    EXIT /B 0
  ))
EXIT /B 0


:: Prompt for git config username and email
:SetUserConfig
  cls
  echo ----------------------------------------------------------
  echo EDIT GIT USER CONFIG DETAILS
  echo ----------------------------------------------------------

  set /p GIT_USERNAME="Enter git user.name:"
  git config --global user.name %GIT_USERNAME%

  set /p GIT_EMAIL="Enter git user.email:"
  git config --global user.email %GIT_EMAIL%

  echo Updated git user config...
  set /p doreset=Would you like to reset the password? [Y/n]:

  echo.%doreset% | findstr /C:"Y">nul && (
    GOTO ResetPassword
  ) || (
    GOTO Main
  )
EXIT /B 0


:: Display the current git user config
:ViewUserConfig
  cls
  echo ----------------------------------------------------------
  echo GIT USER CONFIG DETAILS (global)
  echo ----------------------------------------------------------

  echo|set /p=Username:
  git config --get user.name

  echo|set /p=Email:
  git config --get user.email

  set /p choice=Press Enter to continue...
  GOTO Main
EXIT /B 0


:: Delete the password for the newly-set git user so it will be
:: prompted on the next git operation
:ResetPassword
  echo Which Git account password would you like to reset?
  echo [1] Github
  echo [2] Gitlab
  echo [3] BitBucket
  echo [4] Exit
  set /p gitrepository="Select option:"

  (if %gitrepository% EQU 1 (
    set targetname=git:https://github.com
  ) else if %gitrepository% EQU 2 (
    set targetname=git:https://gitlab.com
  ) else if %gitrepository% EQU 3 (
    set targetname=git:https://bitbucket.org
  ) else (
    GOTO Main
  ))

  :: Delete Git credentials in the Windows Credential Manager
  for /f "delims=" %%i in ('cmdKey /delete:%targetname% 2^>^&1') do set "output=%%i"

  echo.
  echo %output%

  GOTO ExitResetPassword
EXIT /B 0


:: Exit from the git reset password
:ExitResetPassword
  :: Delete temporary git credentials file
  echo The Git credentials were successfully deleted from the
  echo Windows Credential Manager, if they were present.
  GOTO ProcessError
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