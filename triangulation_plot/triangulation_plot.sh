#!/bin/bash
#
gfortran -c triangulation_plot.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangulation_plot.f90"
  exit
fi
#
gfortran triangulation_plot.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangulation_plot.o"
  exit
fi
#
rm triangulation_plot.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/triangulation_plot
#
echo "Executable installed as ~/bin/$ARCH/triangulation_plot"
