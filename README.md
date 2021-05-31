# Purpose
- Automate the backup process
- Revert to any previous version of the WTF files
- Avoid excessive disk usage
- Utilize cloud storage as an additional precaution

# Summary
- Stores a backup of your WTF folder whenever the WoW program closes
- Uses Git (sophisticated version control system (VCS))
  - Extremely data efficient
  - Can revert to any iteration of the WTF folder
  - Specify saved variables files that you want to ignore
  - Easy to push up to cloud storage
	- Extra security
	- GUI that allows you to see differences between versions more easily
- Uses Lua engine to interpret and then sort the saved variables files
  - Increases storage efficiency
  - Increases readability of the differences (deltas) between versions
- Works for PTR, Retail, Classic, and BC Classic, but can be made to work for other clients with minimal effort

# Setup
#### Software
- Windows 10
- World of Warcraft
- AutoHotkey (Download current version from here: https://www.autohotkey.com/)
- Lua for Windows v5.1.5-52 (Download the .exe from here: https://github.com/rjpcomputing/luaforwindows/releases)
- Git (Version shouldn't matter. Just get the most recent from here: https://git-scm.com/download/win)
- WTF Backup.zip (The code in this repo: https://github.com/AdamHayse/WTF-Backup)
- Notepad++ (Recommended) (Get most recent version from here: https://notepad-plus-plus.org/downloads/)

#### Set Up Backup Directory
- Extract contents from WTF Backup.zip to where you want your backup stored. I have mine at C:\Users\Adam\Desktop\WTF Backup. There should be 4 files in WTF Backup.

#### Configure Backup Directory Files
1. Right click initialize_backup_directories.cmd and click Edit with Notepad++ (or just Edit if you didn't install Notepad++).
2. Change the text to the right of the "=" on line 3 to the installation location of WoW on your computer:

       set wow_dir=C:\Program Files (x86)\World of Warcraft

    > **WARNING**
    > Do not include a space directly to the right of the "=".
    > Windows will think it is part of the directory name.

3. Save and close the file.
4. Right click wow_backup.ahk and click Edit with Notepad++ (or open it in Notepad).
5. Change the text between the double quotes on line 1 to the installation location of WoW on your computer

       __wow_dir := "C:\Program Files (x86)\World of Warcraft"

6. Save and close the file.

#### Initialize the Backup Directories
1. Double click initialize\_backup\_directories.cmd and wait until it prompts you to press any key to continue.
    - This script looks for your WoW installation, copies WTF folders, and initializes Git repos for them.
    - The backups are created for \_retail\_, \_classic\_era\_ (which is Classic), \_classic\_ (which is BC Classic), and \_ptr\_.
    - If you are missing one of these folders due to not having its respective client installed, then it will be ignored.
    - This script can be run again later if these clients are installed in the future to setup backups. This won't affect existing backups.
    - If you want to reinitialize a backup, delete the backup folder (ex. Retail Backup) and run this script again.
2. Press any key to close the window.
3. Run the AutoHotkey script
    - Right click wow\_backup.ahk and click Compile Script. This will create a file called wow_backup.exe.
    - Right click wow_backup.exe and click Run as administrator.

      > **WARNING**
      > This script will not work properly if it is not run as administrator.

    - This script listens for the Windows event that signifies the WoW client closing and then triggers the backup process.
    - This script must run in the background for the automated backups to occur.
    - You can see that the script is running by looking in the system tray on the bottom right of your screen (it's a green box with a white H in it).

#### Run AutoHotkey Script on Startup (Optional)
1. Search Task Scheduler in the Windows search bar on the bottom left of your screen.
2. In the right window labeled 'Actions', click "Create Basic Task...".
3. Give the Task a name; I called mine "WoW Data Backup AHK Script".
4. Give the Task a description; I entered "Runs an AHK script that commits WTF folder backups when the WoW window closes".
5. Click "Next".
6. Click the radio button that says "When I log on".
7. Click "Next".
8. Make sure that the radio button that says "Start a program" is selected.
9. Click "Next".
10. In Program/script, enter the location/file to be run. Make sure that you surround it with double quotes if there is a space in a directory name within the file path.
Example: "C:\Users\Adam\Desktop\WTF Backup\wow_backup.exe"
11. Click "Next".
12. Click "Finish".
13. Observe that the new task is created by scrolling through the panel in the top center of the Task Scheduler window.
14. Close the window to exit.

#### Ignore Unimportant Saved Variables (Optional)
1. Start by double clicking restore\_to\_current\_version.cmd in the Backup folder.
    - This ensures that you are committing off of the most recent version of your WTF folder.
2. In each Backup folder, there is a file called .gitignore.
    - If it's not visible to you, then you need to show hidden files. Click View on the top left of the File Explorer window and then check the box that says "Hidden items".
3. Right click .gitignore and click Edit with Notepad++ (or open it in Notepad).
4. In this file, you can enter the names of files that should be ignored in the backup. Enter one file name per line.
Example:

        WTF/SavedVariables/Blizzard_Console.lua
        WTF/Account/<Your Account Name>/SavedVariables/Blizzard_AuctionHouseUI.lua
        WTF/Account/<Your Account Name>/SavedVariables/Details_DataStorage.lua

5. Once you are done adding files that you want to ignore, click Save and close this file.
6. Double click the file called commit_gitignore.cmd to commit the updated .gitignore file.
    - Ignored files will not be removed right away.  They will be removed when the next backup is committed.
7. That's it.
8. If you want to update this list in the future, follow this same process again.

# Regular Usage Behavior
When the WoW client exists (not logout, but the application closing completely), the AutoHotkey script commits a backup if a backup directory exists. The process looks like this:
1. The Command Prompt opens (black box).
2. The backup directory is set to the most recent version if a previous version is checked out.
3. The recently updated WTF folder from the WoW installation directory is copied and pasted into the backup directory (replacing the old backup).
4. The .bak and .old files in the WTF copy are deleted. These are WoW's basic backup system that only stores 1 WTF version earlier.
5. The files specified in the .gitignore file are deleted from the WTF copy.
6. The remaining .lua files in the copy are sorted.
	- These Lua files contain data used by your addons.
	- The data is mostly key-value pairs, and game exports this data in various orders because order does not matter.
	- In order to help Git detect legitimate changes in this data (rather than just rearranged data), the key-value pairs are sorted alphabetically.
	- Sorting also reduces the differences (deltas) between versions and helps to save space.
	- Sorting does not change the data in any way because order does not matter.
7. The processed WTF copy is committed to the Git repository. This means that it is fully backed up, and can be pushed up to cload storage if desired.

# How to Recover a Previous Version
1. Start by double clicking restore\_to\_current\_version.cmd in the Backup folder. This ensures that git repo is up to date with a clean working tree.
2. You should turn off the AutoHotkey script by right clicking the green box with the white H in the windows system tray, and then clicking Exit. This prevents the WTF backup from being overwritten with the older checked out version.
3. Determine a time frame that you want to search within.
4. Navigate to the backup directory (ex. Retail Backup).
5. Right click within the directory (don't right click a file, just the blank space), and click "Git Bash Here".
6. Enter the following into the black box, replacing the date range values as appropriate:
	
	   git log --all --after="YYYY-MM-DD hh:mm:ss" --until="YYYY-MM-DD hh:mm:ss"
	
7. Get the first 8 characters of the hash code that represents a particular commit.
8. Enter the following into the black box, replacing the X's with your 8 character hash code:

       git checkout XXXXXXXX
	
    Your backup repo now contains the WTF folder as it was in the specified commit.
9. Copy the WTF from the respective client folder (Ex. \_retail\_) and paste it somewhere as a backup just incase something goes wrong; Git can be tricky.
10. Right click the WTF folder in the backup folder and copy it.
11. Paste it over the WTF folder in the respective client folder (Ex. \_retail\_).
      
      > **WARNING**
      > Make sure to disable/exit the AutoHotkey script that initiates the backup.
      > If you don't, then exiting the game will commit the older version over the most recent one.

    If you make the mistake described above, your most recent version can still be recovered.  I'll make a section for this scenario since it requires some technical knowledge of Git.
12. Now you can log into the game with the previous version of the WTF folder (minus the excluded saved variables in the .gitignore file).
13. At this point, you can recover things like WeakAuras or any other addon profile using the addon's export tool within the game.

# I accidentally committed a previous version over my most recent version. What do I do?
1. Navigate to the backup directory (ex. Retail Backup).
2. Right click within the directory (don't right click a file, just the blank space), and click "Git Bash Here".
3. Type the following and hit enter:

       git log

    This command will list your previous commits. Press space to view more or 'q' end the git log command.
4. Make a note of the first 8 characters of the hash code for the commit that you want to revert to.
5. Type the following, replacing the X's with the 8 character hash code, and hit enter:

       git checkout XXXXXXXX

6. If you are confident that this is the commit that you want to revert to, type the following and hit enter: git reset --hard

      > **WARNING**
      > A hard reset will permanently delete all commits that have happened after the currently checked out commit (excluding the currently checked out commit).

7. If you have excuted the previous step, then you can stop here. Otherwise, continue.
8. If you are at this step, then you are not confident that you have correct commit checked out.  Follow steps 9 through 13 in the section called **How to Recover a Previous Version**. Make sure to disable the AutoHotkey script this time.
9. Once you are satisfied that the correct commit is checked out, perform step 6 of this section.
10. If the wrong commit is checked out, go back to step 3 of this section and try a different commit.
Note: This process can be tedious and stressful, especially if you aren't familiar with Git and its concepts. Just remember that your data can always be recovered with Git as long as you don't perform a hard reset while a previous commit is checked out.


# Cloud Storage (Optional)
I use GitHub for cloud storage, so I'll use this as an example.
1. Set up a GitHub account if you don't already have one.
2. Initialize a new repository by clicking the green New button on the left side of the main page (https://github.com/).
3. Give it a name, description, and set the repository visibility to private. I named mine WoW-retail-data-PC because I have a separate backup for retail on my laptop.
4. Click the green button that says "Create repository".
5. Click the clipboard button to the right of the text that says "…or push an existing repository from the command line" to copy these commands to the clipboard.
6. In Windows File Explorer, navigate to the backup directory that you want to store in the cloud. Example: Retail Backup
7.  Right click in the empty space within the directory and click "Git Bash Here". Command Prompt (a black box) will open.
8.  Right click in Command Prompt. This will paste what is in your clipboard.
	- Pasting will cause the first two lines to run instantly because the clipboard contains new line characters.
9.  Hit Enter to run the final command and push your local backup repo into the cloud repo that you just set up.
	- If a prompt for a username and password appears, enter your username and password.
	- This prompt generally only happens once, so I don't remember the exact process. If you can't figure it out, then you probably shouldn't be using this VCS strategy.
10. That's it. You can close Command Prompt.
Note: Remote backup will not happen automatically when exiting that game like the local backup does. It must be pushed manually. Push manually by opening right clicking in the empty space within the directory, clicking "Git Bash Here", and then entering the following command:
		
	    git push
		
Note: I did not automate the remote backup process due to the following reasons:
- I want there to be a simple fail-safe for people who aren't used to Git, and something goes wrong in their local that they don't have the knowledge to easily recover.
- There are edge case scenarios that are complex. For example, if internet is lost and WoW is closed, it should still attempt to commit backups locally, but it can't push to remote. Automatically pushing to remote when internet connection is restored would require another solution that I would need to research, and I think there is more value in having this be a manual process.

# Credits
- wibe from the WoWDev discord for a simple AutoHotkey script that I was able to build from.
- Zlodo from the WoWDev discord for the Lua script that sorts the saved variables Lua files.
