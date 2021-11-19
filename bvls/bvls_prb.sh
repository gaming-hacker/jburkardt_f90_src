#!/bin/bash
#
gfortran -c bvls_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling bvls_prb.f90"
  exit
fi
#
gfortran -o bvls_prb bvls_prb.o -L$HOME/lib/$ARCH -lbvls
if [ $? -ne 0 ]; then
  echo "Errors linking and loading bvls_prb.o"
  exit
fi
rm bvls_prb.o
#
./bvls_prb > bvls_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running bvls_prb"
  exit
fi
rm bvls_prb
#
echo "Test program output written to bvls_prb_output.txt."
