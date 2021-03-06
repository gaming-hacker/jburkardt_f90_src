#!/bin/bash
#
gfortran -c cpv_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling cpv_prb.f90"
  exit
fi
#
gfortran -o cpv_prb cpv_prb.o -L$HOME/lib/$ARCH -lcpv
if [ $? -ne 0 ]; then
  echo "Errors linking and loading cpv_prb.o"
  exit
fi
rm cpv_prb.o
#
./cpv_prb > cpv_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running cpv_prb"
  exit
fi
rm cpv_prb
#
echo "Test program output written to cpv_prb_output.txt."
