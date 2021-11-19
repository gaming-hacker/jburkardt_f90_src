#!/bin/bash
#
gfortran -c cdflib_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling cdflib_prb.f90"
  exit
fi
#
gfortran cdflib_prb.o -L$HOME/lib/$ARCH -lcdflib
if [ $? -ne 0 ]; then
  echo "Errors linking and loading cdflib_prb.o"
  exit
fi
rm cdflib_prb.o
#
mv a.out cdflib_prb
./cdflib_prb > cdflib_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running cdflib_prb"
  exit
fi
rm cdflib_prb
#
echo "Test program output written to cdflib_prb_output.txt."
