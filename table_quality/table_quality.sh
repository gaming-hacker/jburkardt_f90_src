#!/bin/bash
#
gfortran -c table_quality.f90
if [ $? -ne 0 ]; then
  echo "Error compiling table_quality.f90"
  exit
fi
#
gfortran table_quality.o
if [ $? -ne 0 ]; then
  echo "Error loading table_quality.o"
  exit
fi
rm table_quality.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/table_quality
#
echo "Executable installed as ~/bin/$ARCH/table_quality"
