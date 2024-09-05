::-------------------------------------------------------------
:: Change the git user.name and user.email
:: Reset the user's git password from a ~/.gitcredential file
:: weaponsforge;20191026
::-------------------------------------------------------------

@echo off
GOTO Main


:: Display the main menu
:Main
  :: Clear the input variables
  set "gitusername="
  set "email="
  set "doreset="
  set "findstring="
  set /A choice=1
  set /A gitrepository=4

  :: Set git credentials file paths
  set gitcredentials=C:\Users\%username%\.gitcredential
  set newcredentials=C:\Users\%username%\.gitcredentialnew

  :: Delete temporary file
  if exist %newcredentials% (
    del /f %newcredentials%
  )

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

  set /p gitusername="Enter git user.name:"
  git config --global user.name %gitusername%

  set /p email="Enter git user.email:"
  git config --global user.email %email%

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
    set findstring=@github.com
  ) else if %gitrepository% EQU 2 (
    set findstring=@gitlab.com
  ) else if %gitrepository% EQU 3 (
    set findstring=@bitbucket.org
  ) else (
    GOTO Main
  ))

  if exist %gitcredentials% (
    echo | findstr /C:%findstring% %gitcredentials% > nul && (
      :: Copy all git credentials to temp file excluding the user to reset
      type %gitcredentials% | findstr /v %findstring% >> %newcredentials%

      :: Overwrite current git credentials to delete (reset) the new git config user's password
      type %newcredentials% > %gitcredentials%
    )
    GOTO ExitResetPassword
  ) else (
    echo %gitcredentials% was not found.
    echo Make sure your windows User path is correct and the file exists, then try again.
    echo Read on the Usage instructions for more information.
    GOTO ProcessError
  )
EXIT /B 0


:: Exit from the git reset password
:ExitResetPassword
  :: Delete temporary git credentials file
  if exist %newcredentials% (
    del /f %newcredentials% && (
      echo Git user's %findstring% password has been reset.
      GOTO ProcessError
    ) || (
      echo Failed deleting temporary file.
      echo Close this program and run again.
      GOTO ProcessExit
    )
  ) else (
    echo Password for user %gitusername% on %findstring% was not found.
    echo Nothing to reset.
    GOTO ProcessError
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