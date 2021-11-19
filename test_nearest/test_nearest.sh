#!/bin/bash
#
gfortran -c test_nearest.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling test_nearest.f90"
  exit
fi
#
gfortran test_nearest.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading test_nearest.o"
  exit
fi
rm test_nearest.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/test_nearest
#
echo "Executable installed as ~/bin/$ARCH/test_nearest"
