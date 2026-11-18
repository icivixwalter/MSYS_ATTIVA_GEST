@echo off
setlocal EnableExtensions
REM ==========================================================================
REM  NOME FILE : ZIP_MSYS_FILE_LIBERI_CREA.bat
REM  POSIZIONE : c:\CASA\LINGUAGGI\ACCESS\PROGETTI_MDB\MSYS\MSYS_ATTIVA_GEST\
REM  SCOPO     : salva in uno ZIP i FILE LIBERI della cartella MADRE
REM                 c:\CASA\LINGUAGGI\ACCESS\PROGETTI_MDB\MSYS\
REM              (solo i file, NON le sottocartelle dei micro progetti)
REM              Lo zip resta qui in MSYS_ATTIVA_GEST e viene salvato su
REM              GitHub insieme a questo progetto: con il pull su un altro
REM              PC si ricostruisce anche la cartella madre con
REM              ZIP_MSYS_FILE_LIBERI_RIPRISTINA.bat
REM  ZIP       : ZIP_MSYS_FILE_LIBERI.zip
REM              dentro c'e' la cartella  MSYS\  con i file: estraendolo
REM              in c:\CASA\LINGUAGGI\ACCESS\PROGETTI_MDB\ si ricrea MSYS\
REM  LOG       : ZIP_MSYS_FILE_LIBERI_CREA_LOG.txt (accanto al bat)
REM ==========================================================================
REM
REM  STRUTTURA
REM  --------------------------------------------------------------------------
REM  SETTORE 1 - INIZIALIZZAZIONE
REM     1.1  cartelle: questo bat, cartella MADRE, cartella NONNA
REM     1.2  nome dello zip e del LOG
REM     1.3  ELENCO DEI TIPI DI FILE da salvare e da escludere
REM  SETTORE 2 - CONTROLLI PRELIMINARI
REM     2.1  7-Zip installato
REM  SETTORE 3 - CREAZIONE ZIP
REM     3.1  creazione in un file temporaneo
REM     3.2  sostituzione del vecchio zip
REM  SETTORE 4 - RIEPILOGO
REM     4.1  elenco dei file contenuti nello zip
REM     4.2  esito finale
REM
REM  COME AGGIUNGERE UN TIPO DI FILE
REM  --------------------------------------------------------------------------
REM  Nel paragrafo 1.3 aggiungere il tipo a  INCLUDI  (es.  *.ini )
REM  oppure a  ESCLUDI  (es.  *_TMP.txt ). Lo zip viene RICREATO ogni volta:
REM  un file cancellato dalla cartella madre sparisce anche dallo zip.
REM ==========================================================================


REM ==========================================================================
REM  SETTORE 1 - INIZIALIZZAZIONE
REM ==========================================================================

REM --- 1.1 cartelle ----------------------------------------------------------
cd /d "%~dp0"
set "QUI=%~dp0"
REM  cartella MADRE  = cartella superiore (MSYS)
for %%M in ("%QUI%..") do set "MADRE=%%~fM"
for %%M in ("%QUI%..") do set "NOME_MADRE=%%~nxM"
REM  cartella NONNA  = cartella sopra la madre (PROGETTI_MDB)
for %%N in ("%QUI%..\..") do set "NONNA=%%~fN"

REM --- 1.2 zip e log ---------------------------------------------------------
set "ZIP=%QUI%ZIP_MSYS_FILE_LIBERI.zip"
set "ZIPTMP=%QUI%ZIP_MSYS_FILE_LIBERI.tmp.zip"
set "LOG=%~dpn0_LOG.txt"
set "SEVENZIP=%ProgramFiles%\7-Zip\7z.exe"

REM --- 1.3 tipi di file ------------------------------------------------------
REM  INCLUDI : file della cartella madre da salvare (senza sottocartelle)
REM  ESCLUDI : file da NON salvare (i log cambiano ad ogni esecuzione)
set "INCLUDI=*.bat *.txt *.md *.sublime-project .gitignore .gitattributes"
set "ESCLUDI=*_LOG.txt"

for /f "usebackq delims=" %%D in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"`) do set "ADESSO=%%D"
if not defined ADESSO set "ADESSO=%date% %time%"

call :SCRIVI ""
call :SCRIVI "##########################################################################"
call :SCRIVI "  ZIP FILE LIBERI DELLA CARTELLA MADRE - avvio %ADESSO%"
call :SCRIVI "  cartella madre : %MADRE%"
call :SCRIVI "  zip            : %ZIP%"
call :SCRIVI "  includi        : %INCLUDI%"
call :SCRIVI "  escludi        : %ESCLUDI%"
call :SCRIVI "##########################################################################"
call :SCRIVI "SETTORE 1 - INIZIALIZZAZIONE ............................. OK"


REM ==========================================================================
REM  SETTORE 2 - CONTROLLI PRELIMINARI
REM ==========================================================================
call :SCRIVI "SETTORE 2 - CONTROLLI PRELIMINARI"
if not exist "%SEVENZIP%" (
    call :SCRIVI "  2.1 7-Zip installato .................................... ERRORE"
    call :SCRIVI "      non trovato: %SEVENZIP%"
    goto :ERRORE
)
call :SCRIVI "  2.1 7-Zip installato .................................... OK"


REM ==========================================================================
REM  SETTORE 3 - CREAZIONE ZIP
REM ==========================================================================
call :SCRIVI "SETTORE 3 - CREAZIONE ZIP"

REM --- 3.1 creazione nel file temporaneo -------------------------------------
REM  ci si posiziona nella cartella NONNA cosi' nello zip i file hanno
REM  il percorso  MSYS\nomefile  ;  -r- = NON entra nelle sottocartelle
REM  (for /f su una stringa: i caratteri jolly NON vengono espansi da cmd
REM   ma passati cosi' come sono a 7-Zip)
set "LISTA="
set "RESTO=%INCLUDI%"
:CICLO_INCLUDI
if not defined RESTO goto :FINE_INCLUDI
for /f "tokens=1*" %%A in ("%RESTO%") do call :ACCODA LISTA "%NOME_MADRE%\%%A" "%%B"
goto :CICLO_INCLUDI
:FINE_INCLUDI
set "LISTA_X="
set "RESTO=%ESCLUDI%"
:CICLO_ESCLUDI
if not defined RESTO goto :FINE_ESCLUDI
for /f "tokens=1*" %%A in ("%RESTO%") do call :ACCODA LISTA_X "-x!%NOME_MADRE%\%%A" "%%B"
goto :CICLO_ESCLUDI
:FINE_ESCLUDI

if exist "%ZIPTMP%" del "%ZIPTMP%" >nul 2>&1
pushd "%NONNA%"
"%SEVENZIP%" a -tzip -r- "%ZIPTMP%" %LISTA% %LISTA_X% >> "%LOG%" 2>&1
set "RC=%errorlevel%"
popd
REM  7-Zip: 0 = OK , 1 = avviso (es. tipo di file non presente) , >1 = errore
if %RC% GTR 1 (
    call :SCRIVI "  3.1 creazione zip ....................................... ERRORE codice %RC%"
    if exist "%ZIPTMP%" del "%ZIPTMP%" >nul 2>&1
    goto :ERRORE
)
REM  controllo: lo zip deve contenere almeno un file
REM  ELENCO = elenco dettagliato dello zip, una riga  "Path = MSYS\file"  per file
set /a N_FILE=0
set "ELENCO=%TEMP%\ZIP_MSYS_FILE_LIBERI_ELENCO.tmp"
"%SEVENZIP%" l -ba -slt "%ZIPTMP%" > "%ELENCO%" 2>nul
for /f "usebackq tokens=1,* delims==" %%A in ("%ELENCO%") do if "%%A"=="Path " set /a N_FILE+=1
if %N_FILE% EQU 0 (
    call :SCRIVI "  3.1 creazione zip ....................................... ERRORE - zip vuoto"
    if exist "%ZIPTMP%" del "%ZIPTMP%" >nul 2>&1
    del "%ELENCO%" >nul 2>&1
    goto :ERRORE
)
call :SCRIVI "  3.1 file nello zip ...................................... %N_FILE%"
if "%RC%"=="1" call :SCRIVI "      (avviso 7-Zip: qualche tipo di file non presente, es. .gitignore)"
call :SCRIVI "  3.1 creazione zip ....................................... OK"

REM --- 3.2 sostituzione del vecchio zip --------------------------------------
move /y "%ZIPTMP%" "%ZIP%" >nul
if errorlevel 1 (
    call :SCRIVI "  3.2 sostituzione zip .................................... ERRORE"
    goto :ERRORE
)
call :SCRIVI "  3.2 sostituzione zip .................................... OK"


REM ==========================================================================
REM  SETTORE 4 - RIEPILOGO
REM ==========================================================================
call :SCRIVI "SETTORE 4 - RIEPILOGO"
call :SCRIVI "  4.1 file contenuti nello zip:"
for /f "usebackq tokens=1,* delims==" %%A in ("%ELENCO%") do if "%%A"=="Path " call :SCRIVI "     %%B"
del "%ELENCO%" >nul 2>&1
call :SCRIVI ""
call :SCRIVI "  4.2 ESITO FINALE: TUTTO OK"
call :SCRIVI "      ora salvare MSYS_ATTIVA_GEST su GitHub (git_STATUS+PULL+ADD+COMMIT+PUSH.BAT)"
call :SCRIVI "##########################################################################"
pause
endlocal
exit /b 0

:ERRORE
call :SCRIVI ""
call :SCRIVI "  *** ESITO FINALE: ERRORE - vedere il log ***"
call :SCRIVI "##########################################################################"
start "" notepad "%LOG%"
pause
endlocal
exit /b 1


REM --------------------------------------------------------------------------
REM  :ACCODA VARIABILE "elemento" "resto"
REM     aggiunge "elemento" (tra virgolette) alla VARIABILE
REM     e mette in RESTO gli elementi ancora da elaborare
REM --------------------------------------------------------------------------
:ACCODA
call set "%~1=%%%~1%% "%~2""
set "RESTO=%~3"
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
