#!/bin/bash
#
gfortran -c triangle_io_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangle_io_prb.f90"
  exit
fi
#
gfortran -o triangle_io_prb triangle_io_prb.o -L$HOME/lib/$ARCH -ltriangle_io
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangle_io_prb.o"
  exit
fi
rm triangle_io_prb.o
#
./triangle_io_prb > triangle_io_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running triangle_io_prb"
  exit
fi
rm triangle_io_prb
#
echo "Test program output written to triangle_io_prb_output.txt."
