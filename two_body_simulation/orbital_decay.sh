#!/bin/bash
#
gfortran -c orbital_decay.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling orbital_decay.f90"
  exit
fi
#
gfortran orbital_decay.o -L$HOME/lib/$ARCH -lrkf45
if [ $? -ne 0 ]; then
  echo "Errors linking and loading orbital_decay.o"
  exit
fi
rm orbital_decay.o
#
mv a.out orbital_decay
./orbital_decay > orbital_decay_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running orbital_decay"
  exit
fi
rm orbital_decay
#
echo "Test program output written to orbital_decay_output.txt."
