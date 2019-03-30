#!/usr/bin/env perl6

use v6;

use Test;

use Algorithm::Evolutionary::Simple;

my $length = 64;

my @χ= random-chromosome( $length );
cmp-ok( leading-ones( @χ ), ">=", 0, "Basic testing Leading Ones");

@χ = ( True, True, True, True, False, False, False, False, True, False, True, False );
is( leading-ones( @χ ), 4, "Testing Leading Ones");

@χ = ( False, True, True, True, False, False, False, False, True, False, True, False );
is( leading-ones( @χ ), 0, "Testing Leading Ones - no leading one");

@χ = (True xx 33);
is( leading-ones( @χ ), 33, "Testing Leading Ones - all ones");

done-testing;
