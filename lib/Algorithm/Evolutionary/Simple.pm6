use v6.c;

unit module Algorithm::Evolutionary::Simple:ver<0.0.8>;

sub random-chromosome( UInt $length --> List(Seq) ) is export {
    return Bool.pick() xx $length;
}

sub initialize( UInt :$size,
		UInt :$genome-length --> Array ) is export {
    my @initial-population;
    for 1..$size -> $p {
	@initial-population.push: random-chromosome( $genome-length );
    }
    return @initial-population;
}

sub leading-ones( @chromosome --> Int ) is export is pure {
    return @chromosome.first( !*, :kv )[0] // @chromosome.elems;
}

sub max-ones( @chromosome --> Int ) is export is pure {
    return @chromosome.map( *.so).sum;
}

sub royal-road( @chromosome --> Int ) is export is pure {
    return @chromosome.rotor(4).grep( so (*.all == True|False) ).elems;
}

proto evaluate( :@population,
	        :%fitness-of,
	        :$evaluator,
                |) { * };

multi sub evaluate( :@population,
	            :%fitness-of,
	            :$evaluator --> Mix ) is export {
    my MixHash $pop-bag;
    for @population -> $p {
	if  ! %fitness-of{$p}.defined {
	    %fitness-of{$p} = $evaluator( $p );

	}
	$pop-bag{$p} = %fitness-of{$p};
    }
    return $pop-bag.Mix;
}

sub evaluate-nocache( :@population,
    			    :$evaluator --> Mix ) is export {
    my MixHash $pop-bag;
    for @population -> $p {
	    if  $pop-bag{$p}:!exists {
	        $pop-bag{$p} = $evaluator( $p );
	    }
    }
    return $pop-bag.Mix;
}

multi sub evaluate( :@population,
	                :%fitness-of,
	                :$evaluator,
                    Bool :$auto-t --> Mix ) is export {
    my @unique-population = @population.unique;
    my @evaluations = @unique-population.race(degree => 8).map( { $^p => $evaluator( $^p ) } );
    my MixHash $pop-bag;
    for @evaluations -> $pair {
        $pop-bag{$pair.key.item} = $pair.value;
    }
    return $pop-bag.Mix;
}

sub get-pool-roulette-wheel( Mix $population,
			                 UInt $need = $population.elems ) is export {
    return $population.roll: $need;
}

sub mutation ( @chromosome is copy --> List ) is export {
    my $pick = (^@chromosome.elems).pick;
    @chromosome[ $pick ] = !@chromosome[ $pick ];
    return @chromosome;
}

sub crossover ( @chromosome1 is copy,
		        @chromosome2 is copy )
                returns List
                is export {
    my $length = @chromosome1.elems;
    my $xover1 = (^($length-2)).pick;
    my $xover2 = ($xover1^..^$length).pick;
    my @x-chromosome = @chromosome2;
    my @þone = $xover1..$xover2;
    @chromosome2[@þone] = @chromosome1[@þone];
    @chromosome1[@þone] = @x-chromosome[@þone];
    return [@chromosome1,@chromosome2];
}

sub produce-offspring( @pool,
		       $size = @pool.elems --> Seq ) is export {
    my @new-population;
    for 1..($size/2) {
	my @χx = @pool.pick: 2;
	@new-population.push: crossover(@χx[0], @χx[1]).Slip;
    }
    return @new-population.map( { mutation( $^þ ) } );

}

sub produce-offspring-no-mutation( @pool,
                                   $size = @pool.elems --> Seq ) is export {
    my @new-population;
    for 1..($size/2) {
	    my @χx = @pool.pick: 2;
	    @new-population.push: crossover(@χx[0], @χx[1]).Slip;
    }
    return @new-population.Seq;

}

sub best-one(Mix $population) is export is pure {
    return $population.sort(*.value).reverse.[0];
}

sub best-fitness(Mix $population ) is export is pure {
    return best-one( $population ).value;
}

proto sub generation(Mix :$population,
	             :%fitness-of,
	             :$evaluator,
	             :$population-size,
                     | --> Mix ) { * };

multi sub generation(Mix :$population,
		     :%fitness-of,
		     :$evaluator,
		     :$population-size = $population.elems --> Mix ) is export {

    my $best = $population.sort(*.value).reverse.[0..1].Mix; # Keep the best as elite
    my @pool = get-pool-roulette-wheel( $population, $population-size-2);
    my @new-population= produce-offspring( @pool, $population-size );
    return Mix(evaluate( population => @new-population,
			 fitness-of => %fitness-of,
			 evaluator => $evaluator ) ∪ $best );
}

multi sub generation(Mix :$population,
	             :%fitness-of,
	             :$evaluator,
	             :$population-size = $population.elems,
                     Bool :$no-mutation --> Mix ) is export {

    my $best = $population.sort(*.value).reverse.[0..1].Mix; # Keep the best as elite
    my @pool = get-pool-roulette-wheel( $population, $population-size-2);
    my @new-population= produce-offspring-no-mutation( @pool, $population-size );
    return Mix(evaluate( population => @new-population,
			 fitness-of => %fitness-of,
			 evaluator => $evaluator ) ∪ $best );
}

multi sub generation(Mix :$population,
	       :%fitness-of,
	       :$evaluator,
	       :$population-size = $population.elems,
               Bool :$auto-t --> Mix ) is export {

    my $best = $population.sort(*.value).reverse.[0..1].Mix; # Keep the best as elite
    my @pool = get-pool-roulette-wheel( $population, $population-size-2);
    my @new-population= produce-offspring( @pool, $population-size );
    return Mix(evaluate( population => @new-population,
			 fitness-of => %fitness-of,
			 evaluator => $evaluator,
                         :$auto-t ) ∪ $best );
}

sub no-change-during( $generations, $best ) is export {
    state $generations-without-change=0;
    state $previous-best;
    with $previous-best {
	    if $best == $previous-best {
	        $generations-without-change++;
	    } else {
	        $generations-without-change=0;
	    }
    } else {
	    $generations-without-change++;
    }
    $previous-best = $best;
    return $generations-without-change >= $generations;
}

sub mix( $population1, $population2, $size --> Mix ) is export {
    my $new-population = $population1 ∪ $population2;
    return $new-population.sort(*.value).reverse.[0..($size-1)].Mix;
}

sub mix-raw( @population1, @population2, $size, $evaluator --> Mix ) is export {
    my @new-population = push(@population1,@population2.Slip);
    my $new-population = evaluate-nocache( population => @new-population,
					   :$evaluator);
    return $new-population.sort(*.value).reverse.[^$size].Mix;
}

sub pack-individual( @individual --> uint64 ) is export {
    my $str = @individual.map( ~ + *).join("");
    my uint64 $temp = :2($str);
    return $temp;
}

sub unpack-individual( uint64 $packed, UInt $bits --> Array(Seq)) is export {
    my @unpacked = $packed.base(2).comb.map( so +* );
    return (False xx ( $bits - @unpacked.elems), @unpacked).flat;
}

sub pack-population( @population --> Buf) is export {
    my @packed-individuals;
    for @population -> $individual {
	    @packed-individuals.push: pack-individual( $individual);
    }
    return buf64.new( @packed-individuals);
}

sub unpack-population( Buf $buffer, UInt $bits --> Array ) is export {
    my @packed-individuals;
    loop (my $i = 0; $i < $buffer.elems; $i++ ) {
	    @packed-individuals.push: unpack-individual( $buffer[$i], $bits);
    }
    return @packed-individuals;
}

proto sub frequencies( |) { * };
multi sub frequencies( @population --> List(Seq) ) is export {
    my @totals = 0 xx @population[0].elems;
    { @totals Z+= @^p } for @population;
    return @totals X/ @population.elems;
}

multi sub frequencies( Mix $population --> List ) is export {
    frequencies( $population.keys );
}

sub frequencies-best( Mix $population, $elite = 2 --> List ) is export {
    my $best = $population.sort(*.value).reverse.[0..($population.elems/$elite)].Mix;
    frequencies($best);
}

sub generate-with-best( $population-size, @frequencies, $best --> Array ) is export {
    my @mix = @frequencies.map( { (Bool::True => $_, Bool::False => 1-$_ ).Mix } );
    my @population = gather {
        for ^($population-size - 1) {
            my @one = @mix>>.roll;
            take @one;
        }
    }
    @population.push( $best.key );
    return @population;
}

sub generate-by-frequencies( $population-size, @frequencies --> Array ) is export {
    my @mix = @frequencies.map( { (Bool::True => $_, Bool::False => 1-$_ ).Mix } );
    my @population = gather {
        for ^$population-size {
            my @one = @mix>>.roll;
            take @one;
        }
    }
    return @population;
}

sub crossover-frequencies( @frequencies, @frequencies-prime --> Array ) is export {
    my @pairs = @frequencies Z @frequencies-prime;
    my @new-population =  gather {
        for @pairs -> @pair {
            take @pair.pick;
        }
    };
    return @new-population;
}

=begin pod

=head1 NAME

Algorithm::Evolutionary::Simple - A simple evolutionary algorithm

=head1 SYNOPSIS

  use Algorithm::Evolutionary::Simple;

=head1 DESCRIPTION

Algorithm::Evolutionary::Simple is a module for writing simple and
quasi-canonical evolutionary algorithms in Perl 6. It uses binary
representation, integer fitness (which is needed for the kind of data
structure we are using) and a single fitness function.

It is intended mainly for demo purposes, although it's been actually used in research. In the future,
more versions will be available.

It uses a fitness cache for storing and not reevaluating,
so take care of memory bloat.
   
=head1 METHODS

=head2 initialize( UInt :$size,
		   UInt :$genome-length --> Array ) is export

Creates the initial population of binary chromosomes with the indicated length; returns an array. 

=head2 random-chromosome(  UInt $length --> List )

Generates a random chromosome of indicated length. Returns a C<Seq> of C<Bool>s

=head2 max-ones( @chromosome --> Int )

Returns the number of trues (or ones) in the chromosome.

=head2 leading-ones( @chromosome --> Int )

Returns the number of ones from the beginning of the chromosome. 


=head2 royal-road( @chromosome )

That's a bumpy road, returns 1 for each block of 4 which has the same true or false value.

=head2 multi evaluate( :@population,
		       :%fitness-of,
		       :$evaluator,
                       :$auto-t = False --> Mix ) is export

Evaluates the chromosomes, storing values in the fitness cache. If C<auto-t> is set to 'True', uses autothreading for faster operation (if needed). In absence of that parameter, defaults to sequential.

=head2 sub evaluate-nocache( :@population,
			    :$evaluator --> Mix )

Evaluates the population, returning a Mix, but does not use a cache. Intended mainly for concurrent operation.
                                               
=head2 get-pool-roulette-wheel( Mix $population,
				UInt $need = $population.elems ) is export

Returns C<$need> elements with probability proportional to its I<weight>, which is fitness in this case.

=head2 mutation( @chromosome is copy --> Array )

Returns the chromosome with a random bit flipped.

=head2 crossover ( @chromosome1 is copy, @chromosome2 is copy ) returns List

Returns two chromosomes, with parts of it crossed over. Generally you will want to do crossover first, then mutation. 

=head2 produce-offspring( @pool, $size = @pool.elems --> Seq ) is export

Produces offspring from an array that contains the reproductive pool; it returns a C<Seq>.

=head2 produce-offspring-no-mutation( @pool,
		                      $size = @pool.elems --> Seq ) is export

Produces offspring from an array that contains the reproductive pool
without using mutation; it returns a C<Seq>.
			
=head2 best-one( $population )

Returns the best individual in the population.

			
=head2 best-fitness( $population )

Returns the fitness of the first element. Mainly useful to check if the algorithm is finished.

=head2 multi sub generation(  :@population,
		              :%fitness-of,
		              :$evaluator,
	                      :$population-size = $population.elems,
                              Bool :$auto-t --> Mix )

Single generation of an evolutionary algorithm. The initial C<Mix>
has to be evaluated before entering here using the C<evaluate>
function. Will use auto-threading if C<$auto-t> is C<True>.

=head2 multi sub generation(  :@population,
		              :%fitness-of,
		              :$evaluator,
	                      :$population-size = $population.elems,
                              Bool :$no-mutation --> Mix )

Single generation of an evolutionary algorithm. The initial C<Mix>
has to be evaluated before entering here using the C<evaluate>
function. Will not use mutation if that variable is set to C<True>


=head2 sub generations-without-change( $generations, $population )

Returns C<False> if the number of generations in C<$generations> has not been reached without changing; it returns C<True> otherwise.

=head2 mix( $population1, $population2, $size --> Mix ) is export 
  
Mixes the two populations, returning a single one of the indicated size and with type Mix.

                                     
=head2 sub pack-individual( @individual --> Int )

Packs the individual in a single C<Int>. The invidual must be binary, and the maximum length is 64.

=head2 sub unpack-individual( Int $packed, UInt $bits --> Array(Seq))

Unpacks the individual that has been packed previously using C<pack-individual>


=head2 sub pack-population( @population --> Buf) 

Packs a population, producing a buffer which can be sent to a channel or stored in a compact form.

=head2 sub unpack-population( Buf $buffer, UInt $bits --> Array )

Unpacks the population that has been packed using C<pack-population>


=head2 multi sub frequencies( $population)

C<$population> can be an array or a Mix, in which case the keys are extracted. This returns the per-bit (or gene) frequency of one (or True) for the population. 

=head2 multi sub frequencies-best( $population, $proportion = 2)

C<$population> is a Mix, in which case the keys are extracted. This returns the per-bit (or gene) frequency of one (or True) for the population of the best part of the population; the size of the population will be divided by the $proportion variable.

=head2 sub generate-with-gest( $population-size, @frequencies, $best-one )

Generates a population of that size with every gene according to the indicated frequency and adds the best a part of the population.

=head2 sub generate-by-frequencies( $population-size, @frequencies )

Generates a population of that size with every gene according to the indicated frequency.


=head2 sub generate-by-frequencies( $population-size, @frequencies )

Generates a population of that size with every gene according to the indicated frequency.

=head2 sub crossover-frequencies( @frequencies, @frequencies-prime --> Array )

Generates a new array with random elements of the two arrays that are used as arguments.


=head1 SEE ALSO

There is a very interesting implementation of an evolutionary algorithm in L<C<Algorithm::Genetic>|https://github.com/samgwise/p6-algorithm-genetic>. Check it out.

This is also a port of L<Algorithm::Evolutionary::Simple, a Perl 5 module, to Perl6|https://metacpan.org/release/Algorithm-Evolutionary-Simple>, which has a few more goodies, but it's not simply a port, since most of the code is completely different. Also the functions. They're just namesakes, actually.

=head1 AUTHOR

JJ Merelo <jjmerelo@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018, 2019 JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
