[![Build Status](https://travis-ci.org/JJ/p6-algorithm-evolutionary-simple.svg?branch=master)](https://travis-ci.org/JJ/p6-algorithm-evolutionary-simple)

NAME
====

Algorithm::Evolutionary::Simple - A simple evolutionary algorithm

SYNOPSIS
========

    use Algorithm::Evolutionary::Simple;

	# Example in resources/examples/max-ones.p6
    my @found;
    for ^$repetitions {
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
	    
	}
	say "Found → $population.sort(*.value).reverse.[0]";
	@found.push( $result );


DESCRIPTION
===========

`Algorithm::Evolutionary::Simple` is a module for writing simple and quasi-canonical evolutionary algorithms in Perl 6. It uses binary representation, integer fitness (which is needed for the kind of data structure we are using) and a single fitness function.

It is intended mainly for demo purposes. In the future, more versions will be available. 

It uses a fitness cache for storing and not reevaluating, so take care
of memory bloat.

INSTALLATION
============

This module is [available in the Perl 6 ecosystem](https://modules.perl6.org/dist/Algorithm::Evolutionary::Simple:cpan:JMERELO), so the usual

	zef install Algorithm::Evolutionary::Simple

should do the trick, or

	zef install --deps-only .

if you want to hack on a copy.

REFERENCING THIS MODULE
=======================

If you use this module somehow for a paper, I would be very grateful
if you used the following reference for it:

```
@inproceedings{Merelo-Guervos:2018:PIE:3205651.3208273,
 author = {Merelo-Guerv\'{o}s, Juan-Juli\'{a}n and Garc\'{\i}a-Valdez, Jos{\'e}-Mario},
 title = {Performance Improvements of Evolutionary Algorithms in Perl 6},
 booktitle = {Proceedings of the Genetic and Evolutionary Computation Conference Companion},
 series = {GECCO '18},
 year = {2018},
 isbn = {978-1-4503-5764-7},
 location = {Kyoto, Japan},
 pages = {1371--1378},
 numpages = {8},
 url = {http://doi.acm.org/10.1145/3205651.3208273},
 doi = {10.1145/3205651.3208273},
 acmid = {3208273},
 publisher = {ACM},
 address = {New York, NY, USA},
 keywords = {benchmarking, computer languages, concurrency, evolutionary algorithms, perl, perl 6},
} 

```

The artículo is avaliable from [ACM in an open access model](https://dl.acm.org/citation.cfm?id=3208273)

EXAMPLES
========

The [`resources/examples`](resources/examples) subdirectory includes a few examples, including how to use it in a concurrent way. If you want to test the speed, the [`resources/benchmarks`](resources/benchmarks) subdirectory includes also a few speed tests.

PRESENTATIONS
=============

[Concurrent evolutionary algorithms in Perl 6](https://jj.github.io/evosoft-concurrent-perl6/#/) was presented for the last time at the [TPC in Glasgow](http://act.perlconference.org/tpc-2018-glasgow/)

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

royal-road( @chromosome )
-------------------------

That's a bumpy road, returns 1 for each block of 4 which has the same true or false value.

multi evaluate( :@population, :%fitness-of, :$evaluator, :$auto-t = False --> Mix ) is export
---------------------------------------------------------------------------------------------

Evaluates the chromosomes, storing values in the fitness cache. If `auto-t` is set to 'True', uses autothreading for faster operation (if needed). In absence of that parameter, defaults to sequential.

get-pool-roulette-wheel( Mix $population, UInt $need = $population.elems ) is export
------------------------------------------------------------------------------------

Roulette wheel selection. 

mutation( @chromosome is copy --> Array )
-----------------------------------------

Returns the chromosome with a random bit flipped.

crossover ( @chromosome1 is copy, @chromosome2 is copy ) returns List
---------------------------------------------------------------------

Returns two chromosomes, with parts of it crossed over. Generally you will want to do crossover first, then mutation. 

produce-offspring( @pool, $size = @pool.elems --> Seq ) is export
-----------------------------------------------------------------

Produces offspring from an array that contains the reproductive pool; it returns a `Seq`.

best-fitness( $population )
---------------------------

Returns the fitness of the first element. Mainly useful to check if the algorithm is finished.

generation( :@population, :%fitness-of, :$evaluator, :$population-size = $population.elems --> Mix )
----------------------------------------------------------------------------------------------------

Single generation of an evolutionary algorithm. The initial `Mix` has to be evaluated before entering here using the `evaluate` function.

mix( $population1, $population2, $size --> Mix ) is export 
-----------------------------------------------------------

Mixes the two populations, returning a single one of the indicated size

SEE ALSO
========

There is a very interesting implementation of an evolutionary algorithm in [Algorithm::Genetic](Algorithm::Genetic). Check it out.

This is also a port of [Algorithm::Evolutionary::Simple to Perl6](https://metacpan.org/release/Algorithm-Evolutionary-Simple), which has a few more goodies. 

AUTHOR
======

JJ Merelo <jjmerelo@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

