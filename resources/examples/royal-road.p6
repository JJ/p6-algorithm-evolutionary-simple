#!/usr/bin/env p6

use v6;

use lib <../../lib>;
use Algorithm::Evolutionary::Simple;

use Log::Async;
use JSON::Fast;

sub json-formatter ( $m, :$fh ) {
    say $m;
    $fh.say: to-json( { msg => from-json($m<msg>),
			time => $m<when>.Str });
}

logger.send-to("royal-road-" ~ DateTime.now.Str ~ ".json", formatter => &json-formatter);

sub MAIN ( UInt :$repetitions = 30,
           UInt :$length = 64,
	   UInt :$population-size = 256,
	   UInt :$no-change-limit = 64 ) {

    my @found;
    info(to-json( { length => $length,
		    population-size => $population-size,
		    start-at => DateTime.now.Str} ));

    my $best-fitness = 0;
    for ^$repetitions {
	my @initial-population = initialize( size => $population-size,
					     genome-length => $length );
	my %fitness-of;
	
	my $population = evaluate( population => @initial-population,
				   fitness-of => %fitness-of,
				   evaluator => &royal-road );
	
	my $result = 0;
	repeat {
	    $population = generation( population => $population,
				      fitness-of => %fitness-of,
				      evaluator => &royal-road,
				      population-size => $population-size) ;
	    $result += $population-size;
	    info(to-json( { best => best-fitness($population) } ));
	    $best-fitness = $population.sort(*.value).reverse.[0].value;
	} until ( $best-fitness >= $length/4 ) or
	  no-change-during( $no-change-limit, $best-fitness );

	say "Best fitness $best-fitness";
	info(to-json( { best => best-fitness($population),
			found => ? ( $best-fitness >= $length/4 ),
			finishing-at => DateTime.now.Str} ));

	@found.push( $result );
    }
    say "Found ", @found;
}
