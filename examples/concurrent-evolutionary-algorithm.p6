#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;

my $length = 64;
my $population-size = 64;
my Channel $raw .= new;
my Channel $evaluated .= new;
my Channel $channel-three = $evaluated.Supply.batch( elems => 3).Channel;
my Channel $output .= new;

$raw.send( random-chromosome($length).list ) for ^$population-size;

my $evaluation = start react whenever $raw -> $one {
    my $with-fitness = $one => max-ones($one);
    $output.send( $with-fitness );
    $evaluated.send( $with-fitness);
    say "Evaluation ", $with-fitness;
    $raw.close if $with-fitness.value == $length;
}

my $selection = start react whenever $channel-three -> @three {
    say "Tournament ", @three.sort( .values ).reverse;
    my @ranked = @three.sort( .values ).reverse;
    say "Ranked ", @ranked;
    $evaluated.send( $_ ) for @ranked[0,1];
    $raw.send( $_ ) for crossover(|@ranked[0,1]);
}

await $evaluation;
loop {
    if my $item = $output.poll {
	$item.say;
    } else {
	$output.close;
    }
    if $output.closed  { last };
}
