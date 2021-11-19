#!/bin/bash
#
gfortran -c triangle_integrals_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangle_integrals_prb.f90"
  exit
fi
#
gfortran -o triangle_integrals_prb triangle_integrals_prb.o -L$HOME/lib/$ARCH -ltriangle_integrals
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangle_integrals_prb.o"
  exit
fi
rm triangle_integrals_prb.o
#
./triangle_integrals_prb > triangle_integrals_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running triangle_integrals_prb"
  exit
fi
rm triangle_integrals_prb
#
echo "Test program output written to triangle_integrals_prb_output.txt."
