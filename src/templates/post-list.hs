{-# LANGUAGE OverloadedStrings #-}

{-# OPTIONS_GHC -fno-warn-type-defaults #-}

module Main where

import           Control.Monad

import           Lucid
import           Lucid.Base
import           Lucid.Html5

import qualified Data.Text.Lazy as L

page :: Html ()
page =
  ul_
   $ do "$for(posts)$"
        li_
         $ do a_ [href_ "$url$"]
                ("$title$")
              " - $date$"
        "$endfor$"

main :: IO ()
main = putStr $ L.unpack (renderText page)
