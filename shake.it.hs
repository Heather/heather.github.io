{-# LANGUAGE CPP           #-}
{-# LANGUAGE MultiWayIf    #-}
{-# LANGUAGE UnicodeSyntax #-}

import           Control.Monad
import           Shake.It.Off

main ∷ IO ()
main = shake $ do
  "clean" ∫ do
    putStrLn " -> Cleaning..."
    removeIfExists index
    removeIfExists "404.html"
    removeDirIfExists "css"
    removeDirIfExists "posts"
    removeDirIfExists "js"
    xcwd ← getCurrentDirectory
    let srcDir = xcwd </> "src"
        tempCache = srcDir </> "_cache"
        tempSite = srcDir </> "_site"
    removeDirIfExists tempCache
    removeDirIfExists tempSite

  index ◉ ["clean"] ♯♯ do
    putStrLn " -> Building..."
    ghc ["--make", siteSrc, "-o", siteOut]
    xcwd ← getCurrentDirectory
    putStrLn " -> Change current dir to src"
    let srcDir = xcwd </> "src"
        siteHK = if | os ∈ ["win32", "mingw32", "cygwin32"] → srcDir </> "src/site.exe"
                    | otherwise → srcDir </> "site"
        tempSite = srcDir </> "_site"
        tempCache = srcDir </> "_cache"
        site a = checkExitCode =<<
          if | os ∈ ["win32", "mingw32", "cygwin32"] → system ("chcp 65001 && " ++ siteHK ++ " " ++ a)
             | otherwise → system (siteHK ++ " " ++ a)
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

 where index ∷ String
       index = "index.html"

       siteSrc ∷ String
       siteSrc = "src/hs/site.hs"

       siteOut ∷ String
       siteOut =
         if | os ∈ ["win32", "mingw32", "cygwin32"] → "src/site.exe"
            | otherwise → "src/site"
