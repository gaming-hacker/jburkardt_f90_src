#!/bin/bash
#
ar x $HOME/lib/$ARCH/libcubpack.a precision_model.mod
ar x $HOME/lib/$ARCH/libcubpack.a cui.mod
#
gfortran -c simplexpapertest.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling simplexpapertest.f90"
  exit
fi
#
rm *.mod
#
gfortran simplexpapertest.o -L$HOME/lib/$ARCH -lcubpack
if [ $? -ne 0 ]; then
  echo "Errors linking and loading simplexpapertest.o"
  exit
fi
rm simplexpapertest.o
#
mv a.out simplexpapertest
./simplexpapertest > simplexpapertest.out
if [ $? -ne 0 ]; then
  echo "Errors running simplexpapertest"
  exit
fi
rm simplexpapertest
#
echo "The simplexpapertest test problem has been executed."
