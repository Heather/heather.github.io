/bin/bash

#Clean
rm -rf css
rm -rf posts
rm -rf index.html

#For unicode support
export LANG=en_US.UTF-8

#cabal install --only-dependencies
#cabal configure
#cabal buil

ghc --make src/hs/site.hs -o src/site

:#Build
cd src

site clean
site build

cp -rf _site/* ..

rm -rf _cache
rm -rf _site

cd ..
