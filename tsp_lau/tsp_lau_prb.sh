#!/bin/bash
#
gfortran -c tsp_lau_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling tsp_lau_prb.f90"
  exit
fi
#
gfortran tsp_lau_prb.o -L$HOME/lib/$ARCH -ltsp_lau
if [ $? -ne 0 ]; then
  echo "Errors linking and loading tsp_lau_prb.o"
  exit
fi
rm tsp_lau_prb.o
#
mv a.out tsp_lau_prb
./tsp_lau_prb > tsp_lau_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running tsp_lau_prb"
  exit
fi
rm tsp_lau_prb
#
echo "Test program output written to tsp_lau_prb_output.txt."
