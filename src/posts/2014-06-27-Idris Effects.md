---
title: Idris Effects
---

For now this code works as package manager:

``` shell
>Synthia install Heather/Control.Eternal.Idris

Cloning into 'C:\Idris\Control.Eternal.Idris'...
remote: Reusing existing pack: 221, done.
Receiving objects: 100% (221/221), 20.70 KiB, done.
Resolving deltas: 100% (104/104), done.
Type checking .\Control\Eternal\System\Process.idr
Type checking .\Control\Eternal\System.idr
Type checking .\Control\Eternal\Parse.idr
Type checking .\Control\Eternal\Logic.idr
Type checking .\Control\Eternal\Operators\List.idr
Type checking .\Control\Eternal\Operators\Nat.idr
Type checking .\Control\Eternal\Operators\String.idr
Type checking .\Control\Eternal\Operators\FSharp.idr
Type checking .\Control\Eternal\Operators.idr
Type checking .\Control\Eternal.idr
Installing Control\Eternal.ibc to ....\cabal\idris-
```

Yaml is [Idris.Yaml](https://github.com/Heather/Idris.Yaml) library for parsing config files and it already works, thanks to [lightyear](https://github.com/ziman/lightyear) and JSON example there <br/>
But there are still being a lot of things to do to make it sane, thanks to

``` haskell
data YamlValue = YamlString String
               | YamlNumber Float
               | YamlBool Bool
               | YamlNull
               | YamlObject (SortedMap String YamlValue)
               | YamlArray (List YamlValue) -- TODO: YamlObject

instance Show YamlValue where
  show (YamlString s)   = show s
  show (YamlNumber x)   = show x
  show (YamlBool True ) = "true"
  show (YamlBool False) = "false"
  show  YamlNull        = "null"
  show (YamlObject xs)  =
      "{" ++ intercalate ", " (map fmtItem $ SortedMap.toList xs) ++ "}"
    where
      intercalate : String -> List String -> String
      intercalate sep [] = ""
      intercalate sep [x] = x
      intercalate sep (x :: xs) = x ++ sep ++ intercalate sep xs

      fmtItem (k, v) = k ++ ": " ++ show v
  show (YamlArray  xs)  = show xs

hex : Parser Int
hex = do
  c <- map (ord . toUpper) $ satisfy isHexDigit
  pure $ if c >= ord '0' && c <= ord '9' then c - ord '0'
                                         else 10 + c - ord 'A'

hexQuad : Parser Int
hexQuad = do
  a <- hex
  b <- hex
  c <- hex
  d <- hex
  pure $ a * 4096 + b * 256 + c * 16 + d

specialChar : Parser Char
specialChar = do
  c <- satisfy (const True)
  case c of
    '"'  => pure '"'
    '\\' => pure '\\'
    '/'  => pure '/'
    'b'  => pure '\b'
    'f'  => pure '\f'
    'n'  => pure '\n'
    'r'  => pure '\r'
    't'  => pure '\t'
    'u'  => map chr hexQuad
    _    => satisfy (const False) <?> "expected special char"

yamlString' : Parser (List Char)
yamlString' = (char '"' $!> pure Prelude.List.Nil) <|> do
  c <- satisfy (/= '"')
  if (c == '\\') then map (::) specialChar <$> yamlString'
                 else map (c ::) yamlString'

yamlString : Parser String
yamlString = char '"' $> map pack yamlString' <?> "Yaml string"

-- inspired by Haskell's Data.Scientific module
record Scientific : Type where
  MkScientific : (coefficient : Integer) ->
                 (exponent : Integer) -> Scientific

scientificToFloat : Scientific -> Float
scientificToFloat (MkScientific c e) = fromInteger c * exp
  where exp = if e < 0 then 1 / pow 10 (fromIntegerNat (- e))
                       else pow 10 (fromIntegerNat e)

parseScientific : Parser Scientific
parseScientific = do sign <- maybe 1 (const (-1)) `map` opt (char '-')
                     digits <- some digit
                     hasComma <- isJust `map` opt (char '.')
                     decimals <- if hasComma then some digit else pure Prelude.List.Nil
                     hasExponent <- isJust `map` opt (char 'e')
                     exponent <- if hasExponent then integer else pure 0
                     pure $ MkScientific (sign * fromDigits (digits ++ decimals))
                                         (exponent - cast (length decimals))
  where fromDigits : List (Fin 10) -> Integer
        fromDigits = foldl (\a, b => 10 * a + cast b) 0

yamlNumber : Parser Float
yamlNumber = map scientificToFloat parseScientific

yamlBool : Parser Bool
yamlBool  =  (char 't' >! string "rue"  $> return True)
         <|> (char 'f' >! string "alse" $> return False) <?> "Yaml Bool"

yamlNull : Parser ()
yamlNull = (char 'n' >! string "ull" >! return ()) <?> "Yaml Null"


parseWord' : Parser (List Char)
parseWord' = (char ' ' $!> pure Prelude.List.Nil) <|> do
  c <- satisfy (/= ' '); map (c ::) parseWord'

||| A parser that skips whitespace without jumping over lines
yamlSpace : Monad m => ParserT m String ()
yamlSpace = skip (many $ satisfy (\c => c /= '\n' && isSpace c)) <?> "yamlSpace"

mutual
  yamlArray : Parser (List YamlValue)
  yamlArray = char '-' $!> (yamlArrayValue `sepBy` (char '-'))

  keyValuePair : Parser (String, YamlValue)
  keyValuePair = do
    key <- space $> map pack parseWord' <$ space
    char ':'
    value <- yamlValue
    pure (key, value)

  yamlObject : Parser (SortedMap String YamlValue)
  yamlObject = map fromList $ keyValuePair `sepBy` (char '\n')

  yamlObjectA : Parser (SortedMap String YamlValue)
  yamlObjectA = map fromList $ keyValuePair `sepBy` (char '\n')

  yamlValue' : Parser YamlValue
  yamlValue' =  (map YamlString yamlString)
            <|> (map YamlNumber yamlNumber)
            <|> (map YamlBool   yamlBool)
            <|> (pure YamlNull <$ yamlNull)
            <|>| map YamlArray  yamlArray
            <|>| map YamlObject yamlObject
            
  yamlValueA' : Parser YamlValue
  yamlValueA' =  (map YamlString yamlString)
             <|> (map YamlNumber yamlNumber)
             <|> (map YamlBool   yamlBool)
             <|> (pure YamlNull <$ yamlNull)
             <|>| map YamlArray  yamlArray
             <|>| map YamlObject yamlObjectA

  yamlArrayValue : Parser YamlValue
  yamlArrayValue = space $> yamlValueA' <$ space

  yamlValue : Parser YamlValue
  yamlValue = yamlSpace $> yamlValue' <$ yamlSpace

yamlToplevelValue : Parser YamlValue
yamlToplevelValue = (map YamlArray yamlArray) <|> (map YamlObject yamlObject)
```

Github repository: [https://github.com/Heather/Synthia](https://github.com/Heather/Synthia) <br/>
Code in current state:

``` haskell
ls : String -> IO String
ls path = readProcess' ("ls " ++ path) False 

{- ETERNAL EFFECT WILL DO LS and stuff in EternalIO -}
data Eternal : Effect where
     LS : String -> { () } Eternal String
instance Handler Eternal IO where
    handle () (LS s) k = do x <- ls s; k x ()
instance Handler Eternal (IOExcept a) where
    handle () (LS s) k = do x <- ioe_lift $ ls s; k x ()

ETERNAL : EFFECT
ETERNAL = MkEff () Eternal

els : String -> { [ETERNAL] } Eff IO String
els s = call $ LS s

EternalIO : Type -> Type -> Type
EternalIO st t = { [FILE_IO st, STDIO, SYSTEM, ETERNAL] } Eff IO t 

{- WE NEED ETERNAL POWER! -}
readFile : EternalIO (OpenFile Read) (List String)
readFile = readAcc [] where
  readAcc : List String -> EternalIO (OpenFile Read) (List String)
  readAcc acc = if (not !eof) then readAcc $ !readLine :: acc
                              else return  $ reverse acc

{- IT'S NOT JUST SYSTEM CALL, IT'S POWERFUL THING!-}
sys : String -> { [STDIO, SYSTEM, ETERNAL] } Eff IO ()
sys ss = do system ss
            return ()

finalInstall : String -> List String -> List String -> { [STDIO, SYSTEM, ETERNAL] } Eff IO ()
finalInstall repoDir synss flist =
    case (synss # 0) of
        Just syn => do {- PROCESS PACKAGE INSTALLATION -}
            let truesyn = repoDir ++ syn
            sys $ "pushd " ++ repoDir ++ " & Synthia --install " ++ truesyn
            
            {- Finishing installation -}
            let makeF = filter (== "Makefile") flist
            case (makeF # 0) of
                Just _ => sys $ "pushd " ++ repoDir ++ " & make & make install"
                _ => let pkg = filter (\x => isSuffixOf <| unpack ".ipkg"
                                                        <| unpack (trim x)) flist
                     in case (pkg # 0) of
                         Just pkg => sys $ "pushd " ++ repoDir ++ " & idris --install " ++ pkg
                         _ => putStrLn "No ipkg in this repository"
        _ => putStrLn "No synthia in this repository"

install : List String -> List String -> { [STDIO, SYSTEM, ETERNAL] } Eff IO ()
install [] [] = putStrLn "try Synthia install GitHubUser/Repo"
install [] xs = let Just mypkg = xs # 0
                in sys $ "idris --install " ++ mypkg
install xs _ = do
    let dir = "C:\\Idris\\"
    let Just repo = xs # 0
    case (splitOn '/' (unpack repo)) # 1 of
        Just repx => do let reps = pack repx
                        sys $ "mkdir " ++ dir
                        let repoDir = dir ++ reps ++ "\\"
                        sys $ "git clone git@github.com:" ++ repo ++ ".git " ++ repoDir
                        let flist = splitOn '\n' !(els repoDir)
                        {- PROCESS DEP CHECK! .syn SYNTHIA FILES -}
                        let synss = filter (\x => isSuffixOf <| unpack ".syn"
                                                             <| unpack (trim x)) flist
                        finalInstall repoDir synss flist

        _ => putStrLn "try Synthia install GitHubUser/Repo" 
{- SYMPLY RUN IDRIS WITH ARGUMENTS -}
goC : List String -> List String -> String -> { [STDIO, SYSTEM, ETERNAL] } Eff IO ()
goC pkg args cc =
    case (pkg # 0) of
        Just mypkg => sys $ cc ++ concat <<| drop 2 args
                               ++ " "
                               ++ mypkg
        _ => putStrLn "No ipkg in this repository" 

procs : (List String) -> (List String) -> Bool -> { [STDIO, SYSTEM, ETERNAL] } Eff IO ()
procs args file p =
    let config = concat file {- READ OWN CONFIG FILE -}
    in case parse yamlToplevelValue config of
       Left err => putStrLn $ "error: " ++ err
       Right v  =>
        if p then putStrLn $ show v -- TODO: Install finally deps
             else let pkg = filter (\x => isSuffixOf <| unpack ".ipkg"
                                                     <| unpack (trim x))
                              $ splitOn '\n' !(els ".")
                  in case (args # 1) of
                        Just cmd => case cmd of
                                       "--help"     => putStrLn "try Synthia install GitHubUser/Repo"
                                       "--version"  => putStrLn "0.0.2"
                                       
                                       "build"      => goC pkg args "idris --build "
                                       "clean"      => goC pkg args "idris --clean "
                                       "mkdoc"      => goC pkg args "idris --mkdoc "
                                       "checkpkg"   => goC pkg args "idris --checkpkg "
                                       "testpkg"    => goC pkg args "idris --testpkg "
                                       
                                       "install"    => install (drop 2 args) pkg
                                       "list"       => sys "ls -d1 C:\\Idris/*/"
                                       
                                       _            => putStrLn "What?"
                        _ => putStrLn "What?"
```