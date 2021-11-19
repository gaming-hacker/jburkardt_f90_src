#!/bin/bash
#
gfortran -c asa053_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling asa053_prb.f90"
  exit
fi
#
gfortran asa053_prb.o -L$HOME/lib/$ARCH -lasa053
if [ $? -ne 0 ]; then
  echo "Errors linking and loading asa053_prb.o"
  exit
fi
rm asa053_prb.o
#
mv a.out asa053_prb
./asa053_prb > asa053_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running asa053_prb"
  exit
fi
rm asa053_prb
#
echo "Test results written to asa053_prb_output.txt."
