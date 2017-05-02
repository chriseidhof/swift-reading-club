## Programing with Alebraic Effects and Handlers

### Andrej Bauer and Matija Pretnar 2012

> A stream-of-consciousness summary by @bkase to make sure he absorbed the paper and discussion

Link to the paper [https://arxiv.org/pdf/1203.1539.pdf](https://arxiv.org/pdf/1203.1539.pdf)

## Eff language

### Types and Expressions

The Eff programming language is described in the paper as an example of the eff programming model. This language has a distinct notion of *expressions* (inert from effects) and *computations* (effectful computation).

Eff is essentially a simple ML (products, sums, functions) with the addition of effects and handlers. An effect has a *row* of operations (in the beginning indexed via the subscript `i`, but later indexed by names) that take arbitrary input and output types `A_i -> B_i`. A handler provides an *interpretation* of the effects used in some computation.

There is a notion of creating a resource `new E` that will generate a *fresh instance* of an effect `E`: think "mutable state" or "opening a file".

### Type checking

Most of the Type checking rules are straightforward if you're familiar with reading such rules. See [@CodaFi 's Functional Swift talk](https://www.youtube.com/watch?v=IbjoA5xVUq0) if you want to get a simple introduction.
Even the handler intro-rule and effect instance intro-rules, while large, can be understood by breaking them down one piece at a time.

### Evaluation rules (Denotational Semantics)

This section really confused me when I was first reading (and re-reading) the paper. During discussion today with @chriseidhof it finally made sense:

My programming language theory knowledge is from Bob Harper's 15-312 "Introduction to Programming Languages" class at Carnegie Mellon University and his _Practical Foundations for Programming Languages_ book (this book is fantastic by the way -- [you can see a preview on Harper's site](https://www.cs.cmu.edu/~rwh/pfpl/2nded.pdf)). In this book, evaluation rules are described with similar syntax to type checking rules.

This paper describes the evaluation rules in a completely different syntax. This paper cites [John Reynolds' technical report, "The Meaning of Types From Intrinsic to Extrinsic Semantics"](http://repository.cmu.edu/cgi/viewcontent.cgi?article=2290&context=compsci) which uses a similar formalism.

Even though I don't have a proper understanding of this syntax, @chriseidhof and I interpreted it in the following way (which may help you -- perhaps a new reader -- understand):

`V` is the domain of values and `R` is the domain of results *in our program world*.

In the first few diagrams with the large black horizontal arrows:

* `ι_x` means lift a value from math of type `x` into some domain in our program
* `ρ_x` means extract a value from math of type `x` from some domain in our program

So for example:

I interpret the `Z_bottom <---> V` diagram on the top-left to mean: We can lift integers from math world into our programming worled by sticking them in `V`. And we can ascribe the math meaning of "integer" (from the set `Z`) to values from the domain `V`.

And I believe the bottom left diagram `R^V <---> V` is written in this way to denote the correspondence of math "functions" to our domain `V`. I figured this because there is an interesting type-algebra operation you can perform where the total possible functions that can be written from `a -> b` is precisely equal to `t(b)^t(a)` aka the total number of values of the result type to the power of the total number of values of the input type. Functions are exponentials. See [@chris-taylor 's blogpost on Algebra of Algebraic Data Types](http://chris-taylor.github.io/blog/2013/02/10/the-algebra-of-algebraic-data-types/) for more information.
(also since the `ι` and `ρ` are indexed by the function `->`)

The other diagrams later on this page just show how we can life `V` into a sum of `V` and all the other stuff that makes the effects work out.

On the next page we can ascribe rules for our to extract values from some context `η` refering to the `ι`ing rules.
The rules get more complex but you can always break them down into pieces and apply the sub rules.

### Implementation and Examples

The implementation of the eff language takes some syntactic liberties (not having to denote the computation differently from an expression).

An interesting bit about effect handlers is that they get "the rest of the computation" packaged up for free as a continuation `k`. This power makes this paper hard to implement in user-land (i.e. without mucking with the language implementation) in Swift.

You can see how this power is used to implement various effects:

* Nondeterministic choice can be interpreted to compute all possible choices (calls continuation many times)
* Exception raising can be interpreted as never calling the continuation

Another interesting bit that I grappled onto here was this notion that effects are interpreted later by handlers. The behavior of the effect is decoupled from it's definition and use. Look at the Nondeterministic Choice example to see what I mean here. This reminds me of the [Free Monad](http://degoes.net/articles/modern-fp).

Advantages of this decoupling:
* You can interpret your effects one way in production and another in testing.
* You can switch libraries easily without rewriting your code or your dependencies.

This is certainly an interesting alternative (non-monadic) way to think about effects. Interestingly, Purescript's effect system also uses a row of operations but is wrapped up in a monad (the `Eff` monad).

## Gotchas

While effects in isolation can be reasoned about algebraically, they do not compose nicely. The paper admits this with this quote: "The moral of the story is that even though effects combine easily, their combinations are not always easily understood".
This is interesting. Monads do not compose either.

## Eff-like effects in Swift

@chriseidhof and I both implemented something similar to the usage in the examples section of the paper. Unfortunately, since the semantics rely on the existence of a continuation, using this framework for programming in Swift relies on (1) programming with callbacks everywhere (explicit continuations) and (2) getting the result via callback even for synchronous effects.

Mine: https://gist.github.com/bkase/064f3a72eb4d6a11d8e723edc6b6157d
@chriseidhof: https://gist.github.com/chriseidhof/c3918e870efae00eb3c1565ff6a9f289

