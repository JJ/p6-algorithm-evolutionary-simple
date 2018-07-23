[![Build Status](https://travis-ci.org/JJ/p6-algorithm-evolutionary-simple.svg?branch=master)](https://travis-ci.org/JJ/p6-algorithm-evolutionary-simple)

NAME
====

Algorithm::Evolutionary::Simple - A simple evolutionary algorithm

SYNOPSIS
========

    use Algorithm::Evolutionary::Simple;

DESCRIPTION
===========

Algorithm::Evolutionary::Simple is a module for writing simple and quasi-canonical evolutionary algorithms in Perl 6. It uses binary representation, integer fitness (which is needed for the kind of data structure we are using) and a single fitness function.

It is intended mainly for demo purposes. In the future, more versions will be available. 

It uses a fitness cache for storing and not reevaluating, so take care of memory bloat.

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

