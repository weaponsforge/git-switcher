# git-switcher

Switches the Git global user account credentials and resets the git user's password for GitHub, GitLab, or BitBucket:

- from the Windows Credential Manager using `main-wincred.bat`.
- from a `~/.gitcredential` file using `main.bat`.


### Dependencies

1. Windows 10 OS 64-bit
2. [Git Bash](https://gitforwindows.org/) for Windows
	- Tested on versions 2.33.0.windows.1 and 2.42
	- Installed using default options
3. Git account
	- GitHub, Gitlab, Bitbucket


## Content

1. **main.bat**
   - Windows batch script to automate git user (view, edit and reset password) commands from a `~/.gitcredential` file.
   - Follow the instructions for setting up Git Bash for usage with this script.

      > **WARNING:** This method stores a Git user's password or Personal Access Token (PAT) in a `~/.gitcredential` plain-text file, which maybe unsafe. Consider using the **main-wincred.bat** script to ensure stricter Git account security.

2. **main-wincred.bat**
   - Windows batch script to automate git user (view, edit and reset password) commands from the Windows Credential Manager.
   - Follow the instructions for setting up Git Bash for usage with this script.

## Installation

1. Clone this repository.<br>
`git clone https://github.com/weaponsforge/git-switcher.git`

2. Follow the GitBash Configuration Steps for `main.bat` or `main-wincred.bat` from the preceeding sub-sections.

3. Read the [Usage](#usage) section for reference on using the scripts after setting up GitBash from step **# 2**.

## GitBash Configuration (Windows OS only)

### GitBash Configuration with `main.bat`

Configure your GitBash first with the following settings before using the script.

> ***WARNING:** These settings remove the Windows Credential Manager process handling for Git to a text-based ".gitcredentials" file from an easy-to-access location. Proceed at your discretion.*

1. Open a command prompt as an **Administrator**  and run the command:<br>
`git config --global credential.helper "store --file ~/.gitcredential`
2. Delete your **github** access credentials from the **Windows Credentials Manager**.
   - Search for **Credential Manager** from the Search box.
	 - Click the **Windows Credentials** button.
	 - Find and delete the entry for **Github**, **Gitlab**, or **Bitbucket**
3. Run `git config --list --show-origin` to view updates.
   - Verify that the command created `.gitconfig` and `.gitcredential` files in **C:\Users\\[USER_NAME]**.
4. Step no.'s 1-3 have been tested for only **GitBash v2.33 - v2.36**. Do the following steps to ensure compatibility with GitBash versions higher than **v2.36+**.
5. Create a backup of the GitBash `gitconfig` file, usually found in the location:<br>
`C:\Program Files\Git\etc\gitconfig`
6. Edit the **gitconfig** file. Delete the following lines and SAVE. (You may need Administrator access to edit the file).<br>
   ```
   [credential]
	   helper = manager
   ```
   - Restore the deleted lines anytime as needed.
   - Take note the git-switcher script will not work after restoring the deleted lines.

### GitBash Configuration with `main-wincred.bat`

1. GitBash requires no further setup when using the Windows Credential Manager for managing Git accounts.
2. Undo the GitBash setup steps from [GitBash Configuration with `main.bat`](#gitBash-configuration-with-main.bat), if these steps were previously used.

## Usage

Click to run the windows batch script file **main.bat**. You may need to run it as an **Administrator** if there will be privilege errors.

1. Select **Option [1]** to **View** the current Git user's global `user.email` and `user.config`.
2. Select **Option [2]** to **Edit** the current global `user.email` and `user.config`.<br>You will be prompted for which Git version control provider would you like to reset the password.
   - Select sub-option **[1]** for **GitHub**.
   - Select sub-option **[2]** for **GitLab**
   - Select sub-option **[3]** for **BitBucket**
   - Select sub-option **[4]** to **Exit**
3. Select **Option [3]** to exit.
4. Press **Ctrl + C** to exit any time.

20191026