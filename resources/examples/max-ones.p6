#!/usr/bin/env raku

use v6;

use lib <lib ../../lib>;
use Algorithm::Evolutionary::Simple;

use Log::Async;
use JSON::Fast;

sub json-formatter ( $m, :$fh ) {
    say $m;
    $fh.say: to-json( { msg => from-json($m<msg>),
			time => $m<when>.Str });
}

logger.send-to("max-ones-" ~ DateTime.now.Str ~ ".json", formatter => &json-formatter);

sub MAIN ( UInt :$repetitions = 30,
           UInt :$length = 64,
	   UInt :$population-size = 256 ) {

    my @found;
    info(to-json( { length => $length,
		    population-size => $population-size,
		    start-at => DateTime.now.Str} ));

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
	    info(to-json( { best => best-fitness($population) } ));
	}
	info(to-json( { best => best-fitness($population),
			found => True,
			finishing-at => DateTime.now.Str} ));

	@found.push( $result );
    }
    say "Found ", @found;
}
