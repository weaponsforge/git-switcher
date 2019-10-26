# git-switcher

>  Switch GitHub account credentials from git config.


### Dependencies

1. Windows 10 OS 64-bit
2. [Git Bash](https://gitforwindows.org/) for Windows
	- version 2.11.0 was used for this tool
	- installed using default options
3. GitHub account


## Content

1. **main.bat**  
Windows batch script to automate git user (view, edit) commands.


## Usage

1. Clone this repository.  
`git clone https://github.com/weaponsforge/git-switcher.git`

2. If you have **GitBash** previously installed, configure it first with the following settings:  
	- Delete your **github** access credentials from the **Windows Credentials Manager**
		- Search for **Credential Manager** from the Search box
		- Click the **Windows Credentials** button
		- Find and delete the entry for **github**
	- Open a command prompt as an **Administrator** and run the command:  
`git config --global credential.helper "store --file ~/.gitcredential"`
	- Run `git config --list --show-origin` to view updates.  
	Verify that `.gitconfig` and `.gitcredentials` files are created in **C:\Users\\[USER_NAME]** 

3. Run the windows batch script file **main.bat**
	- Select **Option [1]** to view Git's current `user.email` and `user.config`
	- Select **Option [2]** to edit the current `user.email` and `user.config`
	- Select **Option [3]** to exit.

20191026