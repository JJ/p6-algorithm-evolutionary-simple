#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;

my $length = 32;
my $supplier = Supplier.new;
my $supply   = $supplier.Supply;
 
$supply.tap( -> $v { say "First : ", $v });
$supply.tap( -> $χ { say max-ones( $χ ) } );
	     
for 1 .. 10 {
    $supplier.emit( random-chromosome($length) );
}


