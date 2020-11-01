@echo off
call .\build\configure_environment.cmd

for /F "tokens=*" %%h in ('git tag --points-at HEAD') do (SET TAG=%%h)
if not defined TAG (set tag=TAGLESS)

for /F "tokens=*" %%h in ('git rev-parse --short HEAD') do (SET COMMIT_HASH=%%h)

set RELEASE_PACKAGE_FOLDER_PATH=RELEASE_PACKAGE

if exist %RELEASE_PACKAGE_FOLDER_PATH% (
    rmdir /S /Q RELEASE_PACKAGE_FOLDER_PATH
)

mkdir %RELEASE_PACKAGE_FOLDER_PATH%
mkdir %RELEASE_PACKAGE_FOLDER_PATH%\Modules
mkdir %RELEASE_PACKAGE_FOLDER_PATH%\Scripts

copy /a scripts\*.* %RELEASE_PACKAGE_FOLDER_PATH%\Scripts
copy /a modules\*.* %RELEASE_PACKAGE_FOLDER_PATH%\Modules

cd %RELEASE_PACKAGE_FOLDER_PATH%

"%SEVEN_ZIP_EXECUTABLE_PATH%\7z.exe" a -r %1-%TAG%-%COMMIT_HASH%.zip Modules Scripts
