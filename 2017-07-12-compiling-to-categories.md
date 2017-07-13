## Compiling to Categories

### Conal Elliott

> Stream-of-consciousness summary by @chriseidhof

Link to the paper (and a video): http://conal.net/papers/compiling-to-categories/

The paper was a nice and easy read, for the most part. I really appreciated how well the first sections were explained. I found it interesting that you can basically take GHC Core, express it using CCC's, and that this actually works.

Another interesting thing is that this works at the source level. I've experimented with (E)DSL's, and noticed that it is very annoying indeed to not have source level access. For example, when you're trying to compile a function type, you can't "look inside" and see the body of the lambda abstraction when you're writing an EDSL. With source level transformations, you can do this (easily).

The Ok trick (section 6) was nice for adding constraints to the types involved.

Some of the applications were interesting, but I didn't try to understand everything in great detail. I have no clue what linear maps are and when to use automatic differentation or incremental computation / interval analysis.
