---
title: Haskell disorder
---

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

There are known problems which developers regularry face with cabal-install
and stack brings easier and safer workflow for developers, that's true. But
I don't see how stack can help developers to understand other aspects

When haskellers talk about user installation they really mean sandbox
When haskellers talk about global installation they mean user installation
When haskellers talk about system installation their brains blows

People complain that on Haskell.org there is harmful workflow for
developers introducing Haskell Platform and it should be overtaken by
stack. (Note that Haskell Platform is system installation used by different
users and it can't be messed up with user installation)

However either `cabal-install` and `stack` worklows are both harmful for
users, `stack` does resolve nothing for user side, it just helps you with
sandbox managing during development stage.

I will try to explain.

Regularly users use package managers (on windows installers) to get what
they want, that's how users install python projects, C++ projects, etc...
users don't use pip (really they don't)

What about haskell? On most distributions and Windows users should use
what? sandboxes for every program and install those progam for every users
avoiding system installation?

Currently yes. Other ways will be harmful. There is solution from NixOS but
I doubt if they've managed to implement revdep rebuild for haskell
packages. I like (a lot) solution from gentoo where you can simply run
`emerge idris` and everything will be installed on system alike you install
some python util (alike portage itself). But even in Gentoo there is dirty
hack to manage haskell packages updates.

it looks really dirty

``` shell
    haskell-updater -- --jobs="$(($(nproc) + 1))" --verbose-conflicts
--backtrack=100
    haskell-updater -- --jobs="$(($(nproc) + 1))" --verbose-conflicts
--backtrack=100
```

basically it's rebuilding all libs depending on changed one then depending
on depending incrementally

What is it even?

Haskell programs and libraries extensively reuse entitites (types,
functions, rewrite rules, type instances, other stuff) exported from
external libraries as non-opaque entities to allow aggressive cross-module
inlining to compile away deep layers of abstraction. It’s language’s
feature. If you accept the fact transitive dependencies being able to break
ABI is not a GHC bug

what actually affects real ABI (exported inlines, exported datatype layout
changes, modules names, strictness annotations, unpack pragmas) ghc
–show-iface can help in tracking ABI drift.

So in nutshell it's a feature but when we're fixing linkage for C/C++ we
can scan libs for missing shared library dependencies and attempts to fix
them by rebuilding broken libs
For haskell we hardly can detect ABI changes and the only way I know
currently is `haskell-updater` util and I'm still looking for better
solution

For example when one project, for example Idris, start using changed
(bumped) library which is shipped with GHC it feels absolutely fine on
sandbox But when user will install idris (and that library to system) all
other libraries will become broken because their dependencies is changed by
that That’s why some core packages has -compat compatibility layers Sure
developers tell me that they don’t care and everything works fine in
sandboxes and downgrading this library is distro-patch

Note that currently either cabal-install and stack has nothing to do with
atomic packages managing. Package manager can install, can remove, can
update, can track dependies changes and end with working environment
without sandbox replacing. Honestly it's very same situation with python or
perl with only difference... When I install software written on python I
don't need to use `pip` and `Haskell` seems like much harder to package but
people everywhere only force you to use really wrong solutions (including
community loved stack)

So my question is generally to community: are we even going to think in
direction of users or are we just focus on developers and their sandboxes?
In second case we need docker for each Haskell project.