{-# LANGUAGE OverloadedStrings #-}

{-# OPTIONS_GHC -fno-warn-type-defaults #-}

module Main where

import           Control.Monad

import           Lucid
import           Lucid.Base
import           Lucid.Html5

import           Data.Text (Text)
import qualified Data.Text.Lazy as L

page :: Html ()
page = do
  link_ [rel_ "stylesheet", type_ "text/css", href_ "css/index.css"]
  div_ [id_ "fof"]
   $ do div_ $ img_ [style_ "position: absolute;", src_ "/images/eyes.png"]
        canvas_ [id_ "canvas"] ""
  div_ [id_ "parent"]
    $ div_ [id_ "top"]
      $ div_ [class_ "mlr"]
       $ do div_ [class_ "mleft"]
              $ ul_ [class_ "recent-posts"]
                $ raw "$partial(\"templates/post-list.html\")$"
            div_ [class_ "mright"] $ img_ [id_ "img", src_ "/images/Hlogo.png"]
  div_ [id_ "main"] "" --fullscreen?
  script "js/eyes.js"
  script "js/youtube.js"
 where
  raw :: Monad m => Text -> HtmlT m ()
  raw = toHtmlRaw

  script :: Monad m => Text -> HtmlT m ()
  script s = script_ [src_ s] empt
   where empt :: Text
         empt = ""

main :: IO ()
main = putStr $ L.unpack (renderText page)
