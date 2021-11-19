#!/bin/bash
#
gfortran -c bellman_ford_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling bellman_ford_prb.f90"
  exit
fi
#
gfortran -o bellman_ford_prb bellman_ford_prb.o -L$HOME/lib/$ARCH -lbellman_ford
if [ $? -ne 0 ]; then
  echo "Errors linking and loading bellman_ford_prb.o"
  exit
fi
rm bellman_ford_prb.o
#
./bellman_ford_prb > bellman_ford_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running bellman_ford_prb"
  exit
fi
rm bellman_ford_prb
#
echo "Test program output written to bellman_ford_prb_output.txt."
