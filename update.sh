#!/usr/bin/env bash

#clean
rm -rf build
rm -rf clay
rm -rf posts
rm -rf index.html

export LANG=en_US.UTF-8

#buld
ghc --make src/hs/site.hs -o src/site

#Dart
cp -rf build/web web/

cd src

./site clean
./site build

#Hakyll
cp -rf _site/* ../

rm -rf _cache
rm -rf _site

cd ..
