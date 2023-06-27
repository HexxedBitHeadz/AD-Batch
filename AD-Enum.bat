@echo off


echo  _  _  ____  _  _  _  _  ____  ____    ____  __  ____  _  _  ____   __   ____  ____ 
echo / )( \(  __)( \/ )( \/ )(  __)(    \  (  _ \(  )(_  _)/ )( \(  __) / _\ (    \(__  )
echo ) __ ( ) _)  )  (  )  (  ) _)  ) D (   ) _ ( )(   )(  ) __ ( ) _) /    \ ) D ( / _/ 
echo \_)(_/(____)(_/\_)(_/\_)(____)(____/  (____/(__) (__) \_)(_/(____)\_/\_/(____/(____)

echo.
echo.

REM Output file path
set OUTPUT_FILE=AD_Enumeration.txt

REM Clear the output file if it exists
if exist "%OUTPUT_FILE%" del "%OUTPUT_FILE%"

echo Domian: %USERDOMAIN% found...

REM Enumerate domain controllers
echo.
echo Enumerating Domain Controllers...
echo Domain Controllers: >> "%OUTPUT_FILE%"
nltest /dclist:%USERDOMAIN% >> "%OUTPUT_FILE%"

REM Enumerate user accounts
echo.
echo Enumerating User Accounts...
echo User Accounts: >> "%OUTPUT_FILE%"
net user /domain >> "%OUTPUT_FILE%"

REM Enumerate high-privileged accounts
echo.
echo Enumerating high-privileged accounts...
echo high-privileged accounts>> "%OUTPUT_FILE%"
net group "Domain Admins" /domain >> "%OUTPUT_FILE%"
net group "Enterprise Admins" /domain 2>NUL >> "%OUTPUT_FILE%"
net group "Schema Admins" /domain 2>NUL >> "%OUTPUT_FILE%"
net group "Administrators" /domain 2>NUL >> "%OUTPUT_FILE%"

REM Enumerate groups
echo.
echo Enumerating Groups...
echo Groups: >> "%OUTPUT_FILE%"
net group /domain >> "%OUTPUT_FILE%"

REM Enumerate group membership for each user
echo.
echo Enumerating Group Membership...
echo Group Membership: >> "%OUTPUT_FILE%"

REM Get list of user accounts
for /f "skip=4 tokens=*" %%U in ('net user /domain') do (
    REM Extract username from the line
    for /f "tokens=1 delims= " %%A in ("%%U") do (
        REM Output username
        echo User: %%A 2>NUL >> "%OUTPUT_FILE%"

	echo. >> "%OUTPUT_FILE%"
        REM Output group membership for the user
        echo Group Membership for %%A: 2>NUL >> "%OUTPUT_FILE%"
        net user %%A /domain | findstr /C:"Local Group Memberships" /C:"Global Group memberships" /C:"Universal Group memberships" 2>NUL >> "%OUTPUT_FILE%"
    )
)

REM Enumerate other computers in the domain
echo.
echo Enumerating Other Computers...
echo Other Computers: >> "%OUTPUT_FILE%"
for /f "skip=1 tokens=1" %%C in ('dsquery computer domainroot -limit 0') do (
    echo %%C >> "%OUTPUT_FILE%"
)

REM Enumerate shares in the domain
echo.
echo Enumerating SMB shares...

echo. >> "%OUTPUT_FILE%"
echo SMB shares: >> "%OUTPUT_FILE%"
net share >> "%OUTPUT_FILE%"

REM Done
echo.
echo Active Directory enumeration completed. Results are saved in "%OUTPUT_FILE%".

pause
