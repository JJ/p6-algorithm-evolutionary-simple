#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;
use Log::Async;

constant tournament-size = 2;


sub json-formatter ( $m, :$fh ) {
    say $m;
    $fh.say: to-json( { msg => from-json($m<msg>),
			time => $m<when>.Str });
}

logger.send-to("test.json", formatter => &json-formatter);

sub regular-EA ( |parameters (
		       UInt :$length = 64,
		       UInt :$population-size = 256,
		       UInt :$diversify-size = 8,
		       UInt :$max-evaluations = 10000,
                       UInt :$threads = 1 )
		 ) {
    
    my Channel $raw .= new;
    my Channel $evaluated .= new;
    my Channel $channel-three = $evaluated.Supply.batch( elems => tournament-size).Channel;
    my Channel $shuffler = $raw.Supply.batch( elems => $diversify-size).Channel;

    $raw.send( random-chromosome($length).list ) for ^$population-size;
    
    my $count = 0;
    my $end;
    
    my $shuffle = start react whenever $shuffler -> @group {
#	say "Mixing in ", $*THREAD.id;
	my @shuffled = @group.pick(*);
	$raw.send( $_ ) for @shuffled;
    };
    
    my @evaluation = ( start react whenever $raw -> $one {
	my $with-fitness = $one => max-ones($one);
	info( to-json( $with-fitness ));
	$evaluated.send( $with-fitness);
#	say $count++, " → $with-fitness";
	if $with-fitness.value == $length {
	    $raw.close;
	    $end = "Found" => $count;
	}
	if $count++ >= $max-evaluations {
	    $raw.close;
	    $end = "Found" => False;
	}
#	say "Evaluating in " , $*THREAD.id;
    } ) for ^$threads;
    
    my $selection = ( start react whenever $channel-three -> @tournament {
#	say "Selecting in " , $*THREAD.id;
	my @ranked = @tournament.sort( { .values } ).reverse;
	$evaluated.send( $_ ) for @ranked[0..1];
	my @crossed = crossover(@ranked[0].key,@ranked[1].key);
	$raw.send( $_.list ) for @crossed.map: { mutation($^þ)};
    } ) for ^($threads/2);
    
    await @evaluation;
    
    say "Parameters ==";
    for parameters.kv -> $key, $value {
	say "$key → $value";
    };
    say "=============";
    return $end;
}

sub MAIN ( UInt :$repetitions = 15,
           UInt :$length = 64,
	   UInt :$population-size = 256,
	   UInt :$diversify-size = 8,
	   UInt :$max-evaluations = 10000,
           UInt :$threads = 2) {

    my @found;
    for ^$repetitions {
	my $result = regular-EA( length => $length,
				 population-size => $population-size,
				 diversify-size => $diversify-size,
				 max-evaluations => $max-evaluations,
                                 threads => $threads);
	say( $result );
	@found.push( $result );
    }
    say "Result ", @found;

}
