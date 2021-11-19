#!/bin/bash
#
gfortran -c upc_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling upc_prb.f90"
  exit
fi
#
gfortran upc_prb.o -L$HOME/lib/$ARCH -lupc
if [ $? -ne 0 ]; then
  echo "Errors linking and loading upc_prb.o"
  exit
fi
rm upc_prb.o
#
mv a.out upc_prb
./upc_prb > upc_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running upc_prb"
  exit
fi
rm upc_prb
#
echo "Test program output written to upc_prb_output.txt."
