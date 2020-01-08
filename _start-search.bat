@echo off

if "x%BIN_DIR%x" == "xx" goto badEnvironment
if "x%INST_DIR%x" == "xx" goto badEnvironment
if "x%BITBUCKET_HOME%x" == "xx" goto badEnvironment

set "ES_CONFIG_PATH=%BITBUCKET_HOME%\shared\search"
set "ES_DATA_PATH=%BITBUCKET_HOME%\shared\search\data"
set "ES_DIR=%INST_DIR%\elasticsearch"
set "ES_LOG_PATH=%BITBUCKET_HOME%\log\search"
set "ES_PID=%ES_LOG_PATH%\elasticsearch.pid"
set "ES_JVM_OPTIONS=%BITBUCKET_HOME%\shared\search\jvm.options"

rem This version refers to <BITBUCKET_HOME>/shared/search/.version file
rem Bump this version if the elasticsearch config files should be updated
set "ES_CONFIG_CURRENT_VERSION=3"

rem If config files are not in their appropriate location, copy them over from the templates in our distribution
rem This copying over also happens in the installer script, modifications here should go to the installer as well
if exist %ES_CONFIG_PATH% goto createEsDirs
echo.
echo Copying Elasticsearch configuration to %ES_CONFIG_PATH%
md %ES_CONFIG_PATH%
robocopy %ES_DIR%\config-template\ %ES_CONFIG_PATH% /S /NFL /NDL /NJH /NJS /NC /NS /NP

:createEsDirs
if not exist %ES_LOG_PATH% md %ES_LOG_PATH%
if not exist %ES_DATA_PATH% md %ES_DATA_PATH%

set /p ES_CONFIG_PREVIOUS_VERSION=<"%ES_CONFIG_PATH%\.version"

if "%ES_CONFIG_PREVIOUS_VERSION%" ==  "%ES_CONFIG_CURRENT_VERSION%" goto run
if exist "%ES_CONFIG_PATH%\elasticsearch.yml" move "%ES_CONFIG_PATH%\elasticsearch.yml" "%ES_CONFIG_PATH%\elasticsearch.yml.bak"
if exist "%ES_CONFIG_PATH%\logging.yml" move "%ES_CONFIG_PATH%\logging.yml" "%ES_CONFIG_PATH%\logging.yml.bak"
copy "%ES_DIR%\config-template\elasticsearch.yml" "%ES_CONFIG_PATH%" >NUL
copy "%ES_DIR%\config-template\jvm.options" "%ES_CONFIG_PATH%" >NUL
copy "%ES_DIR%\config-template\log4j2.properties" "%ES_CONFIG_PATH%"> NUL
(echo %ES_CONFIG_CURRENT_VERSION%) > "%ES_CONFIG_PATH%\.version"

:run

echo.
echo Starting bundled Elasticsearch
echo     Hint: Run start-bitbucket.bat /no-search to skip starting Elasticsearch
echo.
echo Elasticsearch can be stopped by typing Ctrl+C in its console window.

rem Set the location of Elasticsearch config directory
set "ES_PATH_CONF=%ES_CONFIG_PATH%"
start "Elasticsearch" "%ES_DIR%\bin\elasticsearch.bat" -p=%ES_PID%
goto done

:badEnvironment
echo "_start-search.bat is not intended to be run directly. Run start-bitbucket.bat instead"
exit /b 1

:done
