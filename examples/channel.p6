#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;

my $length = 32;
my Channel $channel-pop .= new;
my Channel $channel-two .= new;

my $count = 0;
my $work = start {
    say "Count → $count\n\n";
    $channel-two.send: $_ for $channel-pop.List.rotor(2);
    $channel-pop.close if $count++ >= 100;
    CATCH {
	default {
	    $channel-two.fail($_)
	}
    }
};

my $single = start {
    react  {
        whenever $channel-pop -> $item {
            say "via Channel 1:", max-ones($item);
        }
    }
}

my $pairs = start {
    react  {
        whenever $channel-two -> @pair {
	    my @new-chromosome = crossover( @pair[0], @pair[1] );
	    say "In Channel 2: ", @new-chromosome;
	    $channel-pop.send( @new-chromosome[0]);
	    $channel-pop.send( @new-chromosome[1]);
        }
    }
}

$channel-pop.send( random-chromosome($length) ) for ^10;

await $single;
await $pairs;
