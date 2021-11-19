#!/bin/bash
#
gfortran -c gfarit.f90
if [ $? -ne 0 ]; then
  echo "Error while compiling gfarit.f90"
  exit
fi
#
gfortran gfarit.o
if [ $? -ne 0 ]; then
  echo "Error while loading gfarit.o"
  exit
fi
rm gfarit.o
#
mv a.out ~/bin/$ARCH/gfarit
#
echo "Executable installed as ~/bin/$ARCH/gfarit"
