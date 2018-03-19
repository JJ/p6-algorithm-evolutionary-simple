#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;

my $length = 32;
my $supplier = Supplier.new;
my $supply   = $supplier.Supply;
my $channel-one = $supply.Channel;
my $pairs-supply = $supply.batch( elems => 2 );
my $channel-two = $pairs-supply.Channel;

my $single = start {
    react  {
        whenever $channel-one -> $item {
            say "via Channel 1:", max-ones($item);
        }
    }
}

my $pairs = start {
    react  {
        whenever $channel-two -> @pair {
	    my @new-chromosome = crossover( @pair[0], @pair[1] );
	    say "In Channel 2: ", @new-chromosome;
	    $channel-one.send( @new-chromosome[0]);
	    $channel-one.send( @new-chromosome[1]);
        }
    }
}

await (^10).map: -> $r {
    start {
	sleep $r/100.0;
        $supplier.emit( random-chromosome($length) );
    }
}

#$supplier.done;
#await $single;
await $pairs;
