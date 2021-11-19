#!/bin/bash
#
gfortran -c brent_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling brent_prb.f90"
  exit
fi
#
gfortran brent_prb.o -L$HOME/lib/$ARCH -lbrent
if [ $? -ne 0 ]; then
  echo "Errors linking and loading brent_prb.o"
  exit
fi
rm brent_prb.o
#
mv a.out brent_prb
./brent_prb > brent_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running brent_prb"
  exit
fi
rm brent_prb
#
echo "Test program output written to brent_prb_output.txt."
