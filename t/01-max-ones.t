#!/usr/bin/env perl6

use v6;

use Test;

use Algorithm::Evolutionary::Simple;

my @length = 32, * * 2  … 1024;

for @length -> $l {
    for ^$l {
	my @χ = random-chromosome( $l );
	cmp-ok( @χ, "ne", random-chromosome($l), "Random chromosome size $l");
	
	my $number-ones = reduce { $^b + $^a }, 0, |@χ;
	
	cmp-ok( max-ones( @χ ), "==", $number-ones, "Max ones correct");
    }
}

done-testing;
