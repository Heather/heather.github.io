---
title: Hakyll and Clay
twittertext: Hakyll and Clay
---

Try it

``` haskell
theStylesheet = do -- Overall site-wide styling rules.

    body ? do color         "#333"
              margin        0 auto 0 auto
              width         $   pct 80
              fontSize      $   px 16
              fontFamily    ["Helvetica Neue Light", "Helvetica Neue", "Helvetica"] [sansSerif]
              fontWeight    $   weight 300
              lineHeight    $   em 1.5

    div # "#header" ? do marginBottom    $  px 44
                         marginTop       $  px 44
                         height          $  px 45
                         "#navigation"   ?
                            do height (px 45)
                               a ? do color         $ black
                                      fontSize      $ px 18
                                      fontWeight    $ bold
                                      marginLeft    $ px 12
                                      textDecoration none
                                      textTransform  uppercase
```
