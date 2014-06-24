@echo off

::Clean
rm -rf build
rm -rf clay
rm -rf posts
rm -rf index.html

:: For unicode support
chcp 65001

::cabal install --only-dependencies
::cabal configure
::cabal buil

ghc --make src/hs/site.hs -o src/site.exe

::Dart
cp -rf build/web web/

::Build
pushd .
cd .\src
set ABS_PATH=%CD%

"%CD%/site.exe" clean
"%CD%/site.exe" build

::Hakyll
cp -rf %CD%/_site/* %CD%/../

rm -rf %CD%/_cache
rm -rf %CD%/_site

popd

pause