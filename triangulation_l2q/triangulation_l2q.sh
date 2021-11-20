#!/bin/bash
#
gfortran -c triangulation_l2q.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangulation_l2q.f90"
  exit
fi
#
gfortran triangulation_l2q.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangulation_l2q.o"
  exit
fi
#
rm triangulation_l2q.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/triangulation_l2q
#
echo "Executable installed as ~/bin/$ARCH/triangulation_l2q"
