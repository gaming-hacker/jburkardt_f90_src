#!/bin/bash
#
gfortran -c toms443_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling toms443_prb.f90"
  exit
fi
#
gfortran -o toms443_prb toms443_prb.o -L$HOME/lib/$ARCH -ltoms443
if [ $? -ne 0 ]; then
  echo "Errors linking and loading toms443_prb.o"
  exit
fi
rm toms443_prb.o
#
./toms443_prb > toms443_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running toms443_prb"
  exit
fi
rm toms443_prb
#
echo "Test program output written to toms443_prb_output.txt."
