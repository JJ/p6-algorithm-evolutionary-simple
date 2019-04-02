#!/bin/bash

threads='2 4 6 8 10'
for t in $threads
do
    echo $t
    for i in {1..15}
    do
        perl6 -I../../lib concurrent-ea-leading-ones.p6 --threads=$t
    done
done
