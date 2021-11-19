#!/bin/bash
#
gfortran -c ellipse.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling ellipse.f90"
  exit
fi
#
gfortran ellipse.o -L$HOME/lib/$ARCH -ltoms886
if [ $? -ne 0 ]; then
  echo "Errors linking and loading ellipse.o"
  exit
fi
rm ellipse.o
#
mv a.out ellipse
./ellipse > ellipse_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running ellipse"
  exit
fi
rm ellipse
#
echo "Test results written to ellipse_output.txt."
