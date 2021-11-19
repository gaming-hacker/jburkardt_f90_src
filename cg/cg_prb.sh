#!/bin/bash
#
gfortran -c cg_prb.f90 >& compiler.txt
if [ $? -ne 0 ]; then
  echo "Errors compiling cg_prb.f90"
  exit
fi
rm compiler.txt
#
gfortran cg_prb.o -L$HOME/lib/$ARCH -lcg
if [ $? -ne 0 ]; then
  echo "Errors linking and loading cg_prb.o"
  exit
fi
rm cg_prb.o
#
mv a.out cg_prb
./cg_prb > cg_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running cg_prb"
  exit
fi
rm cg_prb
#
echo "Test program output written to cg_prb_output.txt."
