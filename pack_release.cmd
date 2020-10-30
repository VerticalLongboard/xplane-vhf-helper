for /F "tokens=*" %%h in ('git tag --points-at HEAD') do (SET TAG=%%h)
if not defined TAG (set tag=TAGLESS)

for /F "tokens=*" %%h in ('git rev-parse --short HEAD') do (SET COMMIT_HASH=%%h)

rmdir /S /Q RELEASE_PACKAGE

mkdir RELEASE_PACKAGE
mkdir RELEASE_PACKAGE\Modules
mkdir RELEASE_PACKAGE\Scripts

copy /a scripts\*.* RELEASE_PACKAGE\Scripts
copy /a modules\*.* RELEASE_PACKAGE\Modules

cd RELEASE_PACKAGE

7z.exe a -r %1-%TAG%-%COMMIT_HASH%.zip Modules Scripts
