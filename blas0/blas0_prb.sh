#!/bin/bash
#
gfortran -c blas0_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling blas0_prb.f90"
  exit
fi
#
gfortran blas0_prb.o -L$HOME/lib/$ARCH -lblas
if [ $? -ne 0 ]; then
  echo "Errors linking and loading blas0_prb.o"
  exit
fi
rm blas0_prb.o
#
mv a.out blas0_prb
./blas0_prb > blas0_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running blas0_prb"
  exit
fi
rm blas0_prb
#
echo "Test program output written to blas0_prb_output.txt."
