#!/usr/bin/env bash

#clean
rm -rf clay
rm -rf css
rm -rf posts
rm -rf 404.html
rm -rf index.html

export LANG=en_US.UTF-8

#buld
ghc --make src/hs/site.hs -o src/site

#Dart
rm -rf web/*.js
rm -rf web/packages
cp -rf build/web/packages web/
cp -rf build/web/*.js web/

cd src

./site clean
./site build

#Hakyll
cp -rf _site/* ../

rm -rf _cache
rm -rf _site

cd ..
