#!/bin/bash
#
gfortran -c triangle_analyze.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangle_analyze.f90"
  exit
fi
#
gfortran triangle_analyze.o -L$HOME/lib/$ARCH -ltriangle_properties
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangle_analyze.o"
  exit
fi
rm triangle_analyze.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/triangle_analyze
#
echo "Executable installed as ~/bin/$ARCH/triangle_analyze"
