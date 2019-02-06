#!/usr/bin/env perl6

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

logger.send-to("pmn-" ~ DateTime.now.Str ~ ".json", formatter => &json-formatter);

sub MAIN( UInt :$length = 64,
	  UInt :$population-size = 256,
	  UInt :$generations = 8,
	  UInt :$threads = 2
	) {

    my $initial-populations = $threads + 1;
    info(to-json( { length => $length,
		    initial-populations => $initial-populations,
		    population-size => $population-size,
		    generations => $generations,
		    threads => $threads,
		    start-at => DateTime.now.Str} ));

    my $parameters = .Capture;
    my Channel $channel-one .= new;
    my Channel $to-mix .= new;
    my Channel $mixer = $to-mix.Supply.batch( elems => 2).Channel;
    
    my $evaluations = 0;

    # Initialize three populations for the mixer
    for ^$initial-populations {
	my @initial-population = initialize( size => $population-size,
					     genome-length => $length );
	my %fitness-of;	
	my $population = evaluate( population => @initial-population,
				   fitness-of => %fitness-of,
				   evaluator => &max-ones );
	$evaluations += $population.elems;
	$channel-one.send( pack-population($population.keys) );
    }

    my @promises;
    for ^$threads {
        my $promise = start react whenever $channel-one -> $crew {
	    my @unpacked-pop = unpack-population( $crew, $length );
            my %fitness-of;
	    my $population =  evaluate( population => @unpacked-pop,
				        fitness-of => %fitness-of,
				        evaluator => &max-ones );
	    my $count = 0;
	    while $count++ < $generations && best-fitness($population) < $length {
	        LAST {
                    say "In LAST";
                    say "Best-fitness ", best-fitness($population);
		    if best-fitness($population) >= $length {
		        info(to-json( { id => $*THREAD.id,
			                best => best-fitness($population),
			                found => True,
			                finishing-at => DateTime.now.Str} ));
                
		        say "Solution found" => $evaluations;
		        $channel-one.close;
	            } else {
		        say "Emitting after $count generations in thread ", $*THREAD.id, " Best fitness ",best-fitness($population)  ;
		        info(to-json( { id => $*THREAD.id,
			                best => best-fitness($population) }));
		        $to-mix.send( pack-population($population.keys) );
	            }
	        };
	        $population = generation( population => $population,
				          fitness-of => %fitness-of,
				          evaluator => &max-ones,
				          population-size => $population-size);
	        
	        $evaluations += $population.elems;
            };
        };
        @promises.push: $promise;

    }

    my $pairs = start react whenever $mixer -> @pair {
	$channel-one.send( @pair.pick ); # To avoid getting it hanged up
	my @new-population = unpack-population(@pair[0], $length);
	my @new-population-prime = unpack-population(@pair[1], $length);
	my $new-population = mix-raw( @new-population,
				      @new-population-prime,
				      $population-size,
				      &max-ones );
	$channel-one.send( pack-population($new-population.keys));
	say "Mixing in ", $*THREAD.id;
    };

    start { sleep 800; exit };   # Just in case it gets stuck
    await @promises;
    say "Parameters ==";
    say "Evaluations => $evaluations";
    for $parameters.kv -> $key, $value {
	say "$key → $value";
    };
    say "=============";
    return $evaluations;
}


