#!/bin/bash
#
gfortran -c test_interp_4d_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling test_interp_4d_prb.f90"
  exit
fi
#
gfortran test_interp_4d_prb.o -L$HOME/lib/$ARCH -ltest_interp_4d -lspline
if [ $? -ne 0 ]; then
  echo "Errors linking and loading test_interp_4d_prb.o"
  exit
fi
rm test_interp_4d_prb.o
#
mv a.out test_interp_4d_prb
./test_interp_4d_prb > test_interp_4d_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running test_interp_4d_prb"
  exit
fi
rm test_interp_4d_prb
#
echo "Test program output written to test_interp_4d_prb_output.txt."
