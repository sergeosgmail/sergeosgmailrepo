@echo off

if "x%BIN_DIR%x" == "xx" goto badEnvironment
if "x%INST_DIR%x" == "xx" goto badEnvironment
if "x%BITBUCKET_HOME%x" == "xx" goto badEnvironment

rem Occasionally Atlassian Support may recommend that you set some specific JVM arguments.  You can use this
rem variable to do that. Simply uncomment the below line and add any required arguments. Note however, if this
rem environment variable has been set in the environment of the user running this script, uncommenting the below
rem will override that.
rem
set JVM_SUPPORT_RECOMMENDED_ARGS="-Dplugin.ssh.port=5640"

rem The following 2 settings control the minimum and maximum memory allocated to the Java virtual machine.
rem For larger instances, the maximum amount will need to be increased.
rem
if not "x%JVM_MINIMUM_MEMORY%x" == "xx" goto afterJvmMinimumMemory
set JVM_MINIMUM_MEMORY=512m
:afterJvmMinimumMemory
if not "x%JVM_MAXIMUM_MEMORY%x" == "xx" goto afterJvmMaximumMemory
set JVM_MAXIMUM_MEMORY=1g
:afterJvmMaximumMemory

call %BIN_DIR%\set-jmx-opts.bat
if errorlevel 1 exit /b

set "JVM_LIBRARY_PATH=%INST_DIR%\lib\native;%BITBUCKET_HOME%\lib\native"

set "BITBUCKET_ARGS=-Datlassian.standalone=BITBUCKET -Dbitbucket.home=%BITBUCKET_HOME% -Dbitbucket.install=%INST_DIR%"
set "JVM_FILE_ENCODING_ARGS=-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"
set "JVM_JAVA_ARGS=-Djava.io.tmpdir=%BITBUCKET_HOME%\tmp -Djava.library.path=%JVM_LIBRARY_PATH%"
set "JVM_MEMORY_ARGS=-Xms%JVM_MINIMUM_MEMORY% -Xmx%JVM_MAXIMUM_MEMORY% -XX:+UseG1GC"
set "JVM_REQUIRED_ARGS=%JVM_MEMORY_ARGS% %JVM_FILE_ENCODING_ARGS% %JVM_JAVA_ARGS%"

set "JAVA_OPTS=-classpath %INST_DIR%\app %JAVA_OPTS% %BITBUCKET_ARGS% %JMX_OPTS% %JVM_REQUIRED_ARGS% %JVM_SUPPORT_RECOMMENDED_ARGS%"
set "LAUNCHER=com.atlassian.bitbucket.internal.launcher.BitbucketServerLauncher"

echo.
echo Starting Bitbucket webapp at http://localhost:7990
echo.
echo If you cannot access Bitbucket within 3 minutes, or encounter other issues, check the troubleshooting guide at:
echo https://confluence.atlassian.com/display/BitbucketServerKB/Troubleshooting+Installation
echo.
echo Bitbucket can be stopped by typing Ctrl+C in its console window.

start "Bitbucket Server" "%JRE_HOME%\bin\java" %JAVA_OPTS% %LAUNCHER% start --logging.console=true
goto done

:badEnvironment
echo "_start-webapp.bat is not intended to be run directly. Run start-bitbucket.bat instead"
echo "To start the Bitbucket webapp without starting search, run start-bitbucket.bat /no-search"
exit /b 1

:done