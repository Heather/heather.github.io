{-# LANGUAGE
    OverloadedStrings
  , UnicodeSyntax
  #-}

{-# OPTIONS_GHC -fno-warn-type-defaults #-}

module Main where

import           Lucid

import           Data.Text (Text)
import qualified Data.Text.Lazy as L

page :: Html ()
page = do
  raw "<h1>$title$</h1>"

  audio_ [id_ "audio", autoplay_ "", loop_ ""] $
    source_ [src_ "../images/Bween.mp3", type_ "audio/mp3"]

  div_ [id_ "controls"] $
    img_ [id_ "playpause", height_ "20px", width_ "20px", src_ "../images/RedPause.png"]

  div_ [class_ "info"] $ raw "Posted on $date$"

  raw "$body$"

  div_ [id_ "postfooter"] ""

  script "/js/playpause.js"
  script "/bootstrap/three.js"
  script "/js/bubbles.js"
 where
  raw :: Monad m => Text → HtmlT m ()
  raw = toHtmlRaw

  script :: Monad m => Text → HtmlT m ()
  script s = script_ [src_ s] empt
   where empt :: Text
         empt = ""

main :: IO ()
main = putStr $ L.unpack (renderText page)
