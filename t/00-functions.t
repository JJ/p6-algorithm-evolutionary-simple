#!/usr/bin/env perl6

use Test;

use Algorithm::Evolutionary::Simple;

my $length = 32;

cmp-ok( random-chromosome( $length ), "ne", random-chromosome($length), "Random chromosomes");

done-testing;
