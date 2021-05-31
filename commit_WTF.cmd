@echo off
mode con: cols=100 lines=31
cd %1
echo ********************************
echo ** Performing WoW Data Backup **
echo **        DO NOT CLOSE        **
echo ********************************
echo.
git reset --hard
git clean -fdq
git checkout
echo.
rmdir  /s /q WTF
echo Copying WTF from %2 to "%CD%"...
xcopy /s /i /e /q "%~2\WTF" ".\WTF"
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
echo Deleting ignored files from WTF copy...
git rm -r --cached --quiet .
git add . >nul 2>&1
git clean -xdfq
echo Done.
echo.
echo Performing lexicographic sort of associative array key-values in Lua files...
echo This will take a minute. Don't touch anything.
lua ..\sort_sv.lua
echo Done.
echo.
echo Committing...
git add . && git commit -a --allow-empty-message -m '' --quiet
echo Done.   
echo.
echo Backup done.
echo.
timeout 5