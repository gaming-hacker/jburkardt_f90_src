#!/bin/bash
#
gfortran -c correlation_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling correlation_prb.f90"
  exit
fi
#
gfortran correlation_prb.o -L$HOME/lib/$ARCH -lcorrelation
if [ $? -ne 0 ]; then
  echo "Errors linking and loading correlation_prb.o"
  exit
fi
rm correlation_prb.o
#
mv a.out correlation_prb
./correlation_prb > correlation_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running correlation_prb"
  exit
fi
rm correlation_prb
#
echo "Test program output written to correlation_prb_output.txt."
