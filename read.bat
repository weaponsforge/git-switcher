@echo off
GOTO Main

set /A errorlevel=0

:Main
  setlocal enabledelayedexpansion

  :: Set the path to the .env file
  set "envFile=.env"

  :: Initialize variables
  set "GIT_USERNAME="
  set "GIT_EMAIL="
  set "GIT_SIGNING_KEY="
  set "findstring="

  set /p GIT_USERNAME="Enter git.username:"

  :: Read the .env file
  for /f "tokens=*" %%a in ('findstr /r "github|%GIT_USERNAME%|" "%envFile%"') do (
    set findstring="%%a"
  )

  :: TO-DO: Validate contents
  :: c, d, e, and f should be defined
  if defined findstring (
    for /f "tokens=1,2,3,4 delims=|" %%c in (!findstring!) do (
      echo %%c
      echo %%d
      echo %%e
      echo %%f

      echo %%e | findstr /r "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" >nul
      if !errorlevel! neq 0 (
        echo [ERROR]: Invalid email
        GOTO ExitProgram
      )

      set GIT_EMAIL=%%e
      set GIT_SIGNING_KEY=%%f
    )
  ) else (
    echo "---not found"
  )

  :: Print data
  echo.
  echo Username: %GIT_USERNAME%
  echo Email: %GIT_EMAIL%
  echo GPG Signing Key: %GIT_SIGNING_KEY%

  :: Set Git config
  git config --global user.name %GIT_USERNAME%
  git config --global user.email %GIT_EMAIL%

  if defined GIT_SIGNING_KEY (
    git config --global user.signingkey %GIT_SIGNING_KEY%!
    git config --global commit.gpgsign true
  ) else (
    git config --global --unset user.signingkey
    git config --global --unset commit.gpgsign
  )

  endlocal
EXIT /B 0

:ExitProgram
  echo Exiting app...
  pause
EXIT /B 0