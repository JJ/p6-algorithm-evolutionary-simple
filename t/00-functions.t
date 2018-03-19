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

# Crossover
my @χs = crossover( @initial-population[0], @initial-population[1]);
cmp-ok( @initial-population[$_], &[!eqv], @χs[$_], "$_ chromosome xovered" ) for 0..1;

my $population = evaluate( population => @initial-population,
			   fitness-of => %fitness-of,
			   evaluator => &max-ones );
my $initial-fitness = $population.values.sum;

my $one-of-them = $population.pick();
ok( %fitness-of{$one-of-them}, "Evaluated to " ~ %fitness-of{$one-of-them});

my $best = $population.sort(*.value).reverse.[0..1].Bag;

my @pool = get-pool-roulette-wheel( $population, $population-size-2);
cmp-ok( @pool.elems, "==", $population-size-2, "Correct number of elements" );

# Reproduce
my @new-population= produce-offspring( @pool );
cmp-ok( @new-population.elems, "==", $population-size-2, "Correct number of elements in reproduction" );

$population =  Bag(evaluate( population => @new-population,
				 fitness-of => %fitness-of,
				 evaluator => &max-ones ) ∪ $best );

cmp-ok( $population.elems, "<=", $population-size, "Correct number of elements in new generation" );

my $now-fitness = $population.values.sum;

cmp-ok( $now-fitness, ">=", $initial-fitness, "Improving fitness" );

$population = generation( population => $population,
			  fitness-of => %fitness-of,
			  evaluator => &max-ones,
			  population-size => $population-size);

cmp-ok( $population.values.sum, ">=", $now-fitness, "Improving fitness" );

done-testing;
