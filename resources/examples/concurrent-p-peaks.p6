#!/usr/bin/env perl6

use v6.d.PREVIEW;

use Algorithm::Evolutionary::Simple;
use Algorithm::Evolutionary::Fitness::P-Peaks;
use Log::Async;

sub json-formatter ( $m, :$fh ) {
  my ($chromosome,$fitness) = from-json $m<msg>;
  $fh.say: to-json( { chromosome => $chromosome,
                      fitness => $fitness,
                      time => $m<when>.Str });
}

logger.send-to("test.json", formatter => &json-formatter);

constant tournament-size = 2;

sub regular-EA ( |parameters (
               UInt :$length = 32,
               UInt :$population-size = 1024,
               UInt :$diversify-size = 8,
               UInt :$max-evaluations = 100000,
               UInt :$number-of-peaks = 100,
               UInt :$threads = 1 )
         ) {

    my Channel $raw .= new;
    my Channel $evaluated .= new;
    my Channel $channel-three = $evaluated.Supply.batch( elems => tournament-size).Channel;
    my Channel $shuffler = $raw.Supply.batch( elems => $diversify-size).Channel;

    info(to-json({ length => $length,
		   population-size => $population-size,
		   diversify-size => $diversify-size,
		   threads => $threads,
		   start => DateTime.now.sTR }
		));
    $raw.send( random-chromosome($length).list ) for ^$population-size;

    my $count = 0;
    my $end;

    my $shuffle = start react whenever $shuffler -> @group {
#    say "Mixing in ", $*THREAD.id;
      my @shuffled = @group.pick(*);
      $raw.send( $_ ) for @shuffled;
    };
    my $p-peaks = Algorithm::Evolutionary::Fitness::P-Peaks.new:
        number-of-peaks => $number-of-peaks,
        bits => $length;

    my @evaluation = ( start react whenever $raw -> $one {
        my $distance = $p-peaks.distance($one);
        my $with-fitness = $one => $distance;
        say $with-fitness;
        info( to-json([$one,$distance]) );
        $evaluated.send( $with-fitness);
    #    say $count++, " → $with-fitness";
        if $with-fitness.value == $length {
            $raw.close;
            $end = "Found" => $count;
        }
        if $count++ >= $max-evaluations {
            $raw.close;
            $end = "Found" => False;
        }
        say "Evaluating in " , $*THREAD.id;
    } ) for ^$threads;

    my $selection = (
      start react whenever $channel-three -> @tournament {
        say "Selecting in " , $*THREAD.id;
        my @ranked = @tournament.sort( { .values } ).reverse;
        $evaluated.send( $_ ) for @ranked[0..1];
        my @crossed = crossover(@ranked[0].key,@ranked[1].key);
        $raw.send( $_.list ) for @crossed.map: { mutation($^þ)};
      }
    ) for ^$threads/2;

    await @evaluation;

    loop {
      say "Parameters ==";
      say "Evaluations => $count";
      for parameters.kv -> $key, $value {
        say "$key → $value";
      };
      say "=============";
      return $end;
    }
}

sub MAIN ( UInt :$repetitions = 15,
           UInt :$length = 32,
           UInt :$population-size = 2048,
           UInt :$diversify-size = 32,
           UInt :$number-of-peaks = 100,
           UInt :$max-evaluations = 10000,
           UInt :$threads = 2) {

    my @found;
    for ^$repetitions {
      my $result = regular-EA(:$length,
                              :$population-size,
                              :$diversify-size,
                              :$max-evaluations,
                              :$number-of-peaks,
                              :$threads);
      say( $result );
      @found.push( $result );
    }
    say "Result ", @found;

}
