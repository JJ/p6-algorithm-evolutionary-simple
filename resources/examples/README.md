# Evolutionary computation examples

This directory contains most of the examples used in several papers on
evolutionary algorithms in Perl 6, as well as bash scripts needed to
run them.

If you want to run them, first go to the main directory and run

    zef install --deps-only .
    
Come back to this directory, and run, for instance

     nohup ./pop-mixer-fan-compress-gecco-generations.sh >> evosoft-2019-2.dat 2> evosoft-2019-2.err < /dev/null 
     
(Just in case you will leave it running on a server. Check out the
shell script for the program it's running; right now it's the leading
ones).

This will leave a slew of JSON files, which you use late on for
post-mortem analysis. 
     
