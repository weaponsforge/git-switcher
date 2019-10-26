::----------------------------------------------------------
:: Change the git user.name and user.email
:: weaponsforge;20191026
::----------------------------------------------------------

@echo off

GOTO Main


:: Display the main menu
:Main
  cls
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
  echo SET USER CONFIG DETAILS
  set /p username="Enter git user.name:"
  git config --global user.name %username%

  set /p email="Enter git user.email:"
  git config --global user.email %email%

  echo Updated git user config...
  GOTO ViewUserConfig
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