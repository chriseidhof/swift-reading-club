## Modules over Monads and their Algebras

### Maciej Piróg, Nicolas Wu, and Jeremy Gibbons

http://coalg.org/calco15/papers/p18-Pir%C3%B3g.pdf

> Quick write-up by Chris

In summary, I don't feel I understood the paper. The first time reading, I didn't understand anything. After a few times, I understood more bits and pieces, and looking into adjoints really helped. Here are some random bits I think I understood:

- `mu-> and mu<-` look like an evaluation function (an algebra?) lifted to the functor domain.
- `emb` lifts a functor into a free monad
- Given `g: G -> T`, `[[g]]` evaluates the free monad of G (called G*) into a T
- The free monad definition looks a lot like `G*A = muX.GX+A`:
      data Free f a where
        Free : f (Free f a) -> Free f a
        Pure : a -> Free f a
  The muX.GX seems to be the `Free` constructor, and the `A` the `Pure`?

- The most interesting thing I learned (which I didn't know before reading this paper) is that, given two adjoint functors F and G, that GF is a monad, and FG is a comonad. The adjoint provides a unit (which is the monad's return) and a counit (which is the comonad's extract).

Some reading material on this (for Haskellers):

- [From Adjunctions to Monads](http://www.stephendiehl.com/posts/adjunctions.html)
- [What are the adjoint functor pairs corresponding to common monads in Haskell?](https://stackoverflow.com/questions/13937289/what-are-the-adjoint-functor-pairs-corresponding-to-common-monads-in-haskell)

I've experimented a bit with this in Idris, and [here](https://gist.github.com/chriseidhof/0671f5a907042c4502e3b82bfce05a9a) are the results.

I did not really understand all that much of the rest of the paper.

