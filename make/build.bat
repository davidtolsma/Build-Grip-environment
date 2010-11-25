@echo off


  set clean=%1

  if "%clean%"=="CLEAN" GOTO :CLEAN

:: Sets where this program is located at
  set thisScriptLocation=%~dp0

:: Paths to directories relative to this script
  set source=..\source\
:: The Individual applications variables
  set common=..\common\
:: The Binary directory Name
  set compiled=compiled

:: build variables
  set buildFileName=build.txt
 
:: Check environment
  set UGII_ROOT_DIR=%UGII_BASE_DIR%\ugii\



:: Red
  set backgroundColor=4
:: white
  set foregroundColor=7

:: Set the background and foreground color to show that it is working
  color %backgroundColor%%foregroundColor%


:: Get all the directories in the source folder
  for /D %%d in (%source%*) DO CALL :BUILD %%d

:: Sets the background and foreground color back to standard
  color 07


GOTO :QUIT

~~~~~~~~~~~~~~~~~~~~~~~~~~~

:BUILD
  set builddirectory=%*

  :: looking for the build dependency files
  IF exist %builddirectory%\%buildFileName% (CALL :COMPILE_AND_LINK %builddirectory% )
  

  GOTO :EOF



:COMPILE_AND_LINK
  set buildFile=%*

  for /F %%f in (%buildFile%\%buildFileName%) DO CALL :COMPILING %%f

  :: The last one wins in the build.txt file, which is the application name
  CALL :LINK %applicationName%


  :: Move the binary to the compiled directory
  CALL :MOVE_EXECUTABLE %applicationName%

  GOTO :EOF



:COMPILING
  set compilingFile=%*

  :: The last one will be the application name, used in the compile function
  set applicationName=%compilingFile%

  :: Search for files in the common files and copy to this application location first
  if exist ..\source\common\%compilingFile%.grs copy ..\source\common\%compilingFile%.grs %builddirectory%\%compilingFile%.grs
  
  :: Change directory since grip compile can't accept a path
  cd %builddirectory%

  :: Compiling the dependencies

  call %UGII_ROOT_DIR%gripbatch.bat -c %compilingFile%.grs 

  :: If it is not compiled loop until it is complete
  CALL :WAIT %compilingFile%.gri

  
  :: Remove the GRS file only if it is common so not to have duplicate files laying around
  if exist ..\common\%compilingFile%.grs del %compilingFile%.grs
  
  :: change back the original directory where it started
  cd %thisScriptLocation%


  GOTO :EOF



:LINK
  set linking=%*

  :: Change directory since grip compile can't accept a path
  cd %builddirectory%

  call %UGII_ROOT_DIR%\gripbatch.bat -l %applicationName%

  :: change back the original directory where it started
  cd %thisScriptLocation%

  GOTO :EOF



:MOVE_EXECUTABLE
  set binary=%*

  :: Change directory since grip compile can't accept a path
  cd %builddirectory%

  :: If it is not linked yet loop until it is complete
  CALL :WAIT %binary%.grx
  
  move %binary%.grx ..\..\%compiled%\%binary%.grx

  :: change back the original directory where it started
  cd %thisScriptLocation%

  GOTO :EOF



:CLEAN
  
  :: Change directory since grip compile can't accept a path
  cd ..\

  :: Recursively delete all the *.gri files
  del *.gri /S

  :: change back the original directory where it started
  cd %thisScriptLocation%

  GOTO :QUIT


:WAIT
  set waitingFor=%*

  :: Endless loop until the files are compiled
  if not exist %waitingFor% CALL :WAIT %waitingFor%

  GOTO :EOF


:QUIT

  