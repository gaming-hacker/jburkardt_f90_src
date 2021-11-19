#!/bin/bash
#
gfortran -c bank_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling bank_prb.f90"
  exit
fi
#
gfortran bank_prb.o -L$HOME/lib/$ARCH -lbank
if [ $? -ne 0 ]; then
  echo "Errors linking and loading bank_prb.o"
  exit
fi
rm bank_prb.o
#
mv a.out bank_prb
./bank_prb > bank_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running bank_prb"
  exit
fi
rm bank_prb
#
echo "Test program output written to bank_prb_output.txt."
