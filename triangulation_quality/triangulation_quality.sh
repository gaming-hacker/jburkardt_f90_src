#!/bin/bash
#
gfortran -c triangulation_quality.f90
if [ $? -ne 0 ]; then
  echo "Error compiling triangulation_quality.f90"
  exit
fi
#
gfortran triangulation_quality.o
if [ $? -ne 0 ]; then
  echo "Error loading triangulation_quality.o"
  exit
fi
rm triangulation_quality.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/triangulation_quality
#
echo "Executable installed as ~/bin/$ARCH/triangulation_quality"
