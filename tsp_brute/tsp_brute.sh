#!/bin/bash
#
gfortran -c tsp_brute.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling tsp_brute.f90"
  exit
fi
#
gfortran tsp_brute.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading tsp_brute.o"
  exit
fi
rm tsp_brute.o
#
mv a.out ~/bin/$ARCH/tsp_brute
#
echo "Executable installed as ~/bin/$ARCH/tsp_brute"
