#!/bin/bash
#
gfortran -c show_two.f90
if [ $? -ne 0 ]; then
  echo "Errors while compiling show_two.f90"
  exit
fi
#
gfortran show_two.o
if [ $? -ne 0 ]; then
  echo "Errors while loading show_two.o"
  exit
fi
rm show_two.o
#
mv a.out ~/bin/$ARCH/show_two
#
echo "Executable installed as ~/bin/$ARCH/show_two"
