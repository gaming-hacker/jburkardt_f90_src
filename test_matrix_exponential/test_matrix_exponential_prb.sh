#!/bin/bash
#
gfortran -c test_matrix_exponential_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling test_matrix_exponential_prb.f90"
  exit
fi
#
gfortran test_matrix_exponential_prb.o -L$HOME/lib/$ARCH -ltest_matrix_exponential
if [ $? -ne 0 ]; then
  echo "Errors linking and loading test_matrix_exponential_prb.o"
  exit
fi
rm test_matrix_exponential_prb.o
#
mv a.out test_matrix_exponential_prb
./test_matrix_exponential_prb > test_matrix_exponential_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running test_matrix_exponential_prb"
  exit
fi
rm test_matrix_exponential_prb
#
echo "Program output written to test_matrix_exponential_prb_output.txt"
