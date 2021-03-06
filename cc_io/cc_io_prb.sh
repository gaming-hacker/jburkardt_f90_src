#!/bin/bash
#
gfortran -c cc_io_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling cc_io_prb.f90"
  exit
fi
#
gfortran -o cc_io_prb cc_io_prb.o -L$HOME/lib/$ARCH -lcc_io
if [ $? -ne 0 ]; then
  echo "Errors linking and loading cc_io_prb.o"
  exit
fi
rm cc_io_prb.o
#
./cc_io_prb > cc_io_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running cc_io_prb"
  exit
fi
rm cc_io_prb
#
echo "Test program output written to cc_io_prb_output.txt."
