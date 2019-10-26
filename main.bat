::----------------------------------------------------------
:: Change the git user.name and user.email
:: weaponsforge;20191026
::----------------------------------------------------------

@echo off
GOTO Main

:: Display the main menu
:Main
  cls
  echo ----------------------------------------------------------
  echo VIEWING GIT SWITCHER OPTIONS
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

  :: Clear the input variables
  set "gitusername="
  set "email="

  set /p gitusername="Enter git user.name:"
  git config --global user.name %gitusername%

  set /p email="Enter git user.email:"
  git config --global user.email %email%

  echo Updated git user config...
  GOTO ResetPassword
EXIT /B 0


:: Display the current git user config
:ViewUserConfig
  cls
  echo ----------------------------------------------------------
  echo USER CONFIG DETAILS
  
  echo|set /p=Username:
  git config --get user.name

  echo|set /p=Email:
  git config --get user.email

  set /p choice=Press Enter to continue...
  GOTO Main
EXIT /B 0


:: Delete the password for the newly-set git user so it will be
:: prompted on suceeding git operations
:ResetPassword
  set gitcredentials=C:\Users\%username%\.gitcredential
  set newcredentials=C:\Users\%username%\.gitcredentialnew
  set findstr=@github.com
  set gitindex=""

  echo Which Git account password would you like to reset?
  echo [1] Github
  echo [2] Gitlab
  echo [3] BitBucket
  set /p gitindex="Select option:"

  (if %gitindex% EQU 1 (
    set findstr=@github.com
  ) else if %gitindex% EQU 2 (
    set findstr=@gitlab.com
  ) else if %gitindex% EQU 3 (
    set findstr=@bitbucket.org
  ))

  :: Delete temporary file
  if exist %newcredentials% (
    del /f %newcredentials%
  )

  if exist %gitcredentials% (
    (for /f "tokens=*" %%x in (%gitcredentials%) do (
      @echo.%%x | findstr /C:%findstr%>nul && (
        Echo found

        :: Copy all git credentials to temp file  excluding the user to reset
        type %gitcredentials% | findstr /v %findstr% >> %newcredentials%

        :: Overwrite current git credentials to delete (reset) the new git config user's password
        type %newcredentials% > %gitcredentials%
        GOTO ExitResetPassword
      )

      GOTO ExitResetPassword
    ))
  ) else (
    echo %gitcredentials% was not found.
    echo Make sure your windows User path is correct and try again.
    GOTO ProcessError
  )
EXIT /B 0


:ExitResetPassword
  :: Delete temporary git credentials file
  if exist %newcredentials% (
    del /f %newcredentials% && (
      set /p choice=New git user's password has been reset...
      GOTO ViewUserConfig
    ) || (
      set /p choice=Failed deleting temporary file.
      GOTO ProcessError
    )
  ) else (
    echo Password for user %gitusername% on %findstr% was not found.
    GOTO ProcessError
  )
EXIT /B 0


:ProcessError
  set /p choice=Press Enter to continue...
  GOTO Main
EXIT /B 0