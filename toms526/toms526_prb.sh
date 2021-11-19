#!/bin/bash
#
gfortran -c toms526_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling toms526_prb.f90"
  exit
fi
#
gfortran toms526_prb.o -L$HOME/lib/$ARCH -ltoms526
if [ $? -ne 0 ]; then
  echo "Errors linking and loading toms526_prb.o"
  exit
fi
rm toms526_prb.o
#
mv a.out toms526_prb
./toms526_prb > toms526_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running toms526_prb"
  exit
fi
rm toms526_prb
#
echo "Test program output written to toms526_prb_output.txt."
