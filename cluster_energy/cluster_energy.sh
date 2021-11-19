#!/bin/bash
#
gfortran -c cluster_energy.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling cluster_energy.f90"
  exit
fi
#
gfortran cluster_energy.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading cluster_energy.o"
  exit
fi
rm cluster_energy.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/cluster_energy
#
echo "Program installed as ~/bin/$ARCH/cluster_energy"
