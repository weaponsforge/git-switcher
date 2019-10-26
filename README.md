# git-switcher

>  Switch Git global account credentials from git config.  
>  Reset the git user's password for GitHub, GitLab or BitBucket.


### Dependencies

1. Windows 10 OS 64-bit
2. [Git Bash](https://gitforwindows.org/) for Windows
	- version 2.33.0.windows.1 was used for this tool
	- installed using default options
3. Git account
	- GitHub, Gitlab, Bitbucket


## Content

1. **main.bat**  
Windows batch script to automate git user (view, edit and reset password) commands.


## Usage

1. Clone this repository.  
`git clone https://github.com/weaponsforge/git-switcher.git`

2. If you have **GitBash** previously installed, configure it first with the following settings:  
	- Delete your **github** access credentials from the **Windows Credentials Manager**
		- Search for **Credential Manager** from the Search box
		- Click the **Windows Credentials** button
		- Find and delete the entry for **github**, **gitlab**, or **bitbucket**
	- Open a command prompt as an **Administrator** and run the command:  
`git config --global credential.helper "store --file ~/.gitcredential`
	- Run `git config --list --show-origin` to view updates.  
	Verify that `.gitconfig` and `.gitcredentials` files are created in **C:\Users\\[USER_NAME]** 

3. Click to run the windows batch script file **main.bat**. You may need to run it as an **Administrator** if there will be privilege errors.
	- Select **Option [1]** to **View** the current Git user's global `user.email` and `user.config`
	- Select **Option [2]** to **Edit** the current global `user.email` and `user.config`
		- You will be prompted for which Git version control provider would you like to reset the password.
			- Select sub-option **[1]** for **GitHub**
			- Select sub-option **[2]** for **GitLab**
			- Select sub-option **[3]** for **BitBucket**
			- Select sub-option **[4]** to **Exit**
	- Select **Option [3]** to exit.
	- Press **Ctrl + C** to exit any time.

20191026