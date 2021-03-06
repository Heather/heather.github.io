{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE UnicodeSyntax     #-}

import           Control.Applicative        ((<$>))
import           Control.Monad              (liftM)

import qualified Data.ByteString.Lazy.Char8 as LB
import           Data.Monoid                (mappend)
import qualified Data.Text                  as T
import qualified Data.Text.Encoding         as E

import           System.FilePath
import           System.Process             (system)

import           Hakyll

import           Text.Jasmine

main ∷ IO ()
main = hakyll $ do

    match "images/*.tex" $ do
        route   $ setExtension "png"
        compile $ getResourceBody
            >>= loadAndApplyTemplate "templates/formula.tex" defaultContext
            >>= pdflatex >>= pdfToPng

    match "templates/*.hs" $ do
        route $ customRoute $ toSrc . toFilePath
        compile runGHC

    match "css/*.hs" $ do
        route $ setExtension "css"
        compile $ fmap compressCss <$> runGHC
    match "css/*.styl" $ do
        route $ setExtension "css"
        compile runStylus
    match "css/*.css" $ do
        route idRoute
        compile compressCssCompiler

    match "js/*.sjs" $ do
        route $ setExtension "js"
        compile runSweet
    match "js/*.js" $ do
        route idRoute
        compile compressJsCompiler

    match "posts/*.md" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["index.html"] $ do
        route idRoute
        compile $ do
            posts ← recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home" `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/index.html" indexCtx
                >>= loadAndApplyTemplate "templates/default.html" homeCtx
                >>= relativizeUrls

    create ["404.html"] $ do
        route idRoute
        compile $
            makeItem ""
                >>= loadAndApplyTemplate "templates/404.html" homeCtx
                >>= loadAndApplyTemplate "templates/top.html" homeCtx
                >>= relativizeUrls

    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx `mappend`
                    constField "description" "Heather"

            posts ← fmap (take 10) . recentFirst =<< loadAll "posts/*"
            renderAtom feedConfiguration feedCtx posts

    match "templates/*" $ compile templateCompiler

  where
    changeExtension ∷ FilePath → String → FilePath
    changeExtension path = addExtension (dropExtension path)

    toSrc ∷ String → String
    toSrc p = "src" </> changeExtension p ".html"

    runGHC ∷ Compiler (Item String)
    runGHC = getResourceString >>= withItemBody (unixFilter "runghc" [])

    runStylus ∷ Compiler (Item String)
    runStylus = liftM (fmap compressCss)
      (getResourceString >>=
       withItemBody (unixFilter "stylus" ["-s", "--scss"]))

    runSweet ∷ Compiler (Item String)
    runSweet = liftM (fmap compressCss)
      (getResourceString >>=
       withItemBody (unixFilter "stylus" ["-s", "--scss"]))

    compressJsCompiler ∷ Compiler (Item String)
    compressJsCompiler = fmap jasmin <$> getResourceString

    jasmin ∷ String → String
    jasmin src = LB.unpack $ minify
                           $ LB.fromChunks [E.encodeUtf8 $ T.pack src]


homeCtx ∷ Context String
homeCtx =
    constField "title" "Home" `mappend`
    postCtx

postCtx ∷ Context String
postCtx =
    dateField "date" "%e %B %Y" `mappend`
    defaultContext

feedConfiguration ∷ FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "Cynede"
    , feedDescription = "blog"
    , feedAuthorName  = "Cynede"
    , feedAuthorEmail = "cynede@gentoo.org"
    , feedRoot        = "https://dev.gentoo.org/~cynede/blog"
    }

pdflatex ∷ Item String → Compiler (Item TmpFile)
pdflatex item = do
    TmpFile texPath ← newTmpFile "pdflatex.tex"
    let tmpDir  = takeDirectory texPath
        pdfPath = replaceExtension texPath "pdf"

    unsafeCompiler $ do
        writeFile texPath $ itemBody item
        _ ← system $ unwords [ "pdflatex"
                             , "-halt-on-error"
                             , "-output-directory"
                             , tmpDir
                             , texPath
                             , ">/dev/null"
                             , "2>&1"
                             ]
        return ()
    makeItem $ TmpFile pdfPath

pdfToPng ∷ Item TmpFile → Compiler (Item TmpFile)
pdfToPng item = do
    let TmpFile pdfPath = itemBody item
        pngPath         = replaceExtension pdfPath "png"
    unsafeCompiler $ do
        _ ← system $ unwords [ "convert"
                             , "-density"
                             , "150"
                             , "-quality"
                             , "90"
                             , pdfPath
                             , pngPath
                             ]
        return ()
    makeItem $ TmpFile pngPath
