#!/bin/bash
#
gfortran -c umfpack_2.0_prb.f
if [ $? -ne 0 ]; then
  echo "Errors compiling umfpack_2.0_prb.f"
  exit
fi
#
gfortran umfpack_2.0_prb.o -L$HOME/libf77/$ARCH -lumfpack_2.0
if [ $? -ne 0 ]; then
  echo "Errors linking and loading umfpack_2.0_prb.o"
  exit
fi
rm umfpack_2.0_prb.o
#
mv a.out umfpack_2.0_prb
./umfpack_2.0_prb < umfpack_2.0_prb_input.txt > umfpack_2.0_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running umfpack_2.0_prb"
  exit
fi
rm umfpack_2.0_prb
#
echo "Test results written to umfpack_2.0_prb_output.txt."
