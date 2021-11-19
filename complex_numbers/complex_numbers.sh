#!/bin/bash
#
gfortran -c complex_numbers.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling complex_numbers.f90"
  exit
fi
#
gfortran complex_numbers.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading complex_numbers.o"
  exit
fi
rm complex_numbers.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/complex_numbers
#
echo "Executable installed as ~/bin/$ARCH/complex_numbers"
