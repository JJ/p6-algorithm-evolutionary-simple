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

random-chromosome( $length )
----------------------------

Generates a random chromosome

max-ones( @chromosome )
-----------------------

Returns the number of trues or ones in the chromosome

evaluate( :@population, :%fitness-of, :$evaluator --> BagHash ) is export
-------------------------------------------------------------------------

Evaluates the chromosomes, storing values in the fitness cache. 

get-pool-roulette-wheel( BagHash $population, UInt $need = $population.elems ) is export
----------------------------------------------------------------------------------------

Roulette wheel selection. 

mutation( @chromosome )
-----------------------

Returns the chromosome with a random bit flipped

crossover ( @chromosome1 is copy, @chromosome2 is copy )
--------------------------------------------------------

Returns two cromosomes, with parts of it crossed over

produce-offspring( @pool, $size = @pool.elems ) is export
---------------------------------------------------------

Produces offspring from a pool array

generation( :@population, :%fitness-of, :$evaluator --> BagHash )
-----------------------------------------------------------------

Single generation of an evolutionary algorithm. The initial BagHash has to be evaluated before entering here using the `evaluate` function.

AUTHOR
======

JJ Merelo <jjmerelo@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

