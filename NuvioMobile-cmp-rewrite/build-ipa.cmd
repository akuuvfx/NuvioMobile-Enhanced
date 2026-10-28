@echo off
setlocal EnableExtensions
chcp 65001 >nul

REM ============================================================
REM  Build Nuvio Enhanced -> IPA (via GitHub Actions)
REM  Prerequis : Git + GitHub CLI (https://cli.github.com)
REM  Usage     : double-clic, ou   build-ipa.cmd [Release|Debug]
REM ============================================================

set "REPO_NAME=NuvioMobile-Enhanced"
set "VISIBILITY=public"
set "CONFIGURATION=%~1"
if "%CONFIGURATION%"=="" set "CONFIGURATION=Release"

cd /d "%~dp0"

where git >nul 2>nul || (echo [ERREUR] Git n'est pas installe. https://git-scm.com & goto :fail)
where gh  >nul 2>nul || (echo [ERREUR] GitHub CLI n'est pas installe. https://cli.github.com & goto :fail)

echo.
echo === 1/6  Connexion GitHub ===
gh auth status >nul 2>nul || gh auth login
REM Le scope "workflow" est requis pour pousser .github/workflows
gh auth refresh -h github.com -s workflow
if errorlevel 1 goto :fail

echo.
echo === 2/6  Depot Git local ===
if not exist ".git" (
    git init -b main || goto :fail
)
git config core.autocrlf input
git add -A || goto :fail
git update-index --chmod=+x gradlew
git update-index --chmod=+x scripts/build-ios-ipa.sh scripts/prepare-ios-dependencies.sh
git diff --cached --quiet
if errorlevel 1 (
    git commit -m "Nuvio Enhanced: PiP toggle, Netflix/Crunchyroll styles, IPA workflow" || goto :fail
)

echo.
echo === 3/6  Depot GitHub ===
git remote get-url origin >nul 2>nul
if errorlevel 1 (
    gh repo create "%REPO_NAME%" --%VISIBILITY% --source=. --remote=origin --push || goto :fail
) else (
    git push -u origin HEAD || goto :fail
)

echo.
echo === 4/6  Lancement du build (%CONFIGURATION%) ===
gh workflow run build-ipa.yml -f configuration=%CONFIGURATION% || goto :fail
timeout /t 10 /nobreak >nul

set "RUNID="
for /f "delims=" %%i in ('gh run list --workflow=build-ipa.yml --limit 1 --json databaseId --jq ".[0].databaseId"') do set "RUNID=%%i"
if "%RUNID%"=="" (
    echo [ERREUR] Impossible de retrouver le build lance.
    goto :fail
)
echo Build #%RUNID% en cours (compter 30 a 60 min)...

echo.
echo === 5/6  Attente de la fin du build ===
gh run watch %RUNID% --exit-status
if errorlevel 1 (
    echo.
    echo [ERREUR] Le build a echoue. Logs :  gh run view %RUNID% --log-failed
    goto :fail
)

echo.
echo === 6/6  Telechargement de l'IPA ===
if exist ipa rmdir /s /q ipa
gh run download %RUNID% -n nuvio-ipa -D ipa || goto :fail

echo.
echo ===== TERMINE =====
echo L'IPA (non signee) est dans : %~dp0ipa
echo Installe-la avec AltStore, SideStore ou Sideloadly.
explorer "%~dp0ipa"
pause
exit /b 0

:fail
echo.
echo Le script s'est arrete sur une erreur.
pause
exit /b 1
