use v6.c;
use Test;

use Algorithm::Evolutionary::Simple;

constant length = 32;
my @random-chromosome = random-chromosome( length );
is( @random-chromosome.elems, length, "Chromosome length OK" );
my $packed-in-an-int = pack-individual( @random-chromosome);
isa-ok( $packed-in-an-int, Int, "Individual is packed" );
is-deeply( unpack-individual( $packed-in-an-int, length), @random-chromosome, "Individual unpacks OK" );
done-testing;
