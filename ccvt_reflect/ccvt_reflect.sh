#!/bin/bash
#
gfortran -c ccvt_reflect.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling ccvt_reflect.f90"
  exit
fi
#
gfortran ccvt_reflect.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading ccvt_reflect.o"
  exit
fi
rm ccvt_reflect.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/ccvt_reflect
#
echo "Program installed as ~/bin/$ARCH/ccvt_reflect"
