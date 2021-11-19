#!/bin/bash
#
gfortran -c triangulation_svg.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangulation_svg.f90"
  exit
fi
#
gfortran triangulation_svg.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangulation_svg.o"
  exit
fi
#
rm triangulation_svg.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/triangulation_svg
#
echo "Executable installed as ~/bin/$ARCH/triangulation_svg"
