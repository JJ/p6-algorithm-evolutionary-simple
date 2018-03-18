#!/usr/bin/env perl6

use Test;

use Algorithm::Evolutionary::Simple;

my $length = 32;

my @χ= random-chromosome( $length );
cmp-ok(  @χ, "ne", random-chromosome($length), "Random chromosomes");

my $number-ones = reduce { $^b + $^a }, 0, |@χ;

cmp-ok( max-ones( @χ ), "==", $number-ones, "Max ones correct");


my $population-size = 32;
my @initial-population;
my %fitness-of;
for 1..$population-size -> $p {
    @initial-population.push: random-chromosome( $length );
}

my $population = evaluate( population => @initial-population,
			   fitness-of => %fitness-of );

my $one-of-them = $population.pick();
ok( %fitness-of{$one-of-them}, "Evaluated to " ~ %fitness-of{$one-of-them});

dd $population;
my @new-population = get-pool-roulette-wheel( $population, $population-size);
dd @new-population;

done-testing;
