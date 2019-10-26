# git-switcher

>  Switch GitHub account credentials from git config.


### Dependencies

1. Windows 10 OS 64-bit
2. [Git Bash](https://gitforwindows.org/) for Windows
	- version 2.11.0 was used for this tool
3. GitHub account



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
3. Run `git config --list --show-origin` to view updates.
	- verify that `.gitconfig` and `.gitcredentials` are stored in **C:\Users\\[USER_NAME]** 


20191026