#!/usr/bin/perl -w

# browse the context looking for clues on how to interpret something, and base it off previous interpretations

"'Purchase the music of Seoirse O\'Dochartaigh' = (GoalFn 123414)";

[Isa [storeFn 124235135] 'Equation#3']

my $context =
  {
   [Feature 135133 [storeFn 12421421 ?X] ],
   [Feature 135135 [storeFn 14041204 ?X] "Purchase" "(GoalFn 123414) 'Purchase the music of Seoirse O\'Dochartaigh'"],
   [Feature 134535 "(GoalFn 123414)" "(GoalFn 123414) 'Purchase the music of Seoirse O\'Dochartaigh'"]
   [Activation 134535 0.135153235]
  };

WhatIs("123414 'purchase the compilation' completed");

sub WhatIs {
  # looking at something, recursively analyze it, producing a context,
  # do a proof search essentially over the context, when trying to
  # recognize something

  # what do I think this means, how should I rewrite this to be more meaningful
  # does anything stand out right away as being relevant

  # use a neural network for relevancy?
  
}

X hypothesis 

# check for related items in this history, we find 'purchase the music of ...'

# recognize that 'purchase the compilation' is an interpretation of this goal

whatis [[completed] [purchasing the compilation]]
whatis [[completed purchasing] [the compilation]]

# etc, or just use Enju

# analyze probability using cognitive science methods outlined in that example

# review context, and context stays around but fades out over time

# then determine the likely responses and ask the user to select the
# correct one, if the context, as computed by adjustable autonomy

have to have code for it to select

the context should consist of mappings, right.  purchasing -> 123414,
various concepts expressed this way

the strategy is to search out for potentially contextually relevant
clues, and then repeat until an idea is fixed upon.

reject certain hypothesises

X is unlikely because Y

->

(not (likelyBecause (hypothesis X) ())

X reminds me of this
