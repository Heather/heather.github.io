---
title: Selling dependent types
---

There was long standing question on [Twitter](https://twitter.com/lenadroid/status/577058060860071937)

practical application/use cases of dependently typed programming languages?
===========================================================================


Edwin Brady:

> My current favourite phrase is "making assumptions explicit" - if you assume something, tell the type checker! [1/2] <br/>
> e.g. in non DT code I might assume a list can't be empty, but it's hard to make that explicit and it bites later [2/2] <br/>
> This kind of lightweight property may be more valuable than the strong correctness proofs we like to show off with [3/2] <br/>
> Seems I violated an assumption… [4/4]

Great answer from Chris Allen:

> in Haskell values can generate values, types can generate values, values *cannot* generate types.
> That sucks and means there's a bunch of things you're not allowed to do. There's a phase separation between types and values.
> in Idris, types and values can hop back and forth interchangeably, almost kinda like if you had reflection, except it's type-safe and used to create types that very precisely circumscribe what you want.
> puffnfresh's printf tutorial is a good example of this.
> there ways to avoid needing dependent types in Haskell, but most people would like the option.
> it simplifies things related to writing very precisely typed software
> it makes writing more type-safe software less troublesome.
> it also often means you can more readily use the language as a sort of proof engine.
> I've seen people do this in Haskell, but it's far more common in Coq, Agda, etc.
> virtually everything could use more type-safety.
> something as common as printf benefits from dependent types.
> imagine being able to take the requirements of business logic, which are usually enforced at runtime, and turn them into a proof?
> now your programs can't violate the contracts you want to enforce.

Answer from Brian McKenna:

> yeah, proofs as programs, one useful thing
> another is safe metaprogramming
> e.g. string interpolation, custom literals
> one example I've been interested in recently is putting Big-O complexity into types
> so proving some performance characteristics of algorithms

(I should also post link to this [printf](https://gist.github.com/puffnfresh/11202637))

I was asked to post my simple explanation so here is it...

For example everybody knows about generics and why and where they are useful and we call it alike `foo<Type>()`, now imagine we have some function which does something and returns Type based on integer, for example 4 -> Int, 2 -> Short, 8 -> Long, etc...  So we can `foo<bar(i)>()` so in this case you will not create additional case type-binder... e.g. you still write that 4 will be Int but you don't write that 4 will be foo<int> ... that looks like small metaprogramming trick but when it's all over the code it's not bad, e.g. better readability and more available programming tactics for logics implementation, faster solution solving

Let take a look to example on [rust-lang.org](http://www.rust-lang.org)

``` cpp
let program = "+ + * - /";
let mut accumulator = 0;

for token in program.chars() {
    match token {
        '+' => accumulator += 1,
        '-' => accumulator -= 1,
        '*' => accumulator *= 2,
        '/' => accumulator /= 2,
        _ => { /* ignore everything else */ }
    }
}
```

Press `Run` on website

Not sure if you guess or not but result is 1, because it's integer...

How we can handle it with Idris?

``` haskell
prog : String
prog= "+ + * - /"

cType : String → Type
cType c = if '/' ∈ (unpack c)
            then Float
            else Int

main : IO ()
main = putStrLn $ "The program "
                    ⧺ prog
                    ⧺ " calculates the value "
                    ⧺ (show $ acc (unpack prog) 0)
 where acc : (List Char) → (cType prog) → (cType prog)
       acc [] m = m
       acc (x::xs) m = acc xs $ case x of
                                 '+' => m + 1
                                 '-' => m - 1
                                 '*' => m ⋅ 2
                                 '/' => m ÷ 2
                                 _   => m
```

``` shell
The program + + * - / calculates the value 1.5
```

Discover the difference... But it's small case. With thinking about types we can resolve a lot of common problems much faster. One of the great examples will be type providers in Idris [github](https://github.com/david-christiansen/idris-type-providers) [pdf](http://itu.dk/people/drc/pubs/dependent-type-providers.pdf) by David Christiansen
