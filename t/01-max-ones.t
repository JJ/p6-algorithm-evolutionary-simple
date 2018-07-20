#!/usr/bin/env perl6

use v6;

use Test;

use Algorithm::Evolutionary::Simple;

my @length = 32, * * 2  … 1024;

for @length -> $l {
    my @zeros = False xx $l;
    cmp-ok( max-ones( @zeros ), "==", 0, "False-ed chromosome evaluated");
    @zeros = 0 xx $l;
    cmp-ok( max-ones( @zeros ), "==", 0, "0-ed chromosome evaluated");
    my @ones = True xx $l;
    cmp-ok( max-ones( @ones ), "==", 0, "True-ed chromosome evaluated");
    @zeros = 1 xx $l;
    cmp-ok( max-ones( @ones ), "==", 0, "1-ed chromosome evaluated");

    for ^$l {
	my @χ = random-chromosome( $l );
	cmp-ok( @χ, "ne", random-chromosome($l), "Random chromosome size $l");
	
	my $number-ones = reduce { $^b + $^a }, 0, |@χ;
	
	cmp-ok( max-ones( @χ ), "==", $number-ones, "Max ones correct");
    }
}

done-testing;
