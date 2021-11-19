#!/bin/bash
#
gfortran -c table_latinize.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling table_latinize.f90"
  exit
fi
#
gfortran table_latinize.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading table_latinize.o"
  exit
fi
rm table_latinize.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/table_latinize
#
echo "Executable program written to ~/bin/$ARCH/table_latinize"
