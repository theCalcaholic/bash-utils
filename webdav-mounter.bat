@echo off

REM # Batch script for Windows which mounts a directory from your nextcloud account as network drive

REM # I recommend to mount a password protected link share instead of using your actual credentials
REM # E.g. if your shared link is "https://your-nextcloud.domain/index.php/s/cz8G6rrESnsmeYr, the 
REM # correct values would be:
set url="https://your-nextcloud.domain/public.php/webdav"
REM # Get this id from the end of your shared link:
set user="cz8G6rrESnsmeYr"
set pw="your-share-password"

if [%pw] == [] set /p pw=Enter Nextcloud password:

set connection_count=0
:CONNECT
set /A connection_count=connection_count+1
net use K: %url% %pw% /persistent:no /user:%user%
if errorlevel 1 if %connection_count% leq 3 goto CONNECT

if errorlevel 1 (
    echo "Could not connect to %url% with user "%user%". Exiting...
) else start "" "C:\Program Files\KeePassXC\KeePassXC.exe"
timeout 3
