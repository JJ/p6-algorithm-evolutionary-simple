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
    cmp-ok( @initial-population[$p-1], "==", mutation( @initial-population[$p-1] ), "Mutation works" );
}

say @initial-population[0], @initial-population[1];
my @χs = crossover( @initial-population[0], @initial-population[1]);
say @χs;						   
my $population = evaluate( population => @initial-population,
			   fitness-of => %fitness-of );

say "Values ", $population.values;
my $initial-fitness = $population.values.sum;

my $one-of-them = $population.pick();
ok( %fitness-of{$one-of-them}, "Evaluated to " ~ %fitness-of{$one-of-them});

my @new-population = get-pool-roulette-wheel( $population, $population-size);
cmp-ok( @new-population.elems, "==", $population-size, "Correct number of elements" );


$population =  evaluate( population => @new-population,
			 fitness-of => %fitness-of );

say "Initial fitness " ~ $initial-fitness ~ " now " ~ $population.values.sum;

say "Values ", $population.values;
cmp-ok( $population.values.sum, ">=", $initial-fitness, "Improving fitness" );
done-testing;
