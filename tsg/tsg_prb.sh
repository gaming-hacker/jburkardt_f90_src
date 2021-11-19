#!/bin/bash
#
gfortran -c -fopenmp tsgFModule.f90 -o tsgFModule.mod
if [ $? -ne 0 ]; then
  echo "Errors compiling tsgFModule.f90"
  exit
fi
#
gfortran -c -fopenmp tsg_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling tsg_prb.f90"
  exit
fi
#
gfortran -c -fopenmp tsgFBridge.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling tsgFBridge.f90"
  exit
fi
#
g++ -c -fopenmp -I /$HOME/include tsgFCWrapper.cpp
if [ $? -ne 0 ]; then
  echo "Errors compiling tsgFCWrapper.cpp"
  exit
fi
#
gfortran -fopenmp tsg_prb.o tsgFModule.mod tsgFBridge.o tsgFCWrapper.o -L$HOME/libcpp/$ARCH -ltsg -lstdc++
if [ $? -ne 0 ]; then
  echo "Errors linking and loading tsg_prb.o"
  exit
fi
rm tsg_prb.o
#
mv a.out tsg_prb
./tsg_prb > tsg_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running tsg_prb"
  exit
fi
rm tsg_prb
#
echo "Test program output written to tsg_prb_output.txt."
