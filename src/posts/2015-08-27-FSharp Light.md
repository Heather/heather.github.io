---
title: F# Light
---

F# Light Changes and Features
=============================

Minor fixes and improvements:
-----------------------------

 - fixed `let` `in` encapsulation, e.g. you no longer can use let bindings outside `in` blocks
 
e.g. this code

``` fsharp
let x = 0
in printfn "x: %d" x

printfn "x: %d" x
```

will fail in compile time with error "Not in scope: `x`"
 
 - `let` is `letrec` but syntax `let x, y = 0, 1` will be improved

``` fsharp
let x = 0
    y = 1
in printfn "x: %d, y: %d" x y
```

 -  applicative generic computation expressions, you no longer need to write `xs |> Seq.map`

``` fsharp
let lst5n6  = map ((+) 4) [ 1;2 ]
    arr5n6  = map ((+) 4) [|1;2|]
    lst5n6' = (+) <!> [4] <*> [1;2]
```

Note: you already can use it with [F#+](https://github.com/gmpl/FSharpPlus/tree/master/FSharpPlus/Samples)

 - improved type inference
 
currently you can't compile `Seq.map (fun fi -> fi.Name) fis` and that's why you need that pipe `fis |> Seq.map (fun fi -> fi.Name)` [source](http://stackoverflow.com/questions/844733/why-cant-fs-type-inference-handle-this).
You simply can't have

``` fsharp
let f = exp
```

if exp if some expression and you need

```
let f x = x |> exp
```

now you can just use real point-free programmign style.

 - `let mutable` is deprecated, language is becoming truly functional

Breaking changes:
-----------------

 - Compiler plugins
 - Type calsses (well, sure there is F#+) and GADTs
 - .fshproj XML based projects are deprected, instead project files are YAML based and writeable by hand.
 - Good module system and tooling.
 - .NET platform is deprecated (with dropping all the .NET type system designed for OO languages)
 - Native binaries generation!
 - Laziness by default

You can use it with old F# right now!
=====================================

Since F# Light can generate native binaries it also can generate native FFI shared libraries. And they could be called from current F# alike that:

``` fsharp
module FSharp

open System
open System.Runtime.InteropServices

[<DllImport("FSharpLight.dll", CallingConvention = CallingConvention.Cdecl)>]
extern void hs_init
   ( IntPtr argc
   , IntPtr argv)

[<DllImport("FSharpLight.dll", CallingConvention = CallingConvention.Cdecl)>]
extern void hs_exit()

[<DllImport("FSharpLight.dll", CallingConvention = CallingConvention.Cdecl)>]
extern int fSharpLight(string str)

printfn "Initializing runtime..."
hs_init(IntPtr.Zero, IntPtr.Zero)

try
    printfn "Calling to FSharpLight..."
    let result = fSharpLight("F#")
    printfn "Got result: %d" result
with
| _ as ex -> printfn "Error: %s" ex.Message
             hs_exit()
```

it could be compiled with `fsc` simply alike:

``` shell
set fsc="C:\Program Files (x86)\Microsoft SDKs\F#\3.1\Framework\v4.0\fsc.exe"
%fsc% hs.fs
```

FSharpLight.dll
--------------

``` haskell
{-# LANGUAGE
    UnicodeSyntax
  , ForeignFunctionInterface
  #-}

module FSharpLight where

import Foreign.C.String
import Foreign.C.Types

foreign export ccall
  fSharpLight ∷ CString → IO CInt

fSharpLight ∷ CString → IO CInt
fSharpLight c_str = do
  str    ← peekCString c_str
  result ← fs_foo str
  return $ fromIntegral result

fs_foo ∷ String → IO Int
fs_foo str = do
  putStrLn $ "Hello, " ++ str
  return (length str + 42)
```

sadly for now there is no FSharpLight compiler but you can simply use `GHC`

``` shell
ghc -O2 --make -no-hs-main -shared -o FSharpLight.dll FSharpLight.hs
```

and run the whole thing with

``` shell
set LD_LIBRARY_PATH=. && "FSharp.exe"
```

output:

``` shell
Initializing runtime...
Calling to FSharpLight...
Hello, F#
Got result: 44
Done
```

It's a parody to [this](http://fsharpforfunandprofit.com/csharp-light/) blog post :) Happy Hacking
