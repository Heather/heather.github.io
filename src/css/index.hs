{-# LANGUAGE OverloadedStrings #-}
module Main where

import System.Environment

import qualified Data.Text.Lazy.IO as TXT

import Data.Monoid -- <>

import Prelude hiding (div, span)
import Clay

main :: IO ()
main =
  do args <- getArgs
     case args of
       "compact" : _
          -> TXT.putStr (renderWith compact [] theStylesheet)
       _  -> putCss theStylesheet

theStylesheet :: Css
theStylesheet = do

    div # ".mlr" ? do minHeight $ px 200

    div # ".mleft"  ? do float      floatLeft
                         minWidth   $ px 200
    div # ".mright" ? do float floatRight

    div # "#contacts" ? do fontSize   $ px 15
                           textAlign  $ alignSide sideLeft

