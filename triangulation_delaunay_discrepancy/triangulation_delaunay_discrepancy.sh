#!/bin/bash
#
gfortran -c triangulation_delaunay_discrepancy.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangulation_delaunay_discrepancy.f90"
  exit
fi
#
gfortran triangulation_delaunay_discrepancy.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangulation_delaunay_discrepancy.o"
  exit
fi
#
rm triangulation_delaunay_discrepancy.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/triangulation_delaunay_discrepancy
#
echo "Executable installed as ~/bin/$ARCH/triangulation_delaunay_discrepancy"
