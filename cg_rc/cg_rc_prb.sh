#!/bin/bash
#
gfortran -c cg_rc_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling cg_rc_prb.f90"
  exit
fi
#
gfortran cg_rc_prb.o -L$HOME/lib/$ARCH -lcg_rc
if [ $? -ne 0 ]; then
  echo "Errors linking and loading cg_rc_prb.o"
  exit
fi
rm cg_rc_prb.o
#
mv a.out cg_rc_prb
./cg_rc_prb > cg_rc_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running cg_rc_prb"
  exit
fi
rm cg_rc_prb
#
echo "Test results written to cg_rc_prb_output.txt."
