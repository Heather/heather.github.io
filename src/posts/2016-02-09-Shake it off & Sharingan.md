---
title: Small haskell utils
---

Work in progess
---------------

There are few utils I used to write and wanted to explain how do I use them and what was the reason of creating them.
This article is work in progress. First small util is actually poor shake clone, imperative and weak

Example
-------

`shake.it.hs` file (or `shake.it.lhs`)

``` haskell
import Shake.It.Off

main :: IO ()
main = shake $ do
  phony "clean" $ cabal ["clean"]

  obj "dist/build/Cr.exe" $ do
    cabal ["install", "--only-dependencies"]
    cabal ["configure"]
    cabal ["build"]
```

every time you run `shake` on this file if `shake.it.off` is outdated or not exists it will be rebuild (otherwise you will just run shake.it.off); when you will run `shake clean` it will process just `cabal clean`, if you will run it with no arguments then it will rebuild project, if you will run it with `shake clean install` it will process `shake clean` first then in case if there will be `shake install` phony it will process it, else way it will process default case (rebuilding) after cleaning. (because it's simple stupid imperative)

more complex example with Unicode operators:

``` haskell
{-# LANGUAGE UnicodeSyntax #-}

import Shake.It.Off

import System.Exit
import System.Process

import Control.Monad

main :: IO ()
main = shake $ do
  "clean" ∫ cabal ["clean"]

  weathermanExecutable ♯ do
    cabal ["install", "--only-dependencies"]
    cabal ["configure"]
    cabal ["build"]

  "install" ∫ cabal ["install"]

  "test" ◉ [weathermanExecutable] ∰ w ["--version"]

 where buildPath :: String
       buildPath = "dist/build/w"

       weathermanExecutable :: String
       weathermanExecutable = buildPath </> "w.exe"

       w :: [String] → IO ()
       w xs = rawSystem weathermanExecutable xs >>= checkExitCode
               >> exitSuccess
```

User story
----------

I like haskell and it will be cool to just use `haskell` to build some complex application and discovered `shake` but there was some strange things which was a bit complicated for me

``` haskell
"dist/build/Cr" <.> exe %> \out -> do traced "blabla" ..... >> return ()
Linking dist\build\Cr\Cr.exe ...
Error when running Shake build system:
* dist/build/Cr.exe
Error, rule "dist/build/Cr.exe" failed to build file:
  dist/build/Cr.exe
```

I was trying to understand realization and I've got some bits. It's impossible to have analitics without wrapping IO into Rules and Action and maybe custom functions for those wrappers. I was trying to get deeper and repeat something alike with `free` alike in this example https://github.com/ekmett/free/blob/master/examples/RetryTH.hs - and it's really not that simple to understand what's actually happening there. And there `withRetry` block is sure not IO () block, just yet another wrapper. Yes, wrapped Rules and Actions are easy to process but I don't want to learn that stuff so far, I don't want to lift from IO to Action and bind it to Rule everytime I want to make small change. This library/util is tiny but practical, it's doing very simple things and using imerative way including global mutable state to resolve things alike `phony` in dirty (but simple) way.

Simple time tracking
--------------------

github: https://github.com/Heather/Weatherman

Idea is pretty simple stupid, when you start tracking some task it writes down start time in yaml file with track number

``` haskell
trackFile :: Int → String → IO ()
trackFile id startDate = do
  (_, trackFile) ← getTrack id
  trackYaml ← startTrack trackFile
  let trackStart =
        trackYaml { start = startDate
                  , pause = Nothing
                  , tracked = Nothing
                  }
  yEncode trackFile trackStart
  
trackTask :: Int → IO ()
trackTask id = do
  c1 ← getCurrentTime
  let dateString = show c1
  putStrLn dateString
  if id /= 0
    then do
      putStrLn $ "tracking " ++ show id
      trackFile id dateString
    else do putStrLn "Press any key to stop tracking"
            waitForKeyPress
            putStr "Tracked "
            diff ← diffTime c1
            putStrLn $ humanReadableTimeDiff diff
```

When you pause it calculates tracked time (diff) and set paused flag

``` haskell
pauseT :: (String, String) → IO ()
pauseT (t,p) = do
  trackYaml ← openTrack p
  case trackYaml of
    Nothing    → exitFailure
    Just yaml  → do
      pauseDate ← getCurrentTime
      let startDate = read $ start yaml :: UTCTime
          currentTracked = fromMaybe "0" (tracked yaml)
          currentTime = read currentTracked :: Int
      difft ← diffTime startDate
      let diff = fromEnum difft :: Int
          total = show $ diff + currentTime
          pauseString = show pauseDate
          trackStart  =
            yaml { pause = Just pauseString
                 , tracked = Just total
                 }
      putStrLn $ t ++ " paused at " ++ pauseString
      yEncode p trackStart
```

When you resume it simply changes start time

``` haskell
resumeT :: (String, String) → IO ()
resumeT (t,p) = do
  trackYaml ← openTrack p
  case trackYaml of
    Nothing    → exitFailure
    Just yaml  → do
      resumeDate ← getCurrentTime
      let resumeString = show resumeDate
          trackStart =
            yaml { pause = Nothing
                 , start = resumeString
                 }
      putStrLn $ t ++ " resumed at " ++ resumeString
      yEncode p trackStart
```

When you finish you calculated tracked time sum with diff from current to start time

``` haskell
getTotalTracked :: Track → IO NominalDiffTime
getTotalTracked cfg = do
  difft ← case pause cfg of
      Just _  → return 0
      Nothing → diffTime c1
  let diffInPicos  = fromEnum difft
      totalTracked =
        toEnum (diffInPicos + trackedTime) :: NominalDiffTime
  return totalTracked
 where startDate :: String
       startDate = start cfg
       trackedTime :: Int
       trackedTime =
         case tracked cfg of
           Just t  → read t :: Int
           Nothing → 0
       c1 :: UTCTime
       c1 = read startDate :: UTCTime

finishT :: Bool → (String, String) → IO ()
finishT remove (t,p) = do
  trackYaml ← openTrack p
  case trackYaml of
    Nothing    → exitFailure
    Just yaml  → do
      totalTracked ← getTotalTracked yaml
      putStr $ "* " ++ t ++ " : "
      putStrLn $ humanReadableTimeDiff totalTracked
      when remove $ removeFile p
```

also you can iterate all tracks and pause / resume /finish all

``` haskell
iterateTasks :: ((String, String) → IO ()) → IO ()
iterateTasks action = do
  workDir ← getWorkDir
  content ← getDirectoryContents workDir
  let tasks = filter (isPrefixOf "task-") content
      abslt = map (\t → (t, workDir </> t)) tasks
  forM_ abslt action
  
pauseTask :: Int → IO ()
pauseTask id = pauseT =<< getTrack id

resumeTask :: Int → IO ()
resumeTask id = resumeT =<< getTrack id

finishTask :: Int → IO ()
finishTask id = finishT True =<< getTrack id

list :: IO ()
list = iterateTasks (finishT False)

pauseAll :: IO ()
pauseAll = iterateTasks pauseT

resumeAll :: IO ()
resumeAll = iterateTasks resumeT

finishAll :: IO ()
finishAll = iterateTasks (finishT True)
```

functions startTrack / openTrack are simply manipulations with yaml

``` haskell
condM :: Monad m ⇒ [(m Bool, m a)] → m a
condM ((test,action) : rest) =
  test >>= \t → if t then action
                     else condM rest

getWorkDir ∷ IO FilePath
getWorkDir =
  if | os ∈ ["win32", "mingw32", "cygwin32"] →
        (takeDirectory <$> getExecutablePath)
     | otherwise → getHomeDirectory

getTrack ∷ Int → IO (String, FilePath)
getTrack id = getWorkDir >>= \w →
                return (τ, w </> τ)
 where τ :: String
       τ = "task-" ++ show id

startTrack ∷ String → IO Track
startTrack trackFile =
  condM [ (doesFileExist trackFile, yDecode trackFile ∷ IO Track)
        , ( return True
          , return Track { tracked = Nothing
                         , start = "0"
                         , pause = Nothing
                         })]

openTrack ∷ String → IO (Maybe Track)
openTrack trackFile =
  condM [ (doesFileExist trackFile
         , Just <$> (yDecode trackFile ∷ IO Track))
         , ( return True
           , return Nothing)]
```

Yet another sync util (Sharingan)
---------------------------------

Simply folder worker performing various synchronization actions && custom actions from yml configs just alike travis and I don't know sane method of doing it for now, alternative.
Maybe simple script can do it but it's not handy to write such script each time.

Honestly I'm really lazy to rewrite current implementation of this tool :D

``` haskell
synchronize     -- actual synchronization function
  ∷ CommonOpts  -- common options
  → SyncOpts    -- synchronization options
  → IO()
synchronize _o so = -- ( ◜ ①‿‿① )◜
  withDefaultsConfig $ \defx →
   withConfig $ \ymlx → despair $ do
    jsdat ← yDecode ymlx ∷ IO [RepositoryWrapper]
    jfdat ← yDecode defx ∷ IO DefaultsWrapper
    myenv ← getEnv
    let dfdat = _getDefaults jfdat
        rsdat = map _getRepository jsdat
#if ( defined(mingw32_HOST_OS) || defined(__MINGW32__) )
    when (syncFull so ∨ (fromMaybe False (full dfdat))) $ do
      when (fromMaybe True (updateCabal dfdat)) cabalUpdate
      when (fromMaybe False (updateStack dfdat)) stackUpdate
#endif
    forM_ rsdat $ sync myenv dfdat where
  sync :: MyEnv       -- environment
        → Defaults    -- default options
        → Repository  -- repository (iterating)
        → IO ()
  sync myEnv dfdata repo =
    let loc = location repo
        isenabled = fromMaybe True (enabled repo)
        frs = syncForce so
        ntr = syncInteractive so
        nps = syncNoPush so
    in when (case syncFilter so of
                    Nothing  → case syncGroups so of
                                    [] → isenabled
                                    gx  → case syncGroup repo of
                                                Just gg → isenabled ∧ (gg ∈ gx)
                                                Nothing → False
                    Just snc → isInfixOf <| map toLower snc
                                         <| map toLower loc)
      $ let ups = splitOn " " $ upstream repo
            snc = sharingan (syncInteractive so) adm
            cln = fromMaybe False (clean repo)
            adm = fromMaybe False (root repo)
            noq = not $ fromMaybe False (quick dfdata)
            tsk = task repo
            vcx = vcs repo
            u b = do
              printf " - %s : %s\n" loc b
              if nps ∧ tsk /= "pull"
                then return (True, True)
                else amaterasu tsk loc b ups (syncUnsafe so)
                        frs cln adm (hash repo) myEnv vcx
            eye (_, r) = when ((r ∨ frs) ∧ not (syncQuick so) ∧ noq)
              $ do let shx = loc </> ".sharingan.yml"
                       ps  = postRebuild repo
                   doesFileExist shx ≫= sharingan
                        ntr adm shx loc
                   when (isJust ps) $ forM_ (fromJust ps) $ \psc →
                      let pshx = psc </> ".sharingan.yml"
                      in doesFileExist pshx≫= snc pshx psc
        in do forM_ (tails (branches repo))
               $ \case [x] → u x ≫= eye -- Tail
                       x:_ → u x ≫= (\_ → return ())
                       []  → return ()
              putStrLn ⊲ replicate 80 '_'

```
