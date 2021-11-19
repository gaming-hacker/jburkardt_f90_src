#!/bin/bash
#
gfortran -c timestamp_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling timestamp_prb.f90"
  exit
fi
#
gfortran timestamp_prb.o -L$HOME/lib/$ARCH -ltimestamp
if [ $? -ne 0 ]; then
  echo "Errors linking and loading timestamp_prb.o"
  exit
fi
rm timestamp_prb.o
#
mv a.out timestamp_prb
./timestamp_prb > timestamp_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running timestamp_prb"
  exit
fi
rm timestamp_prb
#
echo "Test program output written to timestamp_prb_output.txt."
