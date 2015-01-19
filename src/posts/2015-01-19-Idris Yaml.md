---
title: Idris YAML (Usage)
---

[Idris.YAML](https://github.com/Heather/Idris.Yaml)
---------------------------------------------------

Simple Idris Parser done with

 - [lightyear](https://github.com/ziman/lightyear) parser combinator library
 - Idris [Effects](http://www.idris-lang.org/documentation/effects/)

``` haskell
||| A parser that skips whitespace without jumping over lines
yamlSpace : Monad m => ParserT m String ()
yamlSpace = skip (many $ satisfy (\c => c /= '\n' && isSpace c)) <?> "yamlSpace"

mutual
    yamlArray : Parser (List YamlValue)
    yamlArray = char '-' $!> (yamlArrayValue `sepBy` (char '-'))

    keyValuePair : Parser (String, YamlValue)
    keyValuePair = do key <- map pack (many (satisfy $ not . isSpace)) <$ space
                      val <- char ':' $> yamlValue
                      pure (key, val)

    yamlObject : Parser (SortedMap String YamlValue)
    yamlObject = map fromList $ keyValuePair `sepBy` (char '\n')

    -- TODO check id indent is bigger than in array start
    yamlObjectA : Parser (SortedMap String YamlValue)
    yamlObjectA = map fromList $ keyValuePair `sepBy` (char '\n')

    yamlValue' : Parser YamlValue
    yamlValue' =  (map YamlString yamlString)
            <|> (map YamlNumber yamlNumber)
            <|> (map YamlBool   yamlBool)
            <|> (pure YamlNull <$ yamlNull)
            <|>| map YamlArray  yamlArray
            <|>| map YamlObject yamlObject
```

Usage
=====

Here is simple example of code that reads and parse YML files

``` haskell
module Main

import Yaml

import public Effects
import public Effect.StdIO
import public Effect.File

FileIO : Type -> Type -> Type
FileIO st t = { [FILE_IO st, STDIO] } Eff t 

readFile : FileIO (OpenFile Read) (List String)
readFile = readAcc [] where
  readAcc : List String -> FileIO (OpenFile Read) (List String)
  readAcc acc = if (not !eof) then readAcc $ !readLine :: acc
                              else return  $ reverse acc

procs : (List String) -> { [STDIO] } Eff ()
procs file = case parse yamlToplevelValue config of
                      Left err => putStrLn $ "error: " ++ err
                      Right v  => putStrLn $ show v
  where config = concat file

test : String -> FileIO () ()
test f = case !(open f Read) of
                True => do procs !readFile
                           close {- =<< -}
                False => putStrLn "Error!"

main : IO ()
main = do
  run $ test "test1.yml"
  run $ test "test2.yml"
```

Script to run:

``` shell
idris Test.idr -p lightyear -p yaml -p effects -o test
./test
```
