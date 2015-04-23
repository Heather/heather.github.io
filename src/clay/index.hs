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
                   top  $ px 5
                   left $ nil

    div # "#top" ? zIndex 100

    div # ".mlr" ? do minHeight $ px 300

    div # ".mleft"  ? do float      floatLeft
                         minWidth   $ px 300
                         backgroundColor $ rgba 200 200 200 100
                         borderRadius (px 5) (px 15) (px 5) (px 15)
                         outline dotted (px 6) $ rgba 50 50 50 100
                         outlineOffset $ px 3

    div # ".mright" ? do float floatRight
                         top $ px $ -100
                         position relative

    div # "#social" ? do zIndex 100
                         position absolute
                         bottom $ px 10
                         height $ px 100
                         backgroundColor $ rgba 150 170 165 210
                         backgroundImage $ url "../images/blood.png"
                         borderRadius (px 30) (px 150) (px 30) (px 150)
                         li ? do marginTop $ px 15
