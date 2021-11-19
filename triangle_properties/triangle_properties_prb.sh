#!/bin/bash
#
gfortran -c triangle_properties_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangle_properties_prb.f90"
  exit
fi
#
gfortran -o triangle_properties_prb triangle_properties_prb.o -L$HOME/lib/$ARCH -ltriangle_properties
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangle_properties_prb.o"
  exit
fi
rm triangle_properties_prb.o
#
./triangle_properties_prb > triangle_properties_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running triangle_properties_prb"
  exit
fi
rm triangle_properties_prb
#
echo "Test program output written to triangle_properties_prb_output.txt."
