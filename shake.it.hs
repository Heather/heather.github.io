{-# LANGUAGE
    UnicodeSyntax
  , CPP
  #-}

-- TODO: Linux support

import Shake.It.Off

import System.Exit
import System.Process
import System.Directory

import Control.Monad

main :: IO ()
main = shake $ do
  "clean" ∫ do
    putStrLn " -> Cleaning..."
    removeIfExists index
    removeIfExists "404.html"
    removeDirIfExists "css"
    removeDirIfExists "posts"
    removeDirIfExists "js"
    cwd ← getCurrentDirectory
    let srcDir = cwd </> "src"
        tempCache = srcDir </> "_cache"
        tempSite = srcDir </> "_site"
    removeDirIfExists tempCache
    removeDirIfExists tempSite

  index ◉ ["clean"] ♯♯ do
    putStrLn " -> Building..."
    ghc ["--make", siteSrc, "-o", siteOut]
    cwd ← getCurrentDirectory
    putStrLn " -> Change current dir to src"
    let srcDir = cwd </> "src"
        siteHK = srcDir </> "site.exe"
        tempSite = srcDir </> "_site"
        tempCache = srcDir </> "_cache"
        site a =
          system ("chcp 65001 && " ++ siteHK ++ " " ++ a)
            >>= checkExitCode
    srcExists ← doesDirectoryExist srcDir
    when srcExists $ do
      setCurrentDirectory srcDir
      siteHKExists ← doesFileExist siteHK
      when siteHKExists $ do
        putStrLn " -> Running hakyll"
        site "clean"
        site "build"
        putStrLn " -> Copy _site back to rootDir"
        _tmpContent ← getDirectoryContents tempSite
        let _tmp = filter (`notElem` [".", "..", "src"]) _tmpContent
        forM_ _tmp $ \name →
          let srcPath = tempSite </> name
              dstPath = ".." </> name
          in doesDirectoryExist srcPath >>= \dirExist →
              if dirExist then copyDir srcPath dstPath
                          else copyFile srcPath dstPath
        putStrLn " -> Removing temp folders"
        removeDirIfExists tempCache
        removeDirIfExists tempSite

 where index :: String
       index = "index.html"

       siteSrc :: String
       siteSrc = "src/hs/site.hs"

       siteOut :: String
       siteOut  = "src/site.exe"
