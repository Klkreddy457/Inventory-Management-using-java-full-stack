@echo off
title InventoryPro - Startup

echo ================================================
echo     InventoryPro - Spring Boot Application
echo ================================================
echo.

:: Set Java and Maven paths
set "JAVA_HOME=%USERPROFILE%\jdk17\jdk-17.0.14+7"
set "MVN_HOME=%USERPROFILE%\maven\apache-maven-3.9.6"
set "PATH=%JAVA_HOME%\bin;%MVN_HOME%\bin;%PATH%"

echo [1/4] Java and Maven configured.
java -version
echo.

:: Get MySQL password
set /p MYSQL_PASS=Enter your MySQL root password (press Enter if blank): 

:: Start MySQL if not running
echo [2/4] Starting MySQL...
net start MYSQL80 2>nul
if errorlevel 1 echo MySQL already running or could not start.
timeout /t 2 /nobreak >nul

:: Create database
echo Creating database if not exists...
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p%MYSQL_PASS% -e "CREATE DATABASE IF NOT EXISTS inventory_db;" 2>&1
if errorlevel 1 (
  echo.
  echo [ERROR] Could not connect to MySQL.
  echo Please check your password and make sure MySQL is running.
  echo.
  echo Edit application.properties to change the password:
  echo   src\main\resources\application.properties
  pause
  exit /b 1
)

echo Database ready!
echo.

:: Launch browser automatically once Spring Boot is ready
echo [3/4] Waiting for server to start, then opening browser...
start /b cmd /c ^
  "for /L %%i in (1,1,30) do (timeout /t 2 /nobreak >nul && curl -s -o nul -w \"%%{http_code}\" http://localhost:8080/index.html | findstr /c:\"200\" >nul && start http://localhost:8080/index.html && exit)"
echo.

:: Run Spring Boot
echo [4/4] Starting Spring Boot application...
echo.
echo Browser will open automatically when the server is ready.
echo Press Ctrl+C to stop the server.
echo.

mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dspring.datasource.password=%MYSQL_PASS%"

pause
