{-# LANGUAGE OverloadedStrings #-}

{-# OPTIONS_GHC -fno-warn-type-defaults #-}

module Main where

import Lucid

import qualified Data.Text.Lazy as L

page :: Html ()
page =
  ul_ $ do
    "$for(posts)$"
    li_ $ do
      a_ [href_ "$url$"] "$title$"
      " "
      span_ " - $date$"
    "$endfor$"

main :: IO ()
main = putStr $ L.unpack (renderText page)
