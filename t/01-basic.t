use v6.c;
use Test;

use Algorithm::Evolutionary::Simple;

my $population-size = 32;

for <32 64> -> $length {
    for ^$population-size {
	my @random-chromosome = random-chromosome( $length );
	is( @random-chromosome.elems, $length, "Chromosome length OK" );
	my $packed-in-an-int = pack-individual( @random-chromosome);
	isa-ok( $packed-in-an-int, Int, "Individual with @random-chromosome[0] is packed in $packed-in-an-int" );
	is-deeply( unpack-individual( $packed-in-an-int, $length), @random-chromosome, "Individual unpacks OK" );
    }

    my @initial-population = initialize( size => $population-size,
					 genome-length => $length );
    is( @initial-population.elems, $population-size, "Pop is the right size");

    my $packed-pop = pack-population( @initial-population);
    does-ok( $packed-pop, Buf[uint64], "Population is packed");
    is( $packed-pop.elems, $population-size, "Buf is the right size");
    my @unpacked-pop = unpack-population( $packed-pop, $length);
    is( @unpacked-pop.elems, $population-size, "Population unpacked OK");
    is-deeply( @unpacked-pop[0], @initial-population[0].Array, "Unpacking works");
}
done-testing;
