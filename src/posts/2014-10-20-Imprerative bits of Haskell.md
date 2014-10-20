---
title: Imperative bits of Haskell
---

Haskell is purely functional. However sometimes people (and me also) need some imperative bits with various reasons: sometimes it could be performance, sometimes simpler design, etc...
However even being purely functional Haskell is very good imperative language.

Data.IORef
----------

``` haskell
test1 :: (PlusPlus a, Show a) => IORef a -> IO ()
test1 a = do (a ++); (a ++); print a

main = do 
    test1 =<< int 1
    test1 =<< float 1.0
    x <- int 1
    x += 4
    x -= 2
    print x
```

realization [source](https://github.com/Heather/io-ref-tests/blob/master/src/Haskellplusplus.hs):

```haskell
int :: Int -> IO (IORef Int)
int x = newIORef x

float :: Float -> IO (IORef Float)
float x = newIORef x

class PlusPlus a  where
   (++) :: IORef a -> IO ()
   (+=) :: IORef a -> a -> IO ()
   (-=) :: IORef a -> a -> IO ()
   print :: IORef a -> IO ()

instance PlusPlus Int where
   (++) r = do x <- readIORef r;    writeIORef r $ x + 1
   (+=) r v = do x <- readIORef r;  writeIORef r $ x + v
   (-=) r v = do x <- readIORef r;  writeIORef r $ x - v
   print r = do x <- readIORef r;    P.print $ P.show x

instance PlusPlus Float where
   (++) r = do x <- readIORef r;    writeIORef r $ x + 1.0
   (+=) r v = do x <- readIORef r;  writeIORef r $ x + v
   (-=) r v = do x <- readIORef r;  writeIORef r $ x - v
   print r = do x <- readIORef r;    P.print $ P.show x
```

However Haskell supports it out from the box! <br/>
[Syntax sugar for mutable types](http://www.haskell.org/haskellwiki/Library/ArrayRef#Syntax_sugar_for_mutable_types)

``` haskell
main = do -- syntax sugar used for reference:
          x <- ref (0::Int)
          x += 1
          x .= (*2)
          a <- val x
          print a
 
          -- syntax sugar used for array:
          arr <- newArray (0,9) 0 :: IO Array Int Int
          (arr,0) =: 1
          b <- val (arr,0)
          print b
```

Better example with C operators:
--------------------------------

``` haskell
for' ( a =: Lit 1 , a <. Lit 11 , a +=: Lit 1 ) $ do {
    b <- new 0;
    b =: a;
    defer' $ do {
       print' b;
    };
    n *=: a;
    if' ( a <. Lit 5)
        continue';
    if' ( a >. Lit 2) 
        break';
    return' a;
}
```

realization [source](https://github.com/mmirman/ImperativeHaskell/blob/master/Control/Monad/Imperative/Internals.hs):

``` haskell
-- | @'for''(init, check, incr)@ acts like its imperative @for@ counterpart
for' :: (CState i, HasValue r (V b r) i, HasValue r valt TyInLoop) => (MIO i r irr1, V b r Bool, MIO i r irr2) -> valt () -> MIO i r ()
for' (init, check, incr) body = init >> for_r
    where for_r = do
            do_comp <- val check
            when do_comp $ callCC $ \break_foo -> do
                           callCC $ \continue_foo -> MIO $
                             wrapState (getMIO $ val body) statefulRetCont $ \inbod -> 
                                InLoop (toLoop $ break_foo ()) (toLoop $ continue_foo ()) (getReturn inbod)
                           incr
                           for_r
```

STRef [source](http://en.wikibooks.org/wiki/Haskell/Mutable_objects) 
--------------

``` haskell
import Control.Monad.ST
import Data.STRef
import Data.Map(Map)
import qualified Data.Map as M
import Data.Monoid(Monoid(..))

memo :: (Ord a) => (a -> b) -> ST s (a -> ST s b)
memo f = do m <- newMemo
            return (withMemo m f)

newtype Memo s a b = Memo (STRef s (Map a b))

newMemo :: (Ord a) => ST s (Memo s a b)
newMemo = Memo `fmap` newSTRef mempty

withMemo :: (Ord a) => Memo s a b -> (a -> b) -> (a -> ST s b)
withMemo (Memo r) f a = do m <- readSTRef r
                           case M.lookup a m of
                             Just b -> return b
                             Nothing -> do let b = f a
                                           writeSTRef r (M.insert a b m)
                                           return b
```

Data.Vector.Mutable [hackage](http://hackage.haskell.org/package/vector-0.9.1/docs/Data-Vector-Mutable.html)
-----------------------------

``` haskell
import qualified Data.Vector.Unboxed.Mutable as M

main = do
    v <- M.new 10
    M.write v 0 (3 :: Int)
    x <- M.read v 0
    print x
```

ArrayRef [hackage](http://hackage.haskell.org/package/ArrayRef-0.1.3.1/src/Examples/Array/Dynamic.hs)
------------------

``` haskell
import Data.ArrayBZ.Dynamic

main = do -- This array will grow at least two times each time when index is out of bounds,
          -- because it is created using `newDynamicArray growTwoTimes`
          arr <- newDynamicArray growTwoTimes (0,-1) 99 :: IO (DynamicIOArray Int Int)
          -- At this moment the array is empty
          printArray arr

          -- During this cycle the array extended 3 times
          for [0..5] $ \i ->
             writeArray arr i i
          printArray arr

          -- During this cycle the array extended one more time
          for [-5 .. -1] $ \i ->
             writeArray arr i i
          printArray arr

          -- Operation that explicitly resizes the array
          resizeDynamicArray arr (3,15)
          printArray arr

          -- This array will not grow automatically because it is created using `newArray`,
          -- but it can be resized explicitly using `resizeDynamicArray`
          arr <- newArray (0,-1) 99 :: IO (DynamicIOArray Int Int)
          resizeDynamicArray arr (0,0)
          printArray arr
          writeArray arr 1 1  -- this operation raises error

printArray arr = do
          bounds   <- getBounds arr
          contents <- getElems  arr
          putStrLn (show bounds++" : "++show contents)

for list action = mapM_ action list
```

Data.Array.Storable [hackage](http://www.haskell.org/ghc/docs/latest/html/libraries/array/Data-Array-Storable.html)
-----------------------------

A storable array is an IO-mutable array which stores its contents in a contiguous memory block living in the C heap. Elements are stored according to the class Storable. You can obtain the pointer to the array contents to manipulate elements from languages like C.

``` haskell
{-# OPTIONS_GHC -fglasgow-exts #-}
import Data.Array.Storable
import Foreign.Ptr
import Foreign.C.Types
 
main = do arr <- newArray (1,10) 37 :: IO (StorableArray Int Int)
           a <- readArray arr 1
           withStorableArray arr 
               (\ptr -> memset ptr 0 40)
           b <- readArray arr 1
           print (a,b)
 
foreign import ccall unsafe "string.h" 
     memset  :: Ptr a -> CInt -> CSize -> IO ()
```

Finally [Lens](http://hackage.haskell.org/package/lens-1.7/docs/Control-Lens-Setter.html)
--------------

 - [LensBeginnersCheatsheet](http://www.haskell.org/haskellwiki/LensBeginnersCheatsheet)
 - [FPComplete: Basic Lensing](https://www.fpcomplete.com/school/to-infinity-and-beyond/pick-of-the-week/basic-lensing)
 - [Lenses In Pictures](http://adit.io/posts/2013-07-22-lenses-in-pictures.html)
 
``` haskell
data Point = Point { _x, _y   :: Double }
data Mario = Mario { _location :: Point }

player1 = Mario (Point 0 0)

location.x `over` (+10) $ player1
```

Check out also:

 - [Haskell: the best imperative programming language](http://code.haskell.org/~slyfox/2014-04-27-haskell-intro.pdf)
 - [Haskell IO for Imperative Programmers](http://www.haskell.org/haskellwiki/Haskell_IO_for_Imperative_Programmers)
 - [Why is Haskell (sometimes) referred to as “Best Imperative Language”](http://stackoverflow.com/questions/6622524/why-is-haskell-sometimes-referred-to-as-best-imperative-language)
 - [Haskell.org : Arrays](http://www.haskell.org/haskellwiki/Modern_array_libraries)
