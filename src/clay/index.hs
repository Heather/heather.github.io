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
                         "#canvas" ? do zIndex 99
                                        top $ px $ -128
                                        left $ px $ -128
                                        position relative

    div # "#top" ? do position relative
                      top $ px $ -550
                      zIndex 100

    div # ".mlr" ? do minHeight $ px 300

    div # ".mleft"  ? do float      floatLeft
                         minWidth   $ px 150
    div # ".mright" ? do float floatRight
                         top $ px $ -100
                         position relative

    div # "#contacts" ? do fontSize   $ px 15
                           textAlign  $ alignSide sideLeft
                           
    div # "#social" ? do position relative
                         top $ px $ -515
                         zIndex 100

