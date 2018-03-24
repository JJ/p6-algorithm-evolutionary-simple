#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;

my $length = 64;
my $population-size = 64;
my Channel $raw .= new;
my Channel $evaluated .= new;
my Channel $channel-three = $evaluated.Supply.batch( elems => 4).Channel;
my Channel $output .= new;

$raw.send( random-chromosome($length).list ) for ^$population-size;

my $count = 0;

my $evaluation = start react whenever $raw -> $one {
    my $with-fitness = $one => max-ones($one);
    $output.send( $with-fitness );
    $evaluated.send( $with-fitness);
    say $count++, " → $with-fitness";
    if $with-fitness.value == $length {
	$raw.close;
	say "Solution found";
    }
}

my $selection = start react whenever $channel-three -> @tournament {
    my @ranked = @tournament.sort( { .values } ).reverse;
    $evaluated.send( $_ ) for @ranked[0..1];
    $raw.send( $_.list ) for crossover(@ranked[0].key,@ranked[1].key);
}

await $selection;
loop {
    if my $item = $output.poll {
	$item.say;
    } else {
	$output.close;
    }
    if $output.closed  { last };
}
