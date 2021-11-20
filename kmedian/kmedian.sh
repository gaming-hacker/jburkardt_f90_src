#!/bin/bash
#
gfortran -c kmedian.f
if [ $? -ne 0 ]; then
  echo "Errors compiling kmedian.f"
  exit
fi
#
gfortran kmedian.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading kmedian.o"
  exit
fi
rm kmedian.o
#
mv a.out ~/binf77/$ARCH/kmedian
#
echo "Executable installed as ~/binf77/$ARCH/kmedian"
