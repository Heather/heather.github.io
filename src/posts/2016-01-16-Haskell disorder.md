---
title: Haskell disorder
---

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

In conclusion this problem is known outside haskell. Often some C++ projects shipping with patched Qt or Boost whenever you have it installed
you build and install those monsters in addition to existing and then suffer from possible conflicts. This scheme oftene used for production,
enterprise software, however most of opensource ecosystem don't act like that. In haskell community people act like they're always alike in
production / enterprise and that's what I can't understand, when sandbox became something mandatory?

Do you even know what is induction?
===================================

Yes, Haskell is very hard and maybe I just don't understand anything

<iframe width="420" height="315"
src="http://www.youtube.com/embed/v93rM8-bU2g?autoplay=1">
</iframe>
