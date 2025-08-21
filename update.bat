@echo off
setlocal enabledelayedexpansion

:: ---------- CONFIGURATION ----------
:: Replace YOUR_USERNAME and YOUR_PAT with your GitHub username and Personal Access Token
set GITHUB_USER=niccocadoni
set GITHUB_PAT=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
set REPO_NAME=niccocadoni/hhexport
set BRANCH=main
set COMMIT_MSG=Update hhexport files
set OUTPUT_FILE=hhexport_links.txt

:: ---------- SET REMOTE URL WITH PAT ----------
git remote set-url origin https://%GITHUB_USER%:%GITHUB_PAT%@github.com/%REPO_NAME%.git

:: ---------- ADD FILES ----------
git add hhexport

:: ---------- GET FILES ADDED / MODIFIED ----------
set FILES_ADDED=
for /f "tokens=*" %%f in ('git diff --cached --name-only --diff-filter=AM -- hhexport') do (
    set FILES_ADDED=!FILES_ADDED! %%f
)

:: ---------- GET FILES REMOVED ----------
set FILES_REMOVED=
for /f "tokens=*" %%f in ('git diff --cached --name-only --diff-filter=D -- hhexport') do (
    set FILES_REMOVED=!FILES_REMOVED! %%f
)

:: ---------- NO CHANGES ----------
if "%FILES_ADDED%"=="" if "%FILES_REMOVED%"=="" (
    echo.
    echo Nessun cambiamento trovato in hhexport.
    echo.
    pause
    exit /b 0
)

:: ---------- COMMIT & PUSH ----------
git commit -m "%COMMIT_MSG%"
git push origin %BRANCH%

:: ---------- READ DOMAIN FROM CNAME ----------
set /p DOMAIN=<CNAME

:: ---------- GENERATE LINKS FOR ADDED FILES ----------
if not "%FILES_ADDED%"=="" (
    echo. >> %OUTPUT_FILE%
    echo ==== Aggiornamento del %date% %time% ==== >> %OUTPUT_FILE%
)

for %%f in (%FILES_ADDED%) do (
    set LINK=https://%DOMAIN%/%%f
    echo !LINK!
    echo !LINK! >> %OUTPUT_FILE%
)

:: ---------- REMOVE LINKS OF DELETED FILES ----------
if not "%FILES_REMOVED%"=="" (
    echo.
    echo Rimozione link relativi a file eliminati...

    copy "%OUTPUT_FILE%" "%OUTPUT_FILE%.tmp" >nul
    break > "%OUTPUT_FILE%"

    for /f "usebackq delims=" %%l in ("%OUTPUT_FILE%.tmp") do (
        set LINE=%%l
        set SKIP_LINE=0
        for %%r in (%FILES_REMOVED%) do (
            set TESTLINK=https://%DOMAIN%/%%r
            if "!LINE!"=="!TESTLINK!" (
                set SKIP_LINE=1
            )
        )
        if !SKIP_LINE! EQU 0 echo !LINE!>>"%OUTPUT_FILE%"
    )

    del "%OUTPUT_FILE%.tmp"
)

echo.
echo Operazione completata. I link aggiornati si trovano in %OUTPUT_FILE%.
echo.

pause
endlocal
