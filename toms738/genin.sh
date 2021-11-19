#!/bin/bash
#
gfortran -c genin.f90
if [ $? -ne 0 ]; then
  echo "Error while compiling genin.f90"
  exit
fi
#
gfortran genin.o
if [ $? -ne 0 ]; then
  echo "Error while loading genin.o"
  exit
fi
rm genin.o
#
mv a.out ~/bin/$ARCH/genin
#
echo "Executable installed as ~/bin/$ARCH/genin"
