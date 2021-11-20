#!/bin/bash
#
gfortran -c table_top.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling table_top.f90"
  exit
fi
#
gfortran table_top.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading table_top.o"
  exit
fi
rm table_top.o
#
mv a.out table_top
#
chmod ugo+x table_top
mv table_top $HOME/bin/$ARCH
#
echo "Executable installed as $HOME/bin/$ARCH/table_top"
