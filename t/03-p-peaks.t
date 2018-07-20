#!/usr/bin/env perl6

use v6;

use Test;

use Algorithm::Evolutionary::Fitness::P-Peaks;

my $length = 32;
my $number-of-peaks=100;

my $p-peaks = Algorithm::Evolutionary::Fitness::P-Peaks.new: number-of-peaks => $number-of-peaks, bits => $length;

cmp-ok $p-peaks, "~~", Algorithm::Evolutionary::Fitness::P-Peaks, "Correct object";

cmp-ok $p-peaks.peaks().elems, "==", $number-of-peaks, "Number of peaks correct";


done-testing;
