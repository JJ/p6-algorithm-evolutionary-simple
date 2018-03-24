#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;

my $length = 64;
my $population-size = 256;
my Channel $raw .= new;
my Channel $evaluated .= new;
my Channel $channel-three = $evaluated.Supply.batch( elems => 4).Channel;
my Channel $shuffler = $raw.Supply.batch( elems => 8).Channel;
my Channel $output .= new;

$raw.send( random-chromosome($length).list ) for ^$population-size;

my $count = 0;

my $shuffle = start react whenever $shuffler -> @group {
    my @shuffled = @group.pick(*);
    $raw.send( $_ ) for @shuffled;
}

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

await $evaluation;

loop {
    if my $item = $output.poll {
	$item.say;
    } else {
	$output.close;
    }
    if $output.closed  { last };
}
