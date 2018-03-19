[![Build Status](https://travis-ci.org/JJ/p6-algorithm-evolutionary-simple.svg?branch=master)](https://travis-ci.org/JJ/p6-algorithm-evolutionary-simple)

NAME
====

Algorithm::Evolutionary::Simple - A simple evolutionary algorithm

SYNOPSIS
========

    use Algorithm::Evolutionary::Simple;

DESCRIPTION
===========

Algorithm::Evolutionary::Simple is ...

METHODS
=======

random-chromosome( $length )
----------------------------

Generates a random chromosome

max-ones( @chromosome )
-----------------------

Returns the number of trues or ones in the chromosome

mutation( @chromosome )
-----------------------

Returns the chromosome with a random bit flipped

generation( :@population, :%fitness-of, :$evaluator --> BagHash )
-----------------------------------------------------------------

Single generation of an evolutionary algorithm. The initial BagHash has to be evaluated

AUTHOR
======

JJ Merelo <jjmerelo@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

