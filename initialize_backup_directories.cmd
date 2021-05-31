@echo off
mode con: cols=100 lines=30
set wow_dir=C:\Program Files (x86)\World of Warcraft
echo Checking for git install...
echo.
git --version
if %ERRORLEVEL% neq 0 (
    echo Install git before attempting to run this script
    pause
    exit
)
echo.
set list=Retail:_retail_,PTR:_ptr_,Classic:_classic_era_,BC Classic:_classic_
if exist "%wow_dir%" (
	for %%a in ("%list:,=" "%") do (
		for /f "tokens=1,2 delims=:" %%A in ("%%~a") do (
			if exist "%wow_dir%\%%~B" (
				if not exist "%%~A Backup" (
					mkdir "%%~A Backup"
					if %ERRORLEVEL% neq 0 (
						echo Failed to create directory %%~A Backup
					) else (
						cd %%~A Backup
						git init --quiet
						git config --local core.autocrlf false
						git branch -m master main
						echo "" > .gitignore
						(echo git reset --hard && echo git clean -fdq && echo git checkout main && echo pause) > restore_to_current_version.cmd
						(echo git add .gitignore && echo git commit -m "Update .gitignore" && echo pause) > commit_gitignore.cmd
						echo Copying WTF from "%wow_dir%\%%~B" to "%CD%\%%~A Backup"...
						xcopy /s /i /e /q "%wow_dir%\%%~B\WTF" ".\WTF"
						echo Done.
						echo.
						echo Deleting unnecessary .bak files from WTF copy...
						del /s /q *.bak  >nul 2>&1
						echo Done.
						echo.
						echo Deleting unnecessary .old files from WTF copy...
						del /s /q *.old  >nul 2>&1
						echo Done.
						echo.
						echo Performing lexicographic sort of associative array key-values in WTF copy...
						echo This may take a minute. Don't touch anything.
						lua ..\sort_sv.lua
						echo Done.
						echo.
						echo Committing...
						git add . >nul 2>&1
						git commit -m "Initial commit" --quiet
						echo Done.
						cd ..
					)
				) else (
					echo %%~A Backup folder already exists.
				)
			) else (
				echo %%~B directory does not exist. Run this script again if it is created in the future.
			)
			echo.
			echo ----------------------------------------------------------------------------------------------------
			echo.
		)
	)
) else (
    echo Unable to locate installation directory for World of Warcraft. Make sure the wow_dir variable on line 3 of this script is properly set, and make sure there are no spaces directly to the right of the equals sign.
    echo.
    echo Example: "set wow_dir=C:\Program Files (x86)\World of Warcraft"
)
pause