heather.github.io
=================

 - run dart-build
 - run update
 - run commit

``` haskell
main = hakyll $ do
    match "clay/*.hs" $ do
        route   $ setExtension "css"
        compile $ getResourceString >>= withItemBody (unixFilter "runghc" [])

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
                
    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx `mappend` -- no idea
                    constField "description" "Heather"

            posts <- fmap (take 10) . recentFirst =<< loadAll "posts/*"
            renderAtom feedConfiguration feedCtx posts

    match "templates/*" $ compile templateCompiler

homeCtx :: Context String
homeCtx =
    constField "title" "Home" `mappend`
    postCtx

postCtx :: Context String
postCtx =
    dateField "date" "%e %B %Y" `mappend`
    defaultContext

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "Heather"
    , feedDescription = "blog"
    , feedAuthorName  = "Heather"
    , feedAuthorEmail = "heather@live.ru"
    , feedRoot        = "http://heather.github.io"
    }
```
