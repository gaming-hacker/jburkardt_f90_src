#!/bin/bash
#
gfortran -c cvt_basis.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling cvt_basis.f90"
  exit
fi
#
gfortran cvt_basis.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading cvt_basis.o"
  exit
fi
rm cvt_basis.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/cvt_basis
#
echo "Library installed as ~/bin/$ARCH/cvt_basis"
