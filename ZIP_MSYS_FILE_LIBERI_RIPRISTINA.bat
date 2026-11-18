@echo off
setlocal EnableExtensions
REM ==========================================================================
REM  NOME FILE : ZIP_MSYS_FILE_LIBERI_RIPRISTINA.bat
REM  POSIZIONE : c:\CASA\LINGUAGGI\ACCESS\PROGETTI_MDB\MSYS\MSYS_ATTIVA_GEST\
REM  SCOPO     : RICOSTRUISCE i FILE LIBERI della cartella MADRE
REM                 c:\CASA\LINGUAGGI\ACCESS\PROGETTI_MDB\MSYS\
REM              estraendo ZIP_MSYS_FILE_LIBERI.zip (creato da
REM              ZIP_MSYS_FILE_LIBERI_CREA.bat e arrivato con il pull).
REM  LOG       : ZIP_MSYS_FILE_LIBERI_RIPRISTINA_LOG.txt (accanto al bat)
REM ==========================================================================
REM
REM  RICOSTRUZIONE COMPLETA SU UN PC NUOVO
REM  --------------------------------------------------------------------------
REM  1) creare  c:\CASA\LINGUAGGI\ACCESS\PROGETTI_MDB\MSYS\MSYS_ATTIVA_GEST\
REM     copiarci git_PULL.BAT e lanciarlo (scarica tutto da GitHub)
REM  2) lanciare QUESTO bat: ricrea i file liberi di MSYS\ (bat collettivi)
REM  3) lanciare  MSYS\DOS_ATTIVA_TUTTI_PULL_GIT.bat : scarica da GitHub
REM     (clone) tutti i micro progetti che mancano e aggiorna gli altri
REM
REM  STRUTTURA
REM  --------------------------------------------------------------------------
REM  SETTORE 1 - INIZIALIZZAZIONE
REM     1.1  cartelle: questo bat, cartella MADRE, cartella NONNA
REM     1.2  nome dello zip, del LOG e della copia di sicurezza
REM  SETTORE 2 - CONTROLLI PRELIMINARI
REM     2.1  lo zip esiste
REM     2.2  programma per estrarre: 7-Zip, altrimenti tar di Windows
REM  SETTORE 3 - RIPRISTINO
REM     3.1  elenco dei file e conferma
REM     3.2  copia di sicurezza dei file liberi attuali (AA_SALVATAGGI)
REM     3.3  estrazione nella cartella NONNA (ricrea MSYS\...)
REM  SETTORE 4 - ESITO FINALE
REM
REM  DUE MODI DI FUNZIONAMENTO
REM  --------------------------------------------------------------------------
REM  - lanciato a mano (senza parametri) = modo TUTTI
REM      chiede conferma, fa la copia di sicurezza e SOVRASCRIVE i file
REM      della cartella madre con quelli dello zip. Le versioni precedenti
REM      restano in  AA_SALVATAGGI\ZIP_MSYS_FILE_LIBERI_PRIMA_<data>.zip
REM  - con il parametro  SOLO_MANCANTI  (lo usa git_PULL.BAT dopo il pull)
REM      nessuna domanda, nessuna pausa: crea la cartella madre se non
REM      esiste e vi estrae SOLO i file che MANCANO; i file gia' presenti
REM      NON vengono mai toccati
REM ==========================================================================


REM ==========================================================================
REM  SETTORE 1 - INIZIALIZZAZIONE
REM ==========================================================================

REM --- 1.1 cartelle ----------------------------------------------------------
cd /d "%~dp0"
set "QUI=%~dp0"
for %%M in ("%QUI%..") do set "MADRE=%%~fM"
for %%M in ("%QUI%..") do set "NOME_MADRE=%%~nxM"
for %%N in ("%QUI%..\..") do set "NONNA=%%~fN"

REM --- 1.2 zip, log, copia di sicurezza --------------------------------------
set "ZIP=%QUI%ZIP_MSYS_FILE_LIBERI.zip"
set "LOG=%~dpn0_LOG.txt"
set "SEVENZIP=%ProgramFiles%\7-Zip\7z.exe"
set "TARWIN=%SystemRoot%\System32\tar.exe"
REM  modo: TUTTI (a mano) oppure SOLO_MANCANTI (da git_PULL.BAT)
set "MODO=TUTTI"
if /i "%~1"=="SOLO_MANCANTI" set "MODO=SOLO_MANCANTI"
for /f "usebackq delims=" %%D in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"`) do set "ADESSO=%%D"
if not defined ADESSO set "ADESSO=%date% %time%"
for /f "usebackq delims=" %%D in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy_MM_dd_HH_mm_ss'"`) do set "TIMBRO=%%D"
if not defined TIMBRO set "TIMBRO=copia"
set "BACKUP=%QUI%AA_SALVATAGGI\ZIP_MSYS_FILE_LIBERI_PRIMA_%TIMBRO%.zip"

call :SCRIVI ""
call :SCRIVI "##########################################################################"
call :SCRIVI "  RIPRISTINO FILE LIBERI DELLA CARTELLA MADRE - avvio %ADESSO%"
call :SCRIVI "  zip            : %ZIP%"
call :SCRIVI "  cartella madre : %MADRE%"
call :SCRIVI "##########################################################################"
call :SCRIVI "SETTORE 1 - INIZIALIZZAZIONE ............................. OK"


REM ==========================================================================
REM  SETTORE 2 - CONTROLLI PRELIMINARI
REM ==========================================================================
call :SCRIVI "SETTORE 2 - CONTROLLI PRELIMINARI"

REM --- 2.1 lo zip esiste -----------------------------------------------------
if not exist "%ZIP%" (
    call :SCRIVI "  2.1 zip presente ........................................ ERRORE"
    call :SCRIVI "      manca %ZIP% : eseguire prima il pull"
    goto :ERRORE
)
call :SCRIVI "  2.1 zip presente ........................................ OK"

REM --- 2.2 programma per estrarre --------------------------------------------
set "ESTRATTORE="
if exist "%SEVENZIP%" set "ESTRATTORE=7ZIP"
if not defined ESTRATTORE if exist "%TARWIN%" set "ESTRATTORE=TAR"
if not defined ESTRATTORE (
    call :SCRIVI "  2.2 programma per estrarre .............................. ERRORE"
    call :SCRIVI "      non trovati ne' 7-Zip ne' tar di Windows"
    goto :ERRORE
)
call :SCRIVI "  2.2 programma per estrarre .............................. OK (%ESTRATTORE%)"


REM ==========================================================================
REM  SETTORE 3 - RIPRISTINO
REM ==========================================================================
call :SCRIVI "SETTORE 3 - RIPRISTINO"

REM --- 3.1 elenco e conferma -------------------------------------------------
call :SCRIVI "  3.1 file contenuti nello zip (da estrarre in %NONNA%\)"
REM  ELENCO = elenco dettagliato dello zip, una riga  "Path = MSYS\file"  per file
set "ELENCO=%TEMP%\ZIP_MSYS_FILE_LIBERI_ELENCO.tmp"
if "%ESTRATTORE%"=="7ZIP" (
    "%SEVENZIP%" l -ba -slt "%ZIP%" > "%ELENCO%" 2>nul
    for /f "usebackq tokens=1,* delims==" %%A in ("%ELENCO%") do if "%%A"=="Path " call :SCRIVI "     %%B"
) else (
    for /f "delims=" %%F in ('""%TARWIN%" -tf "%ZIP%""') do call :SCRIVI "      %%F"
)
if "%MODO%"=="SOLO_MANCANTI" (
    call :SCRIVI "      modo SOLO_MANCANTI: si estraggono solo i file che mancano"
    call :SCRIVI "  3.2 copia di sicurezza .................................. NON SERVE (nessun file sovrascritto)"
    goto :ESTRAI
)
echo.
choice /c SN /m "  Confermi il ripristino (i file presenti verranno SOVRASCRITTI)"
if errorlevel 2 (
    call :SCRIVI "      ripristino ANNULLATO dall'utente"
    goto :FINE_ANNULLATO
)
call :SCRIVI "      confermato"

REM --- 3.2 copia di sicurezza dei file attuali -------------------------------
if not "%ESTRATTORE%"=="7ZIP" (
    call :SCRIVI "  3.2 copia di sicurezza .................................. SALTATA (serve 7-Zip)"
    goto :ESTRAI
)
if not exist "%QUI%AA_SALVATAGGI" mkdir "%QUI%AA_SALVATAGGI"
REM  stessi file contenuti nello zip, presi dalla cartella madre attuale
set "LISTA="
for /f "usebackq tokens=1,* delims==" %%A in ("%ELENCO%") do if "%%A"=="Path " call :AGGIUNGI "%%B"
if not defined LISTA goto :BACKUP_VUOTO
pushd "%NONNA%"
"%SEVENZIP%" a -tzip -r- "%BACKUP%" %LISTA% >> "%LOG%" 2>&1
set "RC=%errorlevel%"
popd
if %RC% GTR 1 (
    call :SCRIVI "  3.2 copia di sicurezza .................................. ERRORE codice %RC%"
    goto :ERRORE
)
if exist "%BACKUP%" (
    call :SCRIVI "  3.2 copia di sicurezza .................................. OK"
    call :SCRIVI "      %BACKUP%"
    goto :ESTRAI
)
:BACKUP_VUOTO
call :SCRIVI "  3.2 copia di sicurezza .................................. nessun file da salvare"

REM --- 3.3 estrazione nella cartella NONNA -----------------------------------
:ESTRAI
if defined ELENCO del "%ELENCO%" >nul 2>&1
REM  TUTTI         : 7-Zip -aoa (sovrascrive)   / tar normale
REM  SOLO_MANCANTI : 7-Zip -aos (salta esistenti) / tar -k (non sovrascrive)
set "OPZ_7Z=-aoa"
set "OPZ_TAR="
if "%MODO%"=="SOLO_MANCANTI" set "OPZ_7Z=-aos"
if "%MODO%"=="SOLO_MANCANTI" set "OPZ_TAR=-k"
if "%ESTRATTORE%"=="7ZIP" (
    "%SEVENZIP%" x -tzip %OPZ_7Z% -y "%ZIP%" -o"%NONNA%" >> "%LOG%" 2>&1
) else (
    "%TARWIN%" -xf "%ZIP%" %OPZ_TAR% -C "%NONNA%" >> "%LOG%" 2>&1
)
if errorlevel 1 (
    call :SCRIVI "  3.3 estrazione .......................................... ERRORE"
    goto :ERRORE
)
call :SCRIVI "  3.3 estrazione .......................................... OK"


REM ==========================================================================
REM  SETTORE 4 - ESITO FINALE
REM ==========================================================================
call :SCRIVI ""
call :SCRIVI "  ESITO FINALE: TUTTO OK - file liberi ricreati in %MADRE%"
call :SCRIVI "  per i micro progetti lanciare: %MADRE%\DOS_ATTIVA_TUTTI_PULL_GIT.bat"
call :SCRIVI "##########################################################################"
if not "%MODO%"=="SOLO_MANCANTI" pause
endlocal
exit /b 0

:FINE_ANNULLATO
call :SCRIVI "##########################################################################"
pause
endlocal
exit /b 0

:ERRORE
call :SCRIVI ""
call :SCRIVI "  *** ESITO FINALE: ERRORE - vedere il log ***"
call :SCRIVI "##########################################################################"
if not "%MODO%"=="SOLO_MANCANTI" start "" notepad "%LOG%"
if not "%MODO%"=="SOLO_MANCANTI" pause
endlocal
exit /b 1


REM --------------------------------------------------------------------------
REM  :AGGIUNGI " MSYS\file"  -> aggiunge alla LISTA il file se esiste gia'
REM --------------------------------------------------------------------------
:AGGIUNGI
set "F=%~1"
REM  toglie lo spazio iniziale lasciato da  "Path = "
if "%F:~0,1%"==" " set "F=%F:~1%"
if exist "%NONNA%\%F%" set LISTA=%LISTA% "%F%"
exit /b 0

REM --------------------------------------------------------------------------
REM  :SCRIVI "testo"  -> scrive a video e nel log
REM --------------------------------------------------------------------------
:SCRIVI
if "%~1"=="" goto :SCRIVI_VUOTO
echo(%~1
>> "%LOG%" echo(%~1
exit /b 0
:SCRIVI_VUOTO
echo.
>> "%LOG%" echo.
exit /b 0
