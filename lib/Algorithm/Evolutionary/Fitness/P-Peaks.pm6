use v6.c;

unit class Algorithm::Evolutionary::Fitness::P-Peaks:ver<0.0.6>;

has UInt $.number-of-peaks;
has UInt $.bits;
has      @.peaks;

method TWEAK() {
    for ^$!number-of-peaks {
	@!peaks.push: (Bool.pick xx $!bits).list;
    }
}

method distance( @chromosome --> Rat) is pure {
    my @distances = @!peaks.map: (*.list Z== @chromosome).sum;
    return 1-@distances.min / @chromosome.elems;
}

=begin pod

=head1 NAME

Algorithm::Evolutionary::Fitness::P-Peaks - Implementation of Kennedy's and Spear's p-peaks function.

=head1 SYNOPSIS

     use Algorithm::Evolutionary::Fitness::P-Peaks;

=head1 DESCRIPTION


=head1 METHODS

=head2 method distance( @chromosome --> Rat)

Returns the minimum distance to the closest of the peaks.

=head1 SEE ALSO

This is also a port of L<Algorithm::Evolutionary::Fitness::P_Peaks to Perl6|https://metacpan.org/release/Algorithm-Evolutionary-Fitness>. 

=head1 AUTHOR

JJ Merelo <jjmerelo@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
