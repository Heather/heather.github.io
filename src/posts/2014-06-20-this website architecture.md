---
title: Blog architecture
---

It's just my Blog where I run all the possible experiments...

Core level has done with [Hakyll](http://jaspervdj.be/hakyll/)

Hakyll builds all the html pages, atom.xml and some other candies

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

My CSS made with [Clay](https://github.com/sebastiaanvisser/clay)

> Clay is a CSS preprocessor like LESS and Sass, 
> but implemented as an embedded domain specific language (EDSL) in Haskell. 
> 
> This means that all CSS selectors and style rules are first class Haskell functions, 
> which makes reuse and composability easy.

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

JS level has made with [Dart](https://www.dartlang.org/), [AngularDart](https://angulardart.org) and [Rikulo](http://rikulo.org/)

``` dart
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

import 'package:dquery/dquery.dart';
import 'package:bootjack/bootjack.dart';

void main() {
    Bootjack.useDefault();
    applicationFactory().run();
}
```