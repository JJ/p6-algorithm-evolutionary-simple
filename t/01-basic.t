use v6.c;
use Test;

use Algorithm::Evolutionary::Simple;

constant length = 32;
my @random-chromosome = random-chromosome( length );
is( @random-chromosome.elems, length, "Chromosome length OK" );
my $packed-in-an-int = pack-individual( @random-chromosome);
isa-ok( $packed-in-an-int, Int, "Individual is packed" );
is-deeply( unpack-individual( $packed-in-an-int, length), @random-chromosome, "Individual unpacks OK" );

my $population-size = 32;
my @initial-population;
for 1..$population-size -> $p {
    @initial-population.push: random-chromosome( length );
}
my $packed-pop = pack-population( @initial-population);
does-ok( $packed-pop, Buf[uint64], "Population is packed");
is( $packed-pop.elems, $population-size, "Buf is the right size");
my @unpacked-pop = unpack-population( $packed-pop, length);
is( @unpacked-pop.elems, length, "Population unpacked OK");
is-deeply( @unpacked-pop[0], @initial-population[0].Array, "Unpacking works");
done-testing;
