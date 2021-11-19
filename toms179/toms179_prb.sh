#!/bin/bash
#
gfortran -c toms179_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling toms179_prb.f90"
  exit
fi
#
gfortran toms179_prb.o -L$HOME/lib/$ARCH -ltoms179
if [ $? -ne 0 ]; then
  echo "Errors linking and loading toms179_prb.o"
  exit
fi
rm toms179_prb.o
#
mv a.out toms179_prb
./toms179_prb > toms179_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running toms179_prb"
  exit
fi
rm toms179_prb
#
echo "Test program output written to toms179_prb_output.txt."
