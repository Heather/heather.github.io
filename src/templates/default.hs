{-# LANGUAGE
    OverloadedStrings
  , UnicodeSyntax
  #-}

{-# OPTIONS_GHC -fno-warn-type-defaults #-}

module Main where

import           Lucid
import           Lucid.Base (makeAttribute)

import           Data.Text (Text)
import qualified Data.Text.Lazy as L

page :: Html ()
page = do
  raw "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  raw "<!DOCTYPE html>"
  html_ [ngapp_] $ do
    head_ $ do
      meta_ [charset_ "utf-8"]
      meta_ [httpEquiv_ "X-UA-Compatible", content_ "IE=edge,chrome=1"]
      meta_ [name_ "description", content_ "Heather"]
      meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1.0"]

      link_ [href_ "/atom.xml", rel_ "alternate", title_ "Heather", type_ "application/atom+xml"]
      link_ [rel_ "shortcut icon", type_ "image/ico", href_ "/favicon.ico"]

      script "/bootstrap/jquery-2.1.1.min.js"
      link_ [rel_ "stylesheet", href_ "/bootstrap/bootstrap.min.css"]
      link_ [rel_ "stylesheet", href_ "/bootstrap/bootstrap-theme.min.css"]
      script "/bootstrap/bootstrap.min.js"
      script "/bootstrap/angular.min.js"

      link_ [rel_ "stylesheet", type_ "text/css", media_ "all", href_ "/css/hasklig.css" ]
      link_ [rel_ "stylesheet", type_ "text/css", media_ "all", href_ "/css/octicons.css"]
      link_ [rel_ "stylesheet", type_ "text/css", media_ "all", href_ "/css/syntax.css"  ]
      link_ [rel_ "stylesheet", type_ "text/css", media_ "all", href_ "/css/default.css" ]

      raw "<title>Heather - $title$</title>"

      script "/js/auto.js"

    body_ $ do
      div_ [class_ "band"] ""
      div_ [id_ "header"] $
        div_ [id_ "logo"] $ do
          a_ [id_ "abbr", href_ "/"] ""
          script_ "e = document.getElementById(\"abbr\");setTimeout(r, 0);"
      div_ [id_ "content"] $ raw "$body$"
      div_ [id_ "social"] $
        ul_ $ do
          li_ $
            a_ [href_ "http://github.com/Heather", title_ "Github", target_ "_blank"] $
              span_ [class_ "mega-octicon octicon-octoface"] ""
          li_ $
            a_ [href_ "http://twitter.com/Cynede", title_ "Twitter", target_ "_blank"] $
              span_ [class_ "mega-octicon octicon-star"] ""
          li_ $
            a_ [href_ "mailto:heather@live.ru", title_ "mail", target_ "_blank"] $
              span_ [class_ "mega-octicon octicon-mail-read"] ""
          li_ $
            a_ [href_ "http://www.last.fm/user/Cynede", title_ "Last.fm", target_ "_blank"] $
              span_ [class_ "mega-octicon octicon-broadcast"] ""
          li_ $
            a_ [href_ "http://stackoverflow.com/users/238232/heather", title_ "Stackoverflow", target_ "_blank"] $
              span_ [class_ "mega-octicon octicon-squirrel"] ""
          li_ $
            a_ [href_ "/atom.xml", title_ "RSS", target_ "_blank"] $
              span_ [class_ "mega-octicon octicon-rss"] ""
      div_ [id_ "footer"] ""
 where
  -- | The @ng-app@ attribute.
  ngapp_ :: Attribute
  ngapp_ = makeAttribute "ng-app" ""

  raw :: Monad m => Text → HtmlT m ()
  raw = toHtmlRaw

  script :: Monad m => Text → HtmlT m ()
  script s = script_ [src_ s] empt
   where empt :: Text
         empt = ""

main :: IO ()
main = putStr $ L.unpack (renderText page)
