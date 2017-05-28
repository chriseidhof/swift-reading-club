## Modules over Monads and their Algebras

### Maciej Piróg, Nicolas Wu, and Jeremy Gibbons

http://coalg.org/calco15/papers/p18-Pir%C3%B3g.pdf

> Quick write-up by Chris (stream of consciousness at bottom by bkase)

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

---

I (bkase) was in the middle of doing my summary when Chris landed this one, so I'll concat that here:

> A stream-of-consciousness summary by @bkase to make sure he absorbed the paper and discussion (with @chriseidhof)

## This Paper is Hard

_Modules over Monads_ is very heavy on Category Theory and very heavy on assumptions of knowledge of category. While we didn't fully understand the paper, through attempting to understand it we learned a lot!

Since this paper is so dense, we only were able to cover a bit of it in the meeting. So I'll just cover those bits here.

## Introduction

### Vocabulary

* Monad = I don't want to attempt to explain this because I'll surely mess it up. I bet there are good conference talks on this though.
* Endofunctor = a functor from one sort of category to itself
* Natural transformation = I think of this as a morphism across functors (like a higher-order functor)

### Definitions

Given a monad M, a right module is an endofunctor S paired with the natural transformation `mu_right : S M -> S`.

Dually a left module over M is an endofunctor L with a natural transformation `mu_left : M L -> L`.

### Takeaways

A right module looks a lot like an F-algebra from haskell land `f a -> a` and a left module looks a lot like a "coalgebra" in haskell land `a -> f a`. These algebras and coalgebras can be used to interpret functors a long with recursion schemes (if I understand correctly). There may be some dual here.

Let's skip the rest of the intro for now.

## Preliminaries

There are a bunch of conventions the paper will follow in the beginning here. That first paragraph is straight-forward -- the second one gets a bit more involved.

### Second paragraph vocab / definitions

* Eilenberg-Moore category = According to ncat, this is the category of modules over monads (aka this paper?). I can't visualize this.
* nu = unit of a monad (aka `pure : a -> m a` in Purescript)
* mu = multiplication of a monad (aka `join : m (m a) -> m a`) -- Note this is the pure/join formulation of a monad, not the pure/flatmap one that we usually use in FP

### Free monad section

This next paragraph I did not understand until talking through with Chris at the meeting. Let's try to understand it all:

* Free monad (from a programming view): `data Free f a = Continue f (Free f a) | Halt a`. John De Goes describes this nicely: A free monad is a description of a program with instructions of type `f` that might (or might not) halt with a value of `a`. The monad instance on `Free f a` can be defined for any `f : Functor`. This is called the "Free monad" because it gives you a monad for free.
* Given an Endofunctor `G : Cat -> Cat`, `G*` is the free monad generated by `G`. The paper sticks a little "(if it exists)" in there. What does this mean? Under my understanding, you can always generate a free monad from any functor (and an endofunctor is a functor).
* `emb : G -> G*` embeds the functor `G` into the free monad `G*`. An application of the `Free` type constructor.
* `[[ g ]] : G* -> T` (banana brackets g) is some monad morphism that can be composed with `emb` to create `g : G -> T` a natural transformation between `G` and `T`  (this is described in a lot more words so I'm sure I may be missing something here)
* `G*A = mu X.GX + A` sort of looks like the `Free` constructor right if `+` is taken to be the `|` in the type constructor. Not sure what an `H-algebra` is.

## Modules Defined

Here this is a precise definition of a module over a monad by showing the commutation diagrams. These make a lot of sense -- the first one says composing `S` with `mu` (the monad join) to go from `SMM -> SM` and then applying the right-module action to go `SM -> S`. Is the same as first applying the right-module action composed with `M` `SMM -> SM` and then the right module action again.

The second diagram says that composing `S` with nu (the monad's pure) to go `S -> SM` and then applyin the right-action `SM -> S` is the same as going straight from `S -> S` with the identity morphism.

Here we skipped to example 2

### Example 2

1. If `M` is a monad, `M` taken as the endofunctor `S` turns the `SM -> M` into `MM -> M`. We have an `MM -> M`: that's `mu` or `join`. That's our right-module action.

skipping down

5. Functor coproducts are like Swift enums at the type-level. You can use `Coproduct f g : Functor` for two functors `f` and `g`. To compose functors in an either/or fashion. This is how you compose interpreters with the free monad.

Then we get to some adjoint/adjunction business.

Before this paper I did not fully grok the power of adjunctions, but I think I get it now.

First of all, what is an adjunction? From a programming perspective: It's a pair of functions `f: A -> B` and `g: B -> A` where doing `f`  is the same as doing `f`, `g`, `f`. It's a weaker form of "self-inverse" which would be `f . g === id`. People tend to use `curry` and `uncurry` as an example of an adjunction, but they're also self-inverses so I think it's misleading. Here's another example that isn't. Let `f : Array<Int> -> SortedMap<Int, Int>`, `g : SortedMap<Int, Int> -> Array<Int>` where `f` just sticks all the elements into a sorted map using the indicies of the array as keys. `g` forgets the keys of some sorted map and then sticks the values back in the array in sorted order. It's important we have a sorted map here (excersize: figure out why). If I give you an arbitrary array you can give me a map. And if I take this map and then run it through `g` then `f` gagain I get the same map. Interestingly, you can give me a map with more interesting keys like `{ 1: 1, 10: 2, 100: 3 }` and if I run it through `g` then `f` I don't get the same map back. We forgot the keys. For this reason `g` is usually called the forget function and `f` is called the free function because we get some structure for free (from something of a weaker structure).

Why do we care? Well it turns out adjunctions (this pair of functions) induce a monad and comonad! And not only that, but every single monad we use and every comonad we use is uniquely generated by some `f` and `g` in an adjunction. And you can implement this in sufficiently advanced programming languages. See the artifacts from this meeting. There is a nice series of videos [Eugenia Cheng (of How to Bake a Pi and Beyond Infinity fame) on Adjunctions](https://www.youtube.com/watch?v=loOJxIOmShE&list=PL54B49729E5102248) and [a talk by Runar on Adjunctions in Everday Life](https://www.youtube.com/watch?v=f-kdpR0BPqo)

Now (6) sort of makes sense since `UF` is a monad because two adjunctions induce a monad the specifics don't quite make sense to me. Same with (7) but with comonads.

### Example 3

The `A x - turnstile (-) ^ A` is the categorical type definition for `curry`. The dash is a the type parameter, so we turn `A x -` aka `(a, ?)` a tuple into `A -> -` a function. The turnstile says "left-adjoint" to. Going the other way we get `uncurry`. The adjunction with `curry` and `uncurry` make the state monad -- a tuple with state and some value and a way to get and set it.

Let's jump to the end of that paragraph. This quote sticks out: "In other words, [the left adjoint] is a morphism that 'executes' the statefule computation". Pretty cool.

The next part talks about the Reader monad (there's some way to get the current state) and it's comonadic dual (it's adjoint) the environment comonad (which is kind of like a writer) and it looks like the module-action removes the ability to read the state?

### Example 4

This is a funny part to me because it's when I realized that understanding this paper entirely was hopeless with my current understanding of the universe. I understood just enough to know that I didn't understand what was going on. When we talked about it in the meeting I understood it a _bit_ more.

Here is the snippet in it's entirety:

> For all n >= 1, the Set functor of lists with at least n elements is a module of the non-empty list monad (the free semigroup monad).

Ok let's break this down.

`For all n >= 1` makes sense.

`The Set functor of lists with at least n elements`. What? I can't visualize this at all, and yet I think I understand all the words individually.

`is a module` (this paper)

`of the non-empty list monad`. What is this? The list monad lets you capture non-deterministic choice in computations. You use the list monad to solve things like the N-Queens problem (the list monad does the backtracking for you). But what does the non-empty list monad do?

`(the free semigroup monad)`. Okay so this I know a little bit about. First of all, the "free H" for some algebraic structure H is some structure that lets you interpret H under some different H later. Let's be concrete. One free monoid is a simple list. The append is list concat. The empty is `[]`. You can later interpret any monoid (let's say addition on ints) over a list of ints, by folding the append over the list. A semigroup is a weaker monoid. A semigroup just requires the append and not the empty element. So a free semigroup is represented by a non-empty list. You can't use a list because how would you interpret the `[]` given a semigroup? You have no empty element! Now here is my question what does it mean to lift this notion of a `free semigroup` or `free list` onto a monad? I have no idea.

This is where I lost hope when reading. It's also where we essentially ran out of time at the meeting.

## Summary and Future work

Briefly, we talked about this section (page 297 of the paper towards the bottom) because it is relevant to programming. It mentions streaming I/O libraries -- this I think is covered by the notion of a `Cofree` which I think is captured somewhere in the depths of this paper. To learn more about cofree streams watch [this talk by John De Goes](https://www.youtube.com/watch?v=R_nYc4FItcI).
And algebraic effects are monads (see Eff monad in Purescript or Scala) or last paper. And finally in the last paragraph before the "Example", the author mentions that right-modules represent functions that run the computations in some context. In Example 3, the context was global state (the state monad), but it can work for other contexts. This reminds me in general in the idea of comonads as interpreters of programs. Remember a free monad describes a program.

## Artifacts

@chriseidhof [implemented a portion of this in Idris](https://gist.github.com/chriseidhof/0671f5a907042c4502e3b82bfce05a9a)
@CodaFi was unable to make it to the meeting, but he [formalized some of the paper in Agda](https://gist.github.com/CodaFi/661585c1ae2b5bc99e1168912d62d5a5) and sent it over email. Thanks!
