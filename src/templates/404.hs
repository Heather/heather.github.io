{-# LANGUAGE
    OverloadedStrings
  #-}

{-# OPTIONS_GHC -fno-warn-type-defaults #-}

module Main where

import           Control.Monad

import           Lucid
import           Lucid.Base
import           Lucid.Bootstrap
import           Lucid.Html5

import           Data.Text (Text)
import qualified Data.Text.Lazy          as L

page :: Html ()
page = do
  link_ [rel_ "stylesheet", type_ "text/css", href_ "./css/index.css"]
  link_ [rel_ "stylesheet", type_ "text/css", href_ "./css/404.css"]
  canvas_ [id_ "canvas"] ""
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
  raw "<audio id=\"audio\" autoplay loop> <source src=\"images/Bween.mp3\" type=\"audio/mp3\" /> <p>Your browser sucks, after all... </p> </audio>"
  termRawWith "script" [src_ "./js/light.js"] ""
  termRawWith "script" [src_ "./js/404.js"] ""
 where
  data_target_ :: Text -> Attribute
  data_target_ = makeAttribute "data-target"

  data_toggle_ :: Text -> Attribute
  data_toggle_ = makeAttribute "data-toggle"

  data_dismiss_ :: Text -> Attribute
  data_dismiss_ = makeAttribute "data-dismiss"

  role_ :: Text -> Attribute
  role_ = makeAttribute "role"

  model_ :: Text -> Attribute
  model_ = makeAttribute "model"

  ng_model_ :: Text -> Attribute
  ng_model_ = makeAttribute "ng-model"

  raw :: Monad m => Text -> HtmlT m ()
  raw = toHtmlRaw

main :: IO ()
main = putStr $ L.unpack (renderText page)
