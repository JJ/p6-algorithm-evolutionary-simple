use v6.c;
unit class Algorithm::Evolutionary::Simple:ver<0.0.1>;


sub random-chromosome( UInt $length ) is export {
    return Bool.pick() xx $length;
}

sub max-ones( @chromosome ) is export {
    return @chromosome.sum;
}

sub evaluate( :@population, :%fitness-of --> BagHash ) is export {
    my BagHash $pop-bag;
    for @population -> $p {
	if  ! %fitness-of{$p}.defined {
	    %fitness-of{$p} = max-ones( $p );
	}
	$pop-bag{$p} = %fitness-of{$p};
    }
    return $pop-bag;
}

sub get-pool-roulette-wheel( BagHash $population,
			     UInt $need = $population.elems ) is export {
    return $population.pick: $need;
}

sub mutation ( @chromosome is copy ) is export {
    my $pick = @chromosome.pick: @chromosome.elems;
    @chromosome[ $pick ] = !@chromosome[ $pick ];
    return @chromosome;
}

sub produce-offspring( @population,
		       $size = @population.elems ) is export {
    my @new-population;
    
}

=begin pod

=head1 NAME

Algorithm::Evolutionary::Simple - A simple evolutionary algorithm

=head1 SYNOPSIS

  use Algorithm::Evolutionary::Simple;

=head1 DESCRIPTION

Algorithm::Evolutionary::Simple is ...

=head1 METHODS

=head2 random-chromosome( $length )

Generates a random chromosome

=head2 max-ones( @chromosome )

Returns the number of trues or ones in the chromosome

=head2 mutation( @chromosome )

Returns the chromosome with a random bit flipped

=head1 AUTHOR

JJ Merelo <jjmerelo@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
