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

logger.send-to("pmf-" ~ DateTime.now.Str ~ ".json", formatter => &json-formatter);

sub MAIN( UInt :$length = 64,
	  UInt :$population-size = 256,
	  UInt :$generations = 8,
	  UInt :$threads = 2
	) {

    my $parameters = .Capture;    
    my Channel $channel-one .= new;
    my Channel $to-mix .= new;
    my Channel $mixer = $to-mix.Supply.batch( elems => 2).Channel;
    my $evaluations = 0;

    my $initial-populations = $threads * 2;
    info(to-json( { length => $length,
		    population-size => $population-size,
                    initial-populations => $initial-populations,
		    generations => $generations,
		    threads => $threads,
		    start-at => DateTime.now.Str} ));

    # Initialize three populations for the mixer
    for ^$initial-populations {
	$channel-one.send( 1.rand xx $length );
    }

    my @promises;
    for ^$threads {
        my $promise = start react whenever $channel-one -> @crew {
            my %fitness-of;
	    my @unpacked-pop = generate-by-frequencies( $population-size, @crew );
	    my $population = evaluate( population => @unpacked-pop,
                                       fitness-of => %fitness-of,
				       evaluator => &max-ones);
	    my $count = 0;
	    while $count++ < $generations && best-fitness($population) < $length {
	        LAST {
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
		        $to-mix.send( frequencies-best($population, 8) );
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
        $to-mix.send( @pair.pick ); # To avoid getting it hanged up
	my @new-population =  crossover-frequencies( @pair[0], @pair[1] );
	$channel-one.send( @new-population);
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
}
