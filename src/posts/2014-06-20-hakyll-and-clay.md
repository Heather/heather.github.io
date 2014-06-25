---
title: Hakyll and Clay
twittertext: Hakyll and Clay
---

That's how Hakyll looks like...

``` haskell
match "posts/*" $ do
    route $ setExtension "html"
    compile $ pandocCompiler
        >>= loadAndApplyTemplate "templates/post.html"    postCtx
        >>= loadAndApplyTemplate "templates/default.html" postCtx
        >>= relativizeUrls

create ["index.html"] $ do
    route idRoute
    compile $ do
        posts <- recentFirst =<< loadAll "posts/*"
        let indexCtx =
                listField "posts" postCtx (return posts) `mappend`
                constField "title" "Home" `mappend`
                defaultContext

        makeItem ""
            >>= loadAndApplyTemplate "templates/index.html" indexCtx
            >>= loadAndApplyTemplate "templates/default.html" homeCtx
            >>= relativizeUrls
```

That's how Clay CSS looks like...

``` haskell
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
