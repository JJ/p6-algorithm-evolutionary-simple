#!/usr/bin/env perl6

# Examples of using auto-threading with a heavy function, P-Peaks.

use v6;
use Algorithm::Evolutionary::Simple;
use Algorithm::Evolutionary::Fitness::P-Peaks;


sub MAIN ( UInt :$repetitions = 15,
           UInt :$length = 32,
           UInt :$number-of-peaks = 100,
	   UInt :$population-size = 4096 ) {

    my @found;
    my $p-peaks = Algorithm::Evolutionary::Fitness::P-Peaks.new: number-of-peaks => $number-of-peaks, bits => $length;
    my $length-peaks = -> @chromosome { $p-peaks.distance( @chromosome ) };
    for ^$repetitions {
	my @initial-population = initialize( size => $population-size,
					     genome-length => $length );
	my %fitness-of;

	my $population = evaluate( population => @initial-population,
				   fitness-of => %fitness-of,
				   evaluator => $length-peaks,
                                   auto-t => True );

	my $result = 0;
	while $population.sort(*.value).reverse.[0].value < 1 {
            say "Best  → ", $population.sort(*.value).reverse.[0].value;
	    $population = generation( population => $population,
				      fitness-of => %fitness-of,
				      evaluator => $length-peaks,
				      population-size => $population-size,
                                      auto-t => True ) ;
	    $result += $population-size;
	}
	say "Found → $population.sort(*.value).reverse.[0]";
	@found.push( $result );
    }
    say "Found ", @found;
}
