#!/usr/bin/env p6

use v6;
use Algorithm::Evolutionary::Simple;
use Algorithm::Evolutionary::Fitness::P-Peaks;


sub MAIN ( UInt :$repetitions = 30,
           UInt :$length = 128,
           UInt :$number-of-peaks = 100,
	   UInt :$population-size = 512 ) {

    my @found;
    my $p-peaks = Algorithm::Evolutionary::Fitness::P-Peaks.new: number-of-peaks => $number-of-peaks, bits => $length;
    my $length-peaks = -> @chromosome { $p-peaks.distance( @chromosome ) };
    for ^$repetitions {
	my @initial-population = initialize( size => $population-size,
					     genome-length => $length );
	my %fitness-of;

	my $population = evaluate( population => @initial-population,
				   fitness-of => %fitness-of,
				   evaluator => $length-peaks );

	my $result = 0;
        say $population.perl;
	while $population.sort(*.value).reverse.[0].value >= 0 {
	    $population = generation( population => $population,
				      fitness-of => %fitness-of,
				      evaluator => $length-peaks,
				      population-size => $population-size) ;
	    $result += $population-size;
	}
	say "Found → $population.sort(*.value).reverse.[0]";
	@found.push( $result );
    }
    say "Found ", @found;
}
