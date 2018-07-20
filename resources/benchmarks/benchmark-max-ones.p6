#!/usr/bin/env p6

use v6;
use Algorithm::Evolutionary::Simple;


sub MAIN ( UInt :$length is copy = 32,
	   UInt :$how-many = 10000 ) {

    while $length <= 2048 {
	my $start = now;
	for 1..$how-many  {
	    my @ones = Bool.roll xx $length ;
	    my $maxones = max-ones(@ones);
	}
	say "perl6-BitVector, $length, ",now - $start;
	$length = $length*2;
    }

}
