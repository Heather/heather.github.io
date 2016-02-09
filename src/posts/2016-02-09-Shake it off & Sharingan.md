---
title: Small haskell utils
---

Work in progess
---------------

There are few utils I used to write and wanted to explain how do I use them and what was the reason of creating them.
This article is work in progress. First small util is actually poor shake clone, imperative and weak

Example
-------

`shake.it.hs` file (or `shake.it.lhs`)

``` haskell
import Shake.It.Off

main :: IO ()
main = shake $ do
  phony "clean" $ cabal ["clean"]

  obj "dist/build/Cr.exe" $ do
    cabal ["install", "--only-dependencies"]
    cabal ["configure"]
    cabal ["build"]
```

every time you run `shake` on this file if `shake.it.off` is outdated or not exists it will be rebuild (otherwise you will just run shake.it.off); when you will run `shake clean` it will process just `cabal clean`, if you will run it with no arguments then it will rebuild project, if you will run it with `shake clean install` it will process `shake clean` first then in case if there will be `shake install` phony it will process it, else way it will process default case (rebuilding) after cleaning. (because it's simple stupid imperative)

more complex example with Unicode operators:

``` haskell
{-# LANGUAGE UnicodeSyntax #-}

import Shake.It.Off

main :: IO ()
main = shake $ do
  -- phony clean @> is non-unicode operator alternative
  "clean" ∫ cabal ["clean"]

  -- building object rule #> is non-unicode operator alternative
  buildPath </> "shake.exe" ♯ do
    cabal ["install", "--only-dependencies"]
    cabal ["configure"]
    cabal ["build"]

  -- install phony depending on obj, @@> is non-unicode operator alternative
  -- ##> or ♯♯ is for dependent object rule, ◉ is just uncarry operator
  "install" ◉ [buildPath </> "shake.exe"] ∰
    cabal ["install"]

 where buildPath :: String
       buildPath = "dist/build/Shake"
```

 - `.dll` extensions treated as `.so` on linux and `.exe` extensions will be dropped there.
 - TODO: it honestly should be optional and no need for .NET

User story
----------

I like haskell and it will be cool to just use `haskell` to build some complex application and discovered `shake` but there was some strange things which was a bit complicated for me

``` haskell
"dist/build/Cr" <.> exe %> \out -> do traced "blabla" ..... >> return ()
Linking dist\build\Cr\Cr.exe ...
Error when running Shake build system:
* dist/build/Cr.exe
Error, rule "dist/build/Cr.exe" failed to build file:
  dist/build/Cr.exe
```

I was trying to understand realization and I've got some bits. It's impossible to have analitics without wrapping IO into Rules and Action and maybe custom functions for those wrappers. I was trying to get deeper and repeat something alike with `free` alike in this example https://github.com/ekmett/free/blob/master/examples/RetryTH.hs - and it's really not that simple to understand what's actually happening there. And there `withRetry` block is sure not IO () block, just yet another wrapper. Yes, wrapped Rules and Actions are easy to process but I don't want to learn that stuff so far, I don't want to lift from IO to Action and bind it to Rule everytime I want to make small change. This library/util is tiny but practical, it's doing very simple things and using imerative way including global mutable state to resolve things alike `phony` in dirty (but simple) way.
