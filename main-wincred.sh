#!/bin/bash
#------------------------------------------------------------------------------
# Updates the global git user.name and user.email.
# Manages git target credentials using git-credential-store:
# - Deletes the user's active git password
# - Sets the new git target with Personal Access Token (PAT)
#
# Succeeding git fetch/pull/push will not prompt for the user's Git password or
# Personal Access Token, since it's stored in the git-credential-store
# weaponsforge;20240905
#------------------------------------------------------------------------------

LOCAL_SETTINGS_FILE=".settings"
LOCAL_GIT_PROVIDER=""
ENV_FILE=".env"

# Check for required software (Git)
function check_installed {
  command -v "$1" >/dev/null 2>&1 || { echo "[ERROR]: $1 is required but it's not installed." >&2; exit 1; }
}

check_installed git
check_installed git-credential-store

# Display the main menu
function main_menu {
  clear
  echo "----------------------------------------------------------"
  echo "VIEWING GIT SWITCHER OPTIONS"
  echo "----------------------------------------------------------"
  echo "[1] View git user config"
  echo "[2] Edit git user config"
  echo "[3] Exit"
  read -p "Select option: " choice

  case $choice in
    1) view_user_config ;;
    2) prompt_user_input ;;
    3) exit 0 ;;
    *) main_menu ;;
  esac
}

# Prompt for git config username and git provider
function prompt_user_input {
  clear
  echo "----------------------------------------------------------"
  echo "EDIT GIT USER CONFIG DETAILS"
  echo "----------------------------------------------------------"

  read -p "Enter git user.name: " GIT_USERNAME
  echo
  echo "Which Git account would you like to edit?"
  echo "[1] Github"
  echo "[2] Gitlab"
  echo "[3] BitBucket"
  echo "[4] Exit"
  read -p "Select option: " gitrepository

  case $gitrepository in
    1) targetname="https://github.com" ; LOCAL_GIT_PROVIDER="github" ;;
    2) targetname="https://gitlab.com" ; LOCAL_GIT_PROVIDER="gitlab" ;;
    3) targetname="https://bitbucket.org" ; LOCAL_GIT_PROVIDER="bitbucket" ;;
    4) exit 0 ;;
    *) main_menu ;;
  esac

  # Read user git data from file
  read_file "$LOCAL_GIT_PROVIDER" "$GIT_USERNAME"

  # Set new git global user config
  if [ $? -ne 0 ]; then
    process_error
  else
    reset_password

    # Set the password in git-credential-store if present in the .env file
    if [ -n "$PERSONAL_ACCESS_TOKEN" ]; then
      set_password
    else
      echo "[INFO]: Personal Access Token not detected. Skipping set password..."
    fi

    set_user_config
  fi
}

# Display the current git user config
function view_user_config {
  clear
  echo "----------------------------------------------------------"
  echo "GIT USER CONFIG DETAILS (global)"
  echo "----------------------------------------------------------"

  echo "Git Provider: $LOCAL_GIT_PROVIDER"
  echo -n "Username: "
  git config --get user.name
  echo -n "Email: "
  git config --get user.email
  echo -n "GPG Key: "
  git config --get user.signingkey

  if [ "$LOCAL_GIT_PROVIDER" != "not yet set" ]; then
    view_git_credentials
  fi

  read -p "Press Enter to continue..." choice
  main_menu
}

# Log the Git credentials of the active Git target
function view_git_credentials {
  git credential-store get < "$targetname"
}

# Set the new git user config
function set_user_config {
  git config --global user.name "$GIT_USERNAME"
  git config --global user.email "$GIT_EMAIL"

  if [ -n "$GIT_SIGNING_KEY" ]; then
    # Check if gpg is available
    check_installed gpg

    git config --global user.signingkey "$GIT_SIGNING_KEY"
    git config --global commit.gpgsign true
    echo "[INFO]: Setting the global git signing key and commit settings."
  else
    git config --global --unset user.signingkey
    git config --global --unset commit.gpgsign
    echo "[INFO]: GPG signing key not defined."
    echo "[INFO]: Resetting global git signing key and commit settings."
  fi

  write_user_preference
  echo "[SUCCESS]: New global Git user config set."
  process_error
}

# Deletes the password in the git-credential-store
function reset_password {
  read -p "Would you like to reset the password? [Y/n]: " doreset

  if [[ "$doreset" =~ ^[Yy]$ ]]; then
    git credential-store erase < "$targetname"
    echo "The Git credentials were successfully deleted from the git-credential-store, if they were present."
  fi
}

# Sets a new target entry with password in the git-credential-store
function set_password {
  git credential-store store <<EOF
protocol=https
host=${targetname}
username=${GIT_USERNAME}
password=${PERSONAL_ACCESS_TOKEN}
EOF

  if [ $? -ne 0 ]; then
    echo "[ERROR]: Credentials not set in git-credential-store."
    exit 1
  else
    echo "[SUCCESS]: New Git credentials set in git-credential-store."
  fi
}

# Read user data from the .env
function read_file {
  local gitProvider="$1"
  local gitUsername="$2"
  hasError=false

  while IFS='|' read -r provider username email signing_key token; do
    if [[ "$provider" == "$gitProvider" && "$username" == "$gitUsername" ]]; then
      GIT_EMAIL="$email"
      GIT_SIGNING_KEY="$signing_key"
      PERSONAL_ACCESS_TOKEN="$token"
    fi
  done < "$ENV_FILE"

  if [ -z "$GIT_EMAIL" ]; then
    echo "[ERROR]: git.email is required."
    hasError=true
  fi

  if [ -z "$GIT_SIGNING_KEY" ]; then
    echo "[WARNING]: git.signingkey is undefined."
  fi

  if [ -z "$PERSONAL_ACCESS_TOKEN" ]; then
    echo "[WARNING]: Personal Access Token is undefined."
  fi

  if [ "$hasError" = true ]; then
    return 1
  fi
}

# Reads the local LOCAL_SETTINGS_FILE user-preference file into variables
function read_user_preference_file {
  if [ -f "$LOCAL_SETTINGS_FILE" ]; then
    while IFS='=' read -r key value; do
      if [ "$key" == "GIT_PROVIDER" ]; then
        LOCAL_GIT_PROVIDER="$value"
      fi
    done < "$LOCAL_SETTINGS_FILE"
  else
    LOCAL_GIT_PROVIDER="not yet set"
  fi
}

# Writes new user-preference values to the LOCAL_SETTINGS_FILE file
function write_user_preference {
  if [ -z "$GIT_PROVIDER" ]; then
    return
  fi

  if [ -f "$LOCAL_SETTINGS_FILE" ]; then
    rm "$LOCAL_SETTINGS_FILE"
  fi

  echo "GIT_PROVIDER=$GIT_PROVIDER" >> "$LOCAL_SETTINGS_FILE"
}

# Process warning messages
function process_error {
  read -p "Press Enter to continue..." choice
  main_menu
}

# Main execution starts here
read_user_preference_file
main_menu