[![Test-install and cache deps](https://github.com/JJ/p6-algorithm-evolutionary-simple/actions/workflows/test.yaml/badge.svg)](https://github.com/JJ/p6-algorithm-evolutionary-simple/actions/workflows/test.yaml)

NAME
====

Algorithm::Evolutionary::Simple - A simple evolutionary algorithm

SYNOPSIS
========

    use Algorithm::Evolutionary::Simple;

    # From resources/examples/max-ones.p6
    my UInt :$length = 64;
	my UInt :$population-size = 256;


    my @initial-population = initialize( size => $population-size,
					     genome-length => $length );
	my %fitness-of;

	my $population = evaluate( population => @initial-population,
				   fitness-of => %fitness-of,
				   evaluator => &max-ones );

	my $result = 0;
	while $population.sort(*.value).reverse.[0].value < $length {
	    $population = generation( population => $population,
				      fitness-of => %fitness-of,
				      evaluator => &max-ones,
				      population-size => $population-size) ;
	    $result += $population-size;
	    info(to-json( { best => best-fitness($population) } ));
	}

    say $result

DESCRIPTION
===========

`Algorithm::Evolutionary::Simple` is a module for writing simple and quasi
-canonical evolutionary algorithms in Raku. It uses binary representation,
integer fitness (which is needed for the kind of data structure we are using)
and a single fitness function.

It is intended mainly for demo purposes, although it's been actually used in
research. In the future, more versions will be available.

It uses a fitness cache for storing and not reevaluating already seen
 chromosomes, so be mindful of memory bloat.

EXAMPLES
========

Go to [`resources/examples`](resources/examples) for examples. For instance
, run `max-ones.p6` or `p-peaks.p6` there. You'll need to run

     zef  install --deps-only .

To install needed modules in that directory.

METHODS
=======

initialize( UInt :$size, UInt :$genome-length --> Array ) is export
-------------------------------------------------------------------

Creates the initial population of binary chromosomes with the indicated length; returns an array.

random-chromosome( UInt $length --> List )
------------------------------------------

Generates a random chromosome of indicated length. Returns a `Seq` of `Bool`s

max-ones( @chromosome --> Int )
-------------------------------

Returns the number of trues (or ones) in the chromosome.

leading-ones( @chromosome --> Int )
-----------------------------------

Returns the number of ones from the beginning of the chromosome.

royal-road( @chromosome )
-------------------------

That's a bumpy road, returns 1 for each block of 4 which has the same true or false value.

multi evaluate( :@population, :%fitness-of, :$evaluator, :$auto-t = False --> Mix ) is export
---------------------------------------------------------------------------------------------

Evaluates the chromosomes, storing values in the fitness cache. If `auto-t` is set to 'True', uses autothreading for faster operation (if needed). In absence of that parameter, defaults to sequential.

sub evaluate-nocache( :@population, :$evaluator --> Mix )
---------------------------------------------------------

Evaluates the population, returning a Mix, but does not use a cache. Intended mainly for concurrent operation.

get-pool-roulette-wheel( Mix $population, UInt $need = $population.elems ) is export
------------------------------------------------------------------------------------

Returns `$need` elements with probability proportional to its *weight*, which is fitness in this case.

mutation( @chromosome is copy --> Array )
-----------------------------------------

Returns the chromosome with a random bit flipped.

crossover ( @chromosome1 is copy, @chromosome2 is copy ) returns List
---------------------------------------------------------------------

Returns two chromosomes, with parts of it crossed over. Generally you will want to do crossover first, then mutation. 

produce-offspring( @pool, $size = @pool.elems --> Seq ) is export
-----------------------------------------------------------------

Produces offspring from an array that contains the reproductive pool; it returns a `Seq`.

produce-offspring-no-mutation( @pool, $size = @pool.elems --> Seq ) is export
-----------------------------------------------------------------------------

Produces offspring from an array that contains the reproductive pool without using mutation; it returns a `Seq`. 

best-fitness( $population )
---------------------------

Returns the fitness of the first element. Mainly useful to check if the algorithm is finished.

multi sub generation( :@population, :%fitness-of, :$evaluator, :$population-size = $population.elems, Bool :$auto-t --> Mix )
-----------------------------------------------------------------------------------------------------------------------------

Single generation of an evolutionary algorithm. The initial `Mix` has to be evaluated before entering here using the `evaluate` function. Will use auto-threading if `$auto-t` is `True`.

multi sub generation( :@population, :%fitness-of, :$evaluator, :$population-size = $population.elems, Bool :$no-mutation --> Mix )
----------------------------------------------------------------------------------------------------------------------------------

Single generation of an evolutionary algorithm. The initial `Mix` has to be evaluated before entering here using the `evaluate` function. Will not use mutation if that variable is set to `True`

sub generations-without-change( $generations, $population )
-----------------------------------------------------------

Returns `False` if the number of generations in `$generations` has not been reached without changing; it returns `True` otherwise.

mix( $population1, $population2, $size --> Mix ) is export 
-----------------------------------------------------------

Mixes the two populations, returning a single one of the indicated size and with type Mix.

sub pack-individual( @individual --> Int )
------------------------------------------

Packs the individual in a single `Int`. The invidual must be binary, and the maximum length is 64.

sub unpack-individual( Int $packed, UInt $bits --> Array(Seq))
--------------------------------------------------------------

Unpacks the individual that has been packed previously using `pack-individual`

sub pack-population( @population --> Buf) 
------------------------------------------

Packs a population, producing a buffer which can be sent to a channel or stored in a compact form.

sub unpack-population( Buf $buffer, UInt $bits --> Array )
----------------------------------------------------------

Unpacks the population that has been packed using `pack-population`

multi sub frequencies( $population)
-----------------------------------

`$population` can be an array or a Mix, in which case the keys are extracted. This returns the per-bit (or gene) frequency of one (or True) for the population. 

multi sub frequencies-best( $population, $proportion = 2)
---------------------------------------------------------

`$population` is a Mix, in which case the keys are extracted. This returns the per-bit (or gene) frequency of one (or True) for the population of the best part of the population; the size of the population will be divided by the $proportion variable.

sub generate-by-frequencies( $population-size, @frequencies )
-------------------------------------------------------------

Generates a population of that size with every gene according to the indicated frequency.

sub crossover-frequencies( @frequencies, @frequencies-prime --> Array )
-----------------------------------------------------------------------

Generates a new array with random elements of the two arrays that are used as arguments.

SEE ALSO
========

There is a very interesting implementation of an evolutionary algorithm in [Algorithm::Genetic](https://github.com/samgwise/p6-algorithm-genetic). Check it out.

This is also kind of a port of [Algorithm::Evolutionary::Simple to Perl6](https
://metacpan.org/release/Algorithm-Evolutionary-Simple), which has a few more goodies, but it's not simply a port, since most of the code is completely different.

AUTHOR
======

JJ Merelo <jjmerelo@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018, 2019, 2022 JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

