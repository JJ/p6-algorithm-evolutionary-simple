#!/usr/bin/env p6

# Examples of using auto-threading with a heavy function, P-Peaks.

use v6;
use Algorithm::Evolutionary::Simple;
use Algorithm::Evolutionary::Fitness::P-Peaks;


sub MAIN ( UInt :$repetitions = 30,
           UInt :$length = 32,
           UInt :$number-of-peaks = 100,
	   UInt :$population-size = 1024 ) {

    my $p-peaks = Algorithm::Evolutionary::Fitness::P-Peaks.new: number-of-peaks => $number-of-peaks, bits => $length;
    my $length-peaks = -> @chromosome { $p-peaks.distance( @chromosome ) };
    my $start = now;
    for ^$repetitions {
	my @initial-population = initialize( size => $population-size,
					     genome-length => $length );
	my %fitness-of;

	my $population = evaluate( population => @initial-population,
				   fitness-of => %fitness-of,
				   evaluator => $length-peaks );
    }
    say "Time → ", now - $start;
}
