#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;

my $length = 64;
my $population-size = 64;
my $generations = 8;
my Channel $channel-one .= new;
my Channel $mixer =  $channel-one.Supply.batch( elems => 2).Channel;

my $single = start react whenever $channel-one -> $crew {
    say "via Channel 1:";
    my $count = 0;
    my $population = $crew.Bag;
    my %fitness-of = $population.Hash;
    while $count++ < $generations && best-fitness($population) < $length {
	LAST {
	    if best-fitness($population) >= $length {
		say "Solution found";
		$channel-one.close;
	    } else {
		say "Emitting";
		$channel-one.send( $population );
	    }
	};
	$population = generation( population => $population,
				  fitness-of => %fitness-of,
				  evaluator => &max-ones,
				  population-size => $population-size) ;
	
	say "Best → ", $population.sort(*.value).reverse.[0];
    }
    
}

my $pairs = start react whenever $mixer -> @pair {
    say "In Channel 2: ";
    $channel-one.send(mix( @pair[0], @pair[1], $population-size ));
}

await (^3).map: -> $r {
    start {
	sleep $r/1000.0;
	my @initial-population = initialize( size => $population-size,
					     genome-length => $length );
	my %fitness-of;	
	my $population = evaluate( population => @initial-population,
				   fitness-of => %fitness-of,
				   evaluator => &max-ones );
        $channel-one.send( $population );
    }
}

await $single;
await $pairs;
