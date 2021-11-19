#!/bin/bash
#
gfortran -c ccvt_box.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling ccvt_box.f90"
  exit
fi
#
gfortran ccvt_box.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading ccvt_box.o"
  exit
fi
rm ccvt_box.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/ccvt_box
#
echo "Program installed as ~/bin/$ARCH/ccvt_box"
