# git-switcher

>  Switches the Git global account credentials from a Git config file without resetting from the Windows Credentials Manager.<br>
>  Sets a git user and resets the git user's password for GitHub, GitLab, or BitBucket.


### Dependencies

1. Windows 10 OS 64-bit
2. [Git Bash](https://gitforwindows.org/) for Windows
	- Tested on versions 2.33.0.windows.1 and 2.42
	- Installed using default options
3. Git account
	- GitHub, Gitlab, Bitbucket


## Content

1. **main.bat**  
Windows batch script to automate git user (view, edit and reset password) commands.

## Installation

1. Clone this repository.  
`git clone https://github.com/weaponsforge/git-switcher.git`
2. Follow the GitBash configuration steps from the preceeding sub-section.

### GitBash Configuration (Windows OS only)

Configure your GitBash first with the following settings before using the script.

> ***WARNING:** These settings remove the Windows Credential Manager process handling for Git to a text-based ".gitcredentials" file from an easy-to-access location. Proceed at your discretion.*

1. Open a command prompt as an ** Administrator**  and run the command:<br>
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
6. Edit the `gitconfig` file. Delete the following lines and SAVE. (You may need Administrator access to edit the file).<br>
   ```
   [credential]
	   helper = manager
   ```
   - Restore the deleted lines anytime as needed.
   - Take note the git-switcher script will not work after restoring the deleted lines.

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