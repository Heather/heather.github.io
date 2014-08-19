---
title: Async Reactive Haskell
---

First: added dirty lifts to [Hackage](https://hackage.haskell.org/package/eternal-0.0.7/src/src/Control/Eternal/Syntax/Lift.hs)

[io-reactive](https://github.com/andygill/io-reactive/pull/1)
-------------------------------------------------------------

Tiny library for generating reactive objects

``` haskell
data Progress
    = Progress { pr_inc  :: IO ()
               , pr_done :: IO ()
               }
mkProgress :: Handle  -> IO Progress
mkProgress h = reactiveObjectIO 0 $ \ _pid req act done ->
  Progress { pr_inc = do hPutStr h "."
                         hFlush h
           , pr_done = do hPutStr h "\nDone\n"
                          hFlush h 
                          done }
```

async
-----

So now we can run some task and react in async on task progress, we even can use periodic pull to our async thread!

``` haskell
doProcess :: Progress -> Async () -> IO ()
doProcess r prc = 
    poll prc >>= \case Nothing -> pr_inc r >> threadDelay 10000 >> doProcess r prc
                       Just _e -> case _e of
                                   Left ex -> putStrLn $ "Caught exception: " ++ show ex
                                   Right _ -> pr_done r

asyncReactive :: IO () -> IO ()
asyncReactive foo = liftM2_ doProcess (mkProgress stdout)
                                     $ async foo
```

Looks cool but does it works and usage:

``` haskell
asyncReactive $ sequence_ [ threadDelay 100000 >> print "A" | n <- [1..50] ]
```

that easy, result will be:

``` shell
.........."A"
.........."A"
.........."A"
.........."A"
.........."A"
.........."A"
.........."A"
.........."A"

...

Done
```

It could be useful for example to visualise activity of an long process which doesn't visualise it's activity [(example)](https://github.com/Heather/Sharingan/blob/master/src/Shell.hs#L103)
