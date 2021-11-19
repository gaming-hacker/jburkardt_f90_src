#!/bin/bash
#
gfortran -c table_delaunay.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling table_delaunay.f90"
  exit
fi
#
gfortran table_delaunay.o -L$HOME/lib/$ARCH
if [ $? -ne 0 ]; then
  echo "Errors linking and loading table_delaunay.o"
  exit
fi
#
rm table_delaunay.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/table_delaunay
#
echo "Executable installed as ~/bin/$ARCH/table_delaunay"
