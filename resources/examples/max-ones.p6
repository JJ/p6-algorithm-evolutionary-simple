#!/usr/bin/env p6

use v6;
use Algorithm::Evolutionary::Simple;


sub MAIN ( UInt :$repetitions = 30,
           UInt :$length = 64,
	   UInt :$population-size = 256 ) {

    my @found;
    for ^$repetitions {
	my @initial-population = initialize( size => $population-size,
					     genome-length => $length );
	my %fitness-of;
	
	my $population = evaluate( population => @initial-population,
				   fitness-of => %fitness-of,
				   evaluator => &max-ones );
	
	my $result = 0;
	while $population.sort(*.value).reverse.[0].value < $length {
	    $population = generation( population => $population,
				      fitness-of => %fitness-of,
				      evaluator => &max-ones,
				      population-size => $population-size) ;
	    $result += $population-size;
	    
	}
	say "Found → $population.sort(*.value).reverse.[0]";
	@found.push( $result );
    }
    say "Found ", @found;
}
