heather.github.io
=================

``` haskell
main :: IO ()
main =
  do args <- getArgs
     case args of
       "compact" : _
          -> TXT.putStr (renderWith compact [] theStylesheet)
       _ -> putCss theStylesheet

theStylesheet :: Css
theStylesheet =
  do -- Overall site-wide styling rules.
    body ? do color "#333"
              margin 0 auto 0 auto
              width $ px 600
              fontSize $ px 15
              fontFamily ["Helvetica Neue Light", "Helvetica Neue", "Helvetica"] [sansSerif]
              fontWeight $ weight 300
              lineHeight $ em 1.5

    div # "#header" ? do marginBottom $ px 44
                         marginTop $ px 44
                         height $ px 45
                         "#navigation" ?
                            do height (px 45)
                               a ? do color $ black
                                      fontSize $ px 18
                                      fontWeight $ bold
                                      marginLeft $ px 12
                                      textDecoration none
                                      textTransform uppercase
    div # "#footer" ? do color "#555"
                         fontSize $ px 12
                         marginTop $ px 30
                         padding 12 0 12 0
                         textAlign $ alignSide sideRight
```
