#!/bin/bash
#
gfortran -c rectangle.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling rectangle.f90"
  exit
fi
#
gfortran rectangle.o -L$HOME/lib/$ARCH -ltoms886
if [ $? -ne 0 ]; then
  echo "Errors linking and loading rectangle.o"
  exit
fi
rm rectangle.o
#
mv a.out rectangle
./rectangle > rectangle_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running rectangle"
  exit
fi
rm rectangle
#
echo "Test results written to rectangle_output.txt."
