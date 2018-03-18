#!/usr/bin/env perl6

use Test;

use Algorithm::Evolutionary::Simple;

my $length = 32;

my @χ= random-chromosome( $length );
cmp-ok(  @χ, "ne", random-chromosome($length), "Random chromosomes");

my $number-ones = reduce { $^b + $^a }, 0, |@χ;

cmp-ok( max-ones( @χ ), "==", $number-ones, "Max ones correct");
done-testing;
