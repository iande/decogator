##Preamble

Decotagor is my own predictable adherence to unwritten rule of implementing a Ruby
AOP library, articulated by Avdi Grimm.  The motivation for writing this
library came from [one of my rambling thoughts](http://github.com/iande/blathering/blob/master/aspect_advice.md),
and it isn't necessarily meant to be useful to anyone.  Writing this has proven
to be a fun exercise in meta-programming, applying combinatory logic, deepening
my understanding of the Ruby object model, and reinforcing my love of Ruby's
expressiveness.  While the code was written by me, Reg Braithwaite's
[take on advice in Ruby](http://github.com/raganwald/homoiconic/blob/master/2008-11-07/before_and_after_advice.rb)
definitely influenced some of my approaches -- particularly when it came to
understanding bugs that my approach initially introduced.

##Delegation

Delegation allows method calls to one object to be forwarded to another.  The
Decogator module creates proxy methods on the target object that merely send
the call along to the specified method (public, private or protected) or instance
variable specified.  For example:

    delegates :each, :to => :@an_array
    delegates :to_i, :to => :a_method
    delegates :'[]', :to => :a_private_method
    include Enumerable

    def a_method
      3.14195
    end

    private
    def a_private_method
      @an_array
    end

Calling `obj.to_i` will send the `to_i` message to `3.14195`, yielding a result
of `3`.  Calling `obj[3]` will return the same value as `@an_array[3]`, and a
call of `obj.map { ... }` will have the same effect as if the `map` function
were called on `@an_array`.  The last example works because in delegating `each`
to `@an_array`, a method named `each` was created, and the `Enumerable` module
will provide `map` and friends to any object, provided the `each` method exists.

##Decoration with Advice

Decogator provides four kinds of advice for decorating methods: before, after,
around, and tap.  Decorating a method results in calls to that method being
filtered by a chain of advice.  Depending upon the type of advice given, this
filtering can happen before, after, or around the underlying method's execution.

###Before

Before advice is called before the underlying method is invoked, providing a
means of doing something else first, including modifying incoming parameters
before they are passed to the underlying method.  Before advice takes the
form of:

    before :a_method, :call => :do_first

    def do_first; ...; end

One of two behaviors will be produced depending upon whether or not the before
method, `do_first` in this case, accepts parameters.  If the before method does
not accept parameters, it is called with no arguments and its return value is
ignored.  Processessing of the before chain continues with the unmodified parameters.
For instance:

    def some_method(a, b)
      a * b
    end

    before :some_method, :call => :do_first
    def do_first
      puts "Doing something before some_method is invoked"
    end

In this case, a call of `obj.some_method(3,2)` yields a result of 6, as expected.

If the before method does accept parameters, then all the arguments that the
underlying method was called with will be passed into the before method.  It is
the before method's responsibility to return the parameters, with or without
modification, so that processing can continue.
For instance:

    def some_method(a, b)
      a * b
    end

    def meth_taking_block(a, &b)
      a * yield
    end

    before :some_method, :call => :do_first
    def do_first(a, b)
      [ [a+b, a-b] ]
    end

    before :method_taking_block, :call => :replace_block
    def replace_block(a, &b)
      [ [a], lambda { b.call * 2 } ]
    end

In this example, we see that the before methods both return an array, which will
be used as the parameters for the next call in the before advice chain, until
ultimately they are supplied as arguments to the underlying method call.  Ergo,
a call of `obj.some_method(5,2)` produces the result 21, rather than 6, and a call of
`obj.meth_taking_block(4) { 2 }` produces 16, instead of 8.

###After

After methods is called after the underlying method has been invoked, providing
a means to do something else when the method has completed.  After advice has
the ability to modify the underlying method's return value.  Such advice takes
the form of:

    after :a_method, :call => :do_last

    def do_last; ...; end

As in the case of before advice, after advice will have one of two behaviors,
depending upon how the after method is implemented.  If the after method accepts
no parameters, it is invoked and its return value is discarded.  If it accepts
a parameter, it will be supplied with the return value of the underlying method
and the return value of the after method will be used in its place.  For instance:

    def some_method(a, b)
      a * b
    end

    after :some_method, :do_last
    def do_last(r)
      r + 1
    end

In this case, a call to `obj.some_method(3, 2)` will result in 7, rather than
6, because `do_last` takes the original return value and adds one to it.  Had
the declaration of `do_last` omitted the parameter `r`, our call would have
produced 6 as expected.

###Around and Tap

Around and tap advice both get applied around the underlying method.  This means
that for processing to continue, the advice method must explicitly state when to
continue the call.  Around advice has the ability to modify parameters as well
as alter return values of the methods it wraps.  The mechanism around advice uses
to modify incoming parameters is considerably different from the one employed by
before advice.  Altering the return value of the underlying method is done
in the same fashion as it is with after advice, the return value of the advice
replaces the return value of the underlying method.  An example of using pieces
of around advice follow:

    def some_method(a, b)
      a * b
    end

    def other_method(a, b)
      a + b
    end

    around :some_method, :call => :do_around
    def do_around
      yield + 3
    end

    around :other_method, :call => :around_other
    def around_other(block, a, b)
      yield(a + 2, b) * 3
    end

In this example, a call to `obj.some_method(3,2)` results in 9, because the
given around advice added 3 to the original result of 6.  Also, a call
to `obj.other_method(1, 2)` produces 15, rather than 3.  A method that implements
around advice that declares no parameters can `yield` its way along the advice
chain.  It can also `yield(a, b)` to change the parameters received by the
next link in the chain.  If an implementor of around advice wishes to have
access to the incoming parameters, it declares a parameter list that matches
the underlying method, with the exception of an additional leading parameter.
This can be seen in the declaration of `around_other` in the above example.
The leading parameter is the block passed to the original call, if any, as
an object.  This kind of around advice implementation still uses `yield` to
move itself along the advice chain.

Tap advice is a special case of around advice that can neither
modify the incoming parameters, nor alter the return value, of the underlying
method.  Its name is taken from the Ruby `tap` method and is meant to be used
when the decorator does not wish to interfere with normal processing.  This
effect can be achieved through specific crafting of around advice, but using
`tap` prevents an author from crafting the around advice improperly.
Additionally, use of the name `tap` clearly signals to other authors that the
decoration is not meant to change the observed behavior of the method.  Tap
methods are always called with only a block, they have no access to the JoinPoint
object.  Below is an example that shows the usage of tap advice, as well as
around advice that behaves like tap advice:

    def some_method(a, b)
      a * b
    end

    tap :some_method, :call => :do_tapped
    def do_tapped
      puts "Before some_method is called!"
      yield
      puts "After some_method is called!"
    end

    def other_method(a, b)
      a + b
    end

    around :other_method, :call => :tap_other
    def tap_other
      puts "Before other_method is called!"
      r = yield
      puts "After other_method is called!"
      # Must explicitly evaluate to r, otherwise
      # we are not 'tapping'
      r
    end

In this example, calls to both `some_method` and `other_method` produce
some useless output, but do not otherwise modify the behavior of the calls.
The need to assign and explicitly return the value yielded by the underlying
method makes using around advice as tap advice both cumbersome and unclear that
we are not modifying method behaviors.  Regardless of the changes I make
to the around advice, tap advice will always be present in this library and
behave just as it is seen here.

###Stacking Advice

A method can have multiple pieces and types of advice decorating it.  Advice
stacks as seen below, where `B_x` denotes the before advice given in the `x`th
call to `before`, the same is true of around/tap and after advice, represented
by `R` and `A` respectively.

      B_i
       .
       .
      B_2
      B_1
      R_j (before)
       .
       .
      R_2 (before)
      R_1 (before)
       M
      R_1 (after)
      R_2 (after)
       .
       .
      R_j (after)
      A_1
      A_2
       .
       .
      A_k

The (before) and (after) labels following the around advice, `R_x`, indicate
the portion that occurs before the advice yields and after the yield completes,
respectively.
Advice stacks from the method, outwards.  The first declared piece of before
advice is evaluated immediately before the last declared piece of around advice.
Similarly, the first piece of after advice is called immediately after the last
piece of around advice completes.  At this time, there is no way to insert a
piece of advice into a particular position within the advice chain, though that
may eventually change.

##Known Issues

1. It's going to be slower than using inheritance. Each time a decorated method
   is invoked, the decorator chain is bound and evaluated.  There is certainly
   room for improvement, but optimizing would be premature at this time.
1. While extending a class with a decorated method, overriding that method in
   the base class, decorating the override, and calling super in the overridden
   method all works as expected now, it is still possible to break things.  If
   a class with decorated methods is renamed through the use of `const_set`, you
   can expect breakage.  Guarding against this scenario is not something I intend
   to bother with, unless an incredibly trivial solution presents itself to me.
   However, as it is a case where things can go awry, I'll make note of it here.
1. Before and after advice implemented with blocks cannot receive the block supplied
   to the original call, assuming any was given.  In short, do not implement advice
   with blocks when the underlying method depending upon being called with a block,
   as such advice will effectively remove the block originally supplied.  In the
   future, I will resolve this issue by changing how the before advice is
   accumulated into the parameters to pass into the rest of the advice chain,
   re-supplying any passed in block when invoking before advice defined with a
   block.  Boy, that's convoluted.
1. Before and after advice can now be implemented with a block.  However, around
   around and tap advice cannot.  The convention of yielding through the around/tap
   chain makes implementing such advice with a block impossible without severe
   modification to the way advice is invoked.

##To-Do

1. Specs, specs, specs!
1. RDocs.  Documentation should really start taking a higher priority in my
   life.
1. Treat before advice implemented as a block a bit differently during parameter
   accumulation on account of such advice's inability to interact with any
   blocks supplied to the original call.
1. Refactor!
