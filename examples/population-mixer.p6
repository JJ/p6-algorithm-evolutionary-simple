#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;

my $length = 64;
my $population-size = 64;
my $generations = 16;
my Channel $channel-one .= new;
my Channel $mixer =  $channel-one.Supply.batch( elems => 2).Channel;

my $evaluations = 0;

for ^3 {
    my @initial-population = initialize( size => $population-size,
					 genome-length => $length );
    my %fitness-of;	
    my $population = evaluate( population => @initial-population,
			       fitness-of => %fitness-of,
			       evaluator => &max-ones );
    $evaluations += $population.elems;
    $channel-one.send( $population );
}

my $single = start react whenever $channel-one -> $crew {
    say "Evolver";
    my $population = $crew.Bag;
    my $count = 0;
    my %fitness-of = $population.Hash;
    while $count++ < $generations && best-fitness($population) < $length {
	LAST {
	    if best-fitness($population) >= $length {
		say "Solution found" => $evaluations;
		$channel-one.close;
	    } else {
		say "Emitting $count";
		$channel-one.send( $population );
	    }
	};
	$population = generation( population => $population,
				  fitness-of => %fitness-of,
				  evaluator => &max-ones,
				  population-size => $population-size) ;
	$evaluations += $population.elems;
	say "Best → ", $population.sort(*.value).reverse.[0];
    }
    
}

my $pairs = start react whenever $mixer -> @pair {
    $channel-one.send(@pair.pick);
    $channel-one.send(mix( @pair[0], @pair[1], $population-size ));
}


await $single;

