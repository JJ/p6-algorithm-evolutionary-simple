#!/usr/bin/env perl6

use v6;

use Test;

use Algorithm::Evolutionary::Fitness::P-Peaks;

my $length = 32;

my $p-peaks = Algorithm::Evolutionary::Fitness::P-Peaks.new: number-of-peaks => 100, bits => $length;

$p-peaks.say;

done-testing;
