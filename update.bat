@echo off
setlocal enabledelayedexpansion

:: Messaggio di commit
set COMMIT_MSG=Update hhexport files

:: Aggiunge solo i file nella cartella hhexport (anche quelli rimossi)
git add hhexport

:: Ricava i file aggiunti o modificati (staged)
set FILES_ADDED=
for /f "tokens=*" %%f in ('git diff --cached --name-only --diff-filter=AM -- hhexport') do (
    set FILES_ADDED=!FILES_ADDED! %%f
)

:: Ricava i file rimossi (staged)
set FILES_REMOVED=
for /f "tokens=*" %%f in ('git diff --cached --name-only --diff-filter=D -- hhexport') do (
    set FILES_REMOVED=!FILES_REMOVED! %%f
)

:: Se non ci sono cambiamenti, mostra messaggio e lascia la console aperta
if "%FILES_ADDED%"=="" if "%FILES_REMOVED%"=="" (
    echo.
    echo Nessun cambiamento trovato in hhexport.
    echo.
    pause
    exit /b 0
)

:: Commit & Push
git commit -m "%COMMIT_MSG%"
git push origin main

:: Legge il dominio dal file CNAME
set /p DOMAIN=<CNAME

:: File di output
set OUTPUT_FILE=hhexport_links.txt

:: Aggiunge intestazione con data/ora se ci sono file aggiunti
if not "%FILES_ADDED%"=="" (
    echo. >> %OUTPUT_FILE%
    echo ==== Aggiornamento del %date% %time% ==== >> %OUTPUT_FILE%
)

:: Scrive i link dei file aggiunti
for %%f in (%FILES_ADDED%) do (
    set LINK=https://%DOMAIN%/%%f
    echo !LINK!
    echo !LINK! >> %OUTPUT_FILE%
)

:: Se ci sono file rimossi, ricrea temporaneamente il file senza quei link
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
