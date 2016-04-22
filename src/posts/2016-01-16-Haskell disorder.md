---
title: Haskell disorder
---

Prelude
=======

Many different people have different opinions of what language ecosystem should be.
Many people don't care.
Some people don't care and have opinion in the same time.
How is that?
Simply they are able to build their project and run it using their tool.
They don't need other changes.
They just want to be safe in their (sometimes very specific) workflow.
And that could be even named alike "time-tested strategies that are known to work (like known-good package sets)".
There are could be different reasoning but mostly people tell that they care.
People care about their own workflow.
Sometimes we just need to point that they are not alone.
When you say that something is distro-specific, os-specific, language-specific, workflow-specific
you just face the limitation and limitation is something most people would like to avoid.

Haskell
=======

> Haskell programs and libraries extensively reuse entitites (types,
> functions, rewrite rules, type instances, other stuff) exported from
> external libraries as non-opaque entities to allow aggressive cross-module
> inlining to compile away deep layers of abstraction. It's language's feature.
> If you accept the fact transitive dependencies being able to break ABI is not a GHC bug

> what actually affects real ABI (exported inlines, exported datatype layout changes, modules
> names, strictness annotations, unpack pragmas)
> ghc --show-iface can help in tracking ABI drift.

I've seen that people tell that `stack` and `cabal` are much better than `pip` for example

However when you install library or executable `A` whcih is depending on `B` it's likely already dangerous
Because when we have libraries that have had their dependencies changed it's likely broken (in case of changed ABI)
And neither `stack` neither `cabal` can help you with your broken environment
Neither `python` ever used to had this problem
That could be work for some `package manager` and could be called `revdep-rebuild`
(scan libs for missing shared library dependencies and attempts to fix them by rebuilding broken libs)
That's how you manage dynamic libraries updating on system level

From what I see currently stack is something unmanaged, I can't update some root library used for system binaries

Community
=========

Most of haskell community has no idea that haskell projects even can be installed to system.

I mean for real. Haskellers think that haskell is something that you only run once.
To build small executable inside small sanbox on userspace.
And they are proud of it.

And usually they point you to NixOS or stack (they love stack) tricks alike

> stack has brought a new era of stability to haskell in the real world.
> yes, it's a hack, but it usually works really well.

But actually not everyone can even understand that it's a hack.

Actually stack and sandboxed workflow could be useful for development
But that workflow could be dangerous because people stop thinking about other cases
So Haskell projects is becoming sandbox-only

For example when one project, for example Idris, start using changed (bumped)
library which is shipped with `GHC` it feels absolutely fine on sandbox
But when user will install idris (and that library to system) all other libraries
will become broken because their dependencies is changed by that
That's why some core packages has `-compat` compatibility layers
Sure developers tell me that they don't care and everything works fine
in sandboxes and downgrading this library is `distro-patch`

Sandbox all the things!
=======================

For example we can use `A > 2` for library `B` and `A < 2` for library `C` so we do but we can't use libraries `B` and `C` together.
It will be a problem for someone who want to use `B` and `C` but not a problem at all for either `B` and `C` developers.
Because we have so much cool tools: lovely stack and cabal sandboxes which allow us to use `B` for application `X` and `C` for application `Y` together but sandboxed.
Most horrible thing there is that most of Haskell developers really don't see reason to support another `A` versions.

Another horrible thing there is when developers don't bump `A` just because they are lazy to test and don't need it.
If you think that's not the case you can check how often we bump max limits with `cabal_chdeps` calls in `gentoo-haskell` ebuilds.

All those `distro-patches` and weak `distro-hacks` used in Gentoo for haskell makes `portage` the only one existing package manager for haskell.
I'm not sure if Nix people have any progress in this direction honestly.
I don't see how Stackage can do the same. With portage you can use Haskell without sandboxes and without breaking everything, YES YOU CAN.
NOTHING IS IMPOSSIBLE. But community don't need it. Most of haskell developers I was speaking with JUST DON'T CARE about compatibility and even see no real problems.

I don't know why but people don't understand my reasoning, everywhere people tell me that I just don't understand stack...

Another horrible hacks are packages provided by GHC (alike transformers) and hacks packages with `-compat`.
I don't even know honestly why it's there but if some package needs `tranformers` upper then in GHC it just break everything else if you're not in sandbox.

next day to write some Hello World in Haskell you will need to buy PC supporting building Hello World in Haskell,
install Hello World Building OS, Create Hello World sandbox with HelloWorld compiler, patch Hello World library to support Hello World compiler from your "LTS"
but sure we have all the tools to make it simple! we're so much proud about them...
with stack we can have Hello World compiler installed once for user so we can build many Hello World applications alike that using this same compiler.
I know, awesome...

But where we go? There was no package manager for haskell for many years [Cabal is not a Package Manager](https://ivanmiljenovic.wordpress.com/2010/03/15/repeat-after-me-cabal-is-not-a-package-manager/)
and now there is stack which is doing the same but only a bit better, that's why I don't like stack. I was hoping for radical changes
but there is just a bit more handy util to produce same problems again, not to resolve but to avoid.

Look at this function is one of core packages in Setup.lhs:

``` haskell
testDeps :: ComponentLocalBuildInfo -> ComponentLocalBuildInfo -> [(InstalledPackageId, PackageId)]
testDeps xs ys = nub $ componentPackageDeps xs ++ componentPackageDeps ys
```

It doesn't work because `InstalledPackageId` is changed to `UnitId` in new cabal but you can't fix it.
Ideally maybe you can

``` haskell
#if MIN_VERSION_Cabal(1, 23, 0)
testDeps :: ComponentLocalBuildInfo -> ComponentLocalBuildInfo -> [(UnitId, PackageId)]
#else
testDeps :: ComponentLocalBuildInfo -> ComponentLocalBuildInfo -> [(InstalledPackageId, PackageId)]
#endif
```

but because it's Setup.lhs you can't use `MIN_VERSION_Cabal` MIN_VERSION_Cabal is a macro from cabal_macros.h that is generated by Setup.lhs
so you pick either people with old cabal will always fail or people with new cabal will always fail, such stuff are all around haskell

In conclusion this problem is known outside haskell. Often some C++ projects shipping with patched Qt or Boost whenever you have it installed
you build and install those monsters in addition to existing and then suffer from possible conflicts. This scheme often used for production,
enterprise software, however most of opensource ecosystem don't act like that. In haskell community people act like they're always alike in
production / enterprise and that's what I can't understand, when sandbox became something mandatory?
