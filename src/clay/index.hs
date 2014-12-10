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

    div # "#parent" ? do position relative
                         zIndex 1000
    "#canvas" ? do zIndex 99
                   height $ pct 100
                   width  $ pct 100
                   position absolute
                   top  5
                   left 0

    div # "#top" ? zIndex 100

    div # ".mlr" ? do minHeight $ px 300

    div # ".mleft"  ? do float      floatLeft
                         minWidth   $ px 300
                         backgroundColor $ rgba 250 250 250 80
                         borderRadius (px 15) (px 15) (px 15) (px 15)

    div # ".mright" ? do float floatRight
                         top $ px $ -100
                         position relative

    div # "#social" ? do zIndex 100
                         position absolute
                         bottom $ px 15
                         width  $ pct 80
                         height $ px 100
                         backgroundColor $ rgba 200 200 200 200
                         borderRadius (px 30) (px 150) (px 30) (px 150)
