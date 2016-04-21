{-# LANGUAGE UnicodeSyntax #-}

-- work in progress

import Shake.It.Off

import System.Exit
import System.Process
import System.Directory

import Control.Monad

main :: IO ()
main = shake $ do
  "clean" ∫ do
    putStrLn "Cleaning..."
    removeFile index
    removeFile "404.html"
    removeDirectoryRecursive "css"
    removeDirectoryRecursive "posts"

  index ◉ ["clean"] ♯♯ do
    ghc ["--make", siteSrc, "-o", siteOut]

 where index :: String
       index = "index.html"

       siteSrc :: String
       siteSrc = "src/hs/site.hs"

       siteOut :: String
       siteOut  = "src/site.exe"
