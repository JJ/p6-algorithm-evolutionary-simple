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

my $length = 32;
my @population = initialize( size => $population-size,
			     genome-length => $length );

my $evaluated-pop = evaluate-nocache(:@population,
				     evaluator => &max-ones );

for $evaluated-pop.keys -> $k {
    is( $evaluated-pop{$k}, max-ones( $k ), "Evaluation is correct, {$evaluated-pop{$k}}");
}

does-ok($evaluated-pop, Mix, "Evaluated pop is the right class" );

my @population-prime = initialize( size => $population-size,
				   genome-length => $length );

my $new-pop = mix-raw( @population, @population-prime, $population-size, &max-ones);
is( $new-pop.elems, $population-size, "Size is correct" );

my @frequencies = frequencies( $new-pop );
is( @frequencies.elems, $length, "Size is correct" );
cmp-ok( any(@frequencies), ">", 0, "Some frequencies are not null" );

@population = generate-by-frequencies( $population-size, @frequencies );
is( @population.elems, $population-size, "Size is correct" );
for @population -> @p {
    is( @p.elems, $length, "Size of generated elem is correct" );
}
my @new-frequencies = frequencies( @population );
my $difference =  [+] @new-frequencies Z- @frequencies;
cmp-ok( $difference, "<", $population-size * 0.3, "Frequencies differ in $difference" );

done-testing;
