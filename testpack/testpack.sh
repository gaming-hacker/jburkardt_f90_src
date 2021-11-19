#!/bin/bash
#
gfortran -c testpack.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling testpack.f90"
  exit
fi
#
gfortran testpack.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading testpack.o"
  exit
fi
rm testpack.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/testpack
#
echo "Executable installed as ~/bin/$ARCH/testpack"
