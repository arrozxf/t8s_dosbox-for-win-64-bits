@echo off
setlocal EnableDelayedExpansion
title CORRER T8S
rem ============================================================
rem  CORRER_T8S.bat  -  Corre todas las redes de TRANSYT 8S
rem
rem  Estructura esperada (carpeta sin espacios, ej. C:\T8S):
rem     CORRER_T8S.bat
rem     T8S.EXE
rem     mingw\           (DOSBox-X)
rem     redes\           (aqui se colocan las redes *.prn a correr)
rem     resultados\      (aqui quedan los resultados de cada red)
rem
rem  Funcionamiento: cada red se copia a una carpeta temporal con un
rem  nombre corto N001.PRN, N002.PRN, etc. Se abre UNA sola sesion de
rem  DOSBox-X que ejecuta un lote DOS. Para cada red, el comando
rem  AUTOTYPE de DOSBox-X escribe en T8S el nombre de datos y el de
rem  salida, S001.TXT, S002.TXT, etc. Al terminar, cada salida se
rem  mueve a  resultados\resultados - NOMBRE_RED.txt
rem ============================================================

rem ---------------- CONFIGURACION ----------------
rem Extension de los archivos de datos que se buscan en la carpeta redes
set "EXT=prn"
rem 1 = DOSBox-X queda abierto al final, para revisar la pantalla. Se cierra con la X.
rem 0 = DOSBox-X se cierra solo al terminar todas las redes.
set "PAUSA=0"
rem Segundos que AUTOTYPE espera antes de empezar a escribir, para dar tiempo a que T8S abra
set "ESPERA=2"
rem Segundos entre tecla y tecla
set "PACE=0.15"
rem Teclas adicionales al final de cada red, por si T8S pide una tecla para terminar, por ejemplo: enter
set "EXTRA="
rem -----------------------------------------------

set "DIR=%~dp0"
if "%DIR:~-1%"=="\" set "DIR=%DIR:~0,-1%"

echo.
echo  CORRER T8S - lote de redes TRANSYT 8S
echo  Carpeta: %DIR%
echo.

if not "%DIR%"=="%DIR: =%" (
  echo ERROR: la ruta de la carpeta tiene espacios. Mueva todo a una ruta corta, por ejemplo C:\T8S
  pause
  exit /b 1
)
if not exist "%DIR%\T8S.EXE" (
  echo ERROR: no esta T8S.EXE en esta carpeta.
  pause
  exit /b 1
)
if not exist "%DIR%\redes\" (
  echo ERROR: no existe la carpeta redes. Cree la carpeta redes y coloque ahi los archivos *.%EXT%
  pause
  exit /b 1
)
if not exist "%DIR%\resultados\" md "%DIR%\resultados"

rem ---------------- BUSCAR DOSBOX-X ----------------
set "DOSBOX="
if exist "%DIR%\DOSBOX_RUTA.txt" set /p DOSBOX=<"%DIR%\DOSBOX_RUTA.txt"
if defined DOSBOX if not exist "!DOSBOX!" set "DOSBOX="
if not defined DOSBOX if exist "%DIR%\dosbox-x.exe" set "DOSBOX=%DIR%\dosbox-x.exe"
if not defined DOSBOX for /f "delims=" %%I in ('dir /s /b "%DIR%\dosbox-x.exe" 2^>nul') do if not defined DOSBOX set "DOSBOX=%%I"
if not defined DOSBOX if exist "%ProgramFiles%\DOSBox-X\dosbox-x.exe" set "DOSBOX=%ProgramFiles%\DOSBox-X\dosbox-x.exe"
if not defined DOSBOX if exist "%ProgramFiles(x86)%\DOSBox-X\dosbox-x.exe" set "DOSBOX=%ProgramFiles(x86)%\DOSBox-X\dosbox-x.exe"
if not defined DOSBOX for /f "delims=" %%I in ('where dosbox-x.exe 2^>nul') do if not defined DOSBOX set "DOSBOX=%%I"
if not defined DOSBOX (
  echo No se encontro dosbox-x.exe automaticamente.
  echo Arrastre el archivo dosbox-x.exe a esta ventana y presione Enter.
  set /p "DOSBOX=Ruta: "
  set "DOSBOX=!DOSBOX:"=!"
)
if not exist "!DOSBOX!" (
  echo ERROR: no existe "!DOSBOX!"
  pause
  exit /b 1
)
> "%DIR%\DOSBOX_RUTA.txt" echo !DOSBOX!
echo  DOSBox-X: !DOSBOX!

rem ---------------- PREPARAR CARPETA DE TRABAJO ----------------
if exist "%DIR%\trabajo" rd /s /q "%DIR%\trabajo"
md "%DIR%\trabajo"
copy /y "%DIR%\T8S.EXE" "%DIR%\trabajo\" >nul
> "%DIR%\trabajo\LOTE.BAT" echo @echo off

set /a TOTAL=0
for %%F in ("%DIR%\redes\*.%EXT%") do (
  if /i "%%~xF"==".%EXT%" (
    set /a TOTAL+=1
    set "NN=000!TOTAL!"
    set "NN=!NN:~-3!"
    set "NOM_!NN!=%%~nF"
    copy /y "%%~fF" "%DIR%\trabajo\N!NN!.PRN" >nul
    echo  N!NN!  =  %%~nxF
    call :escribir_lote !NN!
  )
)
if !TOTAL! EQU 0 (
  echo ERROR: no hay archivos *.%EXT% en la carpeta redes.
  pause
  exit /b 1
)
echo.
echo  Redes preparadas: !TOTAL!

rem ---------------- CORRER TODO EN UNA SESION DE DOSBOX-X ----------------
if "%PAUSA%"=="0" (set "SALIR=-c exit") else (set "SALIR=")
echo.
echo  Abriendo DOSBox-X. No toque el teclado dentro de la ventana mientras corre.
start "" /wait "%DOSBOX%" -nopromptfolder -defaultdir "%DIR%" -c "mount c %DIR%\trabajo" -c "c:" -c "call lote.bat" !SALIR!

rem ---------------- RECOGER RESULTADOS ----------------
set /a OKS=0
set /a FALLOS=0
for /l %%I in (1,1,!TOTAL!) do call :recoger %%I

set "HAYEXTRA=0"
for /f "delims=" %%G in ('dir /b /a-d "%DIR%\trabajo" 2^>nul') do call :extra "%%~G"

echo.
echo ============================================================
echo  Redes: !TOTAL!   Con resultado: !OKS!   Sin resultado: !FALLOS!
echo ============================================================
echo  Contenido de la carpeta resultados:
dir /b "%DIR%\resultados" 2>nul
if !FALLOS! EQU 0 if "!HAYEXTRA!"=="0" (
  if exist "%DIR%\trabajo" rd /s /q "%DIR%\trabajo"
)
if !FALLOS! GTR 0 (
  echo.
  echo  Hay redes sin resultado. La carpeta trabajo conserva lo que T8S dejo.
  echo  Revise la pantalla de DOSBox-X si PAUSA=1. Si T8S quedo esperando nombres,
  echo  suba ESPERA a 4 o PACE a 0.3 y reintente.
)
echo.
pause
endlocal
exit /b 0

rem ------------------------------------------------------------
rem  Agrega al lote DOS las lineas de la red numero %1
rem ------------------------------------------------------------
:escribir_lote
set "K=%~1"
set "KD=!K:~0,1! !K:~1,1! !K:~2,1!"
>> "%DIR%\trabajo\LOTE.BAT" echo echo ===== N!K! =====
>> "%DIR%\trabajo\LOTE.BAT" echo autotype -w %ESPERA% -p %PACE% n !KD! period p r n enter s !KD! period t x t enter %EXTRA%
>> "%DIR%\trabajo\LOTE.BAT" echo t8s
exit /b 0

rem ------------------------------------------------------------
rem  Mueve S###.TXT a resultados\resultados - NOMBRE_RED.txt
rem ------------------------------------------------------------
:recoger
set "NN=000%~1"
set "NN=!NN:~-3!"
call set "RED=%%NOM_!NN!%%"
if exist "%DIR%\trabajo\S!NN!.TXT" (
  move /y "%DIR%\trabajo\S!NN!.TXT" "%DIR%\resultados\resultados - !RED!.txt" >nul
  echo  OK: resultados - !RED!.txt
  set /a OKS+=1
) else (
  echo  SIN RESULTADO: !RED!
  set /a FALLOS+=1
)
exit /b 0

rem  Avisa de archivos que T8S haya creado y no sean parte de las corridas
:extra
if /i "%~1"=="T8S.EXE" exit /b 0
if /i "%~1"=="LOTE.BAT" exit /b 0
set "X=%~1"
if /i "!X:~0,1!"=="N" if /i "%~x1"==".PRN" exit /b 0
echo  Archivo adicional en trabajo: %~1
set "HAYEXTRA=1"
exit /b 0
