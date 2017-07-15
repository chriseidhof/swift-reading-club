## Compiling to Categories

### Conal Elliott

> Stream-of-consciousness summary by @chriseidhof

Link to the paper (and a video): http://conal.net/papers/compiling-to-categories/

The paper was a nice and easy read, for the most part. I really appreciated how well the first sections were explained. I found it interesting that you can basically take GHC Core, express it using CCC's, and that this actually works.

Another interesting thing is that this works at the source level. I've experimented with (E)DSL's, and noticed that it is very annoying indeed to not have source level access. For example, when you're trying to compile a function type, you can't "look inside" and see the body of the lambda abstraction when you're writing an EDSL. With source level transformations, you can do this (easily).

The Ok trick (section 6) was nice for adding constraints to the types involved.

Some of the applications were interesting, but I didn't try to understand everything in great detail. I have no clue what linear maps are and when to use automatic differentation or incremental computation / interval analysis.

> Stream-of-consciousness summary by @bkase

This paper convers a really fascinating idea: Since the simply typed lambda calculus is an instance of a Cartesian Closed Category (CCC) and GHC's Core is basically lambda calculus with polymorphic type variables ([Girard's System F](https://en.wikipedia.org/wiki/System_F) with some extra sugar), if we restrict our programs to be monomorphic (no type variables) Haskell. GHC Core will be close enough to simply typed lambda calculus that we can just think of it as some CCC that can be reinterpreted like a deep embedded DSL.

This has an awesome implication: We can reinterpret the same Haskell program in multiple ways just as we can interpret deep DSLs in different ways. The DSL is Haskell code. And this approach works with all of (monomorphic) Haskell: It just requires a constraint and around ten functions in order to conform to the CCC type classes. You use all of Haskell's standard and third-party libraries. It's ridiculously powerful.

This work blew my mind. I went from thinking a deeply embedded DSLs' ability to be inspected, manipulated, and interpreted were worth the shortcomings (for one forcing your clients to learn a new language and potentially re-implement libraries). But this method is just so much nicer.

We briefly discussed how that this method could be used to transpile Haskell to other languages (like Swift!). The transpiler is just one particular CCC!
