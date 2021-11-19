#!/bin/bash
#
gfortran -c bvec_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling bvec_prb.f90"
  exit
fi
#
gfortran -o bvec_prb bvec_prb.o -L$HOME/lib/$ARCH -lbvec
if [ $? -ne 0 ]; then
  echo "Errors linking and loading bvec_prb.o"
  exit
fi
rm bvec_prb.o
#
./bvec_prb > bvec_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running bvec_prb"
  exit
fi
rm bvec_prb
#
echo "Test program output written to bvec_prb_output.txt."
