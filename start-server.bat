@echo off
setlocal
cd /d "%~dp0"

echo.
echo [1/2] docker compose -f docker-compose-env.yaml up -d
docker compose -f docker-compose-env.yaml up -d
if %ERRORLEVEL% neq 0 (
  echo [ERROR] docker-compose-env.yaml failed
  pause
  exit /b %ERRORLEVEL%
)

echo.
echo [2/2] docker compose up -d
docker compose up -d
if %ERRORLEVEL% neq 0 (
  echo [ERROR] docker-compose.yaml failed
  pause
  exit /b %ERRORLEVEL%
)

echo.
echo [OK] Server started
exit /b 0
