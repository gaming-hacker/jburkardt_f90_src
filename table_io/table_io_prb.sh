#!/bin/bash
#
gfortran -c table_io_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling table_io_prb.f90"
  exit
fi
#
gfortran table_io_prb.o -L$HOME/lib/$ARCH -ltable_io
if [ $? -ne 0 ]; then
  echo "Errors linking and loading table_io_prb.o"
  exit
fi
rm table_io_prb.o
#
mv a.out table_io_prb
./table_io_prb > table_io_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running table_io_prb"
  exit
fi
rm table_io_prb
#
echo "Test program output written to table_io_prb_output.txt."
