use v6.c;

unit class Algorithm::Evolutionary::Fitness::P-Peaks:ver<0.0.1>;

has UInt $.number-of-peaks;
has UInt $.bits;
has      @.peaks = ();

method TWEAK() {
    for ^$!number-of-peaks {
	@!peaks.push: Bool.pick xx $!bits;
    }

}

method distance( @chromosome --> Rat) {
    my @distances = @!peaks.map: (*.list Z== @chromosome).sum;
    return @distances.min / @chromosome.elems;
}

=begin pod

=head1 NAME

Algorithm::Evolutionary::Fitness::P-Peaks - Implementation of Kennedy's and Spear's p-peaks function.

=head1 SYNOPSIS

  use Algorithm::Evolutionary::Fitness::P-Peaks;

=head1 DESCRIPTION


=head1 METHODS


=head1 SEE ALSO

This is also a port of L<Algorithm::Evolutionary::Fitness::P_Peaks to Perl6|https://metacpan.org/release/Algorithm-Evolutionary-Fitness>. 

=head1 AUTHOR

JJ Merelo <jjmerelo@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod