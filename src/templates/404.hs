{-# LANGUAGE
    OverloadedStrings
  , UnicodeSyntax
  #-}

{-# OPTIONS_GHC -fno-warn-type-defaults #-}

module Main where

import           Lucid
import           Lucid.Base

import           Data.Text (Text)
import qualified Data.Text.Lazy          as L

page :: Html ()
page = do
  link_ [rel_ "stylesheet", type_ "text/css", href_ "./css/index.css"]
  link_ [rel_ "stylesheet", type_ "text/css", href_ "./css/404.css"]
  div_ [id_ "main"] "" --fullscreen?
  div_ [id_ "parent"]
    $ div_ [id_ "top"]
      $ div_ [class_ "mlr"]
       $ do div_ [class_ "mleft", style_ "margin-top: 50px;"]
              "404"
            div_ [class_ "mright", style_ "padding-top: 250px;"]
             $ do h3_ "Hello {{name}}!"
                  "Name:"
                  input_ [type_ "text", ng_model_ "name"]
                  br_ []
                  button_ [class_ "btn btn-primary", data_target_ "#modal", data_toggle_ "modal"] "Ping"
                  div_ [id_ "modal", class_ "modal fade", tabindex_ "-1", role_ "dialog"]
                   $ div_ [class_ "modal-dialog"]
                    $ div_ [class_ "modal-content"]
                     $ do div_ [class_ "modal-header"]
                            $ do button_ [type_ "button", class_ "close", data_dismiss_ "modal"]
                                  $ raw "&times"
                                 h3_ [style_ "margin: 0"] "Pong"
                          div_ [class_ "modal-body"]
                           $ ul_ [style_ "margin: 0"]
                                $ do li_ "Hakyll"
                                     li_ "Lucid"
                                     li_ "Clay"
                          div_ [class_ "modal-footer", style_ "margin: 0"]
                           $ button_ [class_ "btn btn-success", data_dismiss_ "modal"] "OK"
  script "./js/light.js"
  script "./js/404.js"
  script "./js/youtube404.js"
 where
  data_target_ :: Text → Attribute
  data_target_ = makeAttribute "data-target"

  data_toggle_ :: Text → Attribute
  data_toggle_ = makeAttribute "data-toggle"

  data_dismiss_ :: Text → Attribute
  data_dismiss_ = makeAttribute "data-dismiss"

  ng_model_ :: Text → Attribute
  ng_model_ = makeAttribute "ng-model"

  raw :: Monad m => Text → HtmlT m ()
  raw = toHtmlRaw

  script :: Monad m => Text → HtmlT m ()
  script s = script_ [src_ s] empt
   where empt :: Text
         empt = ""

main :: IO ()
main = putStr $ L.unpack (renderText page)
