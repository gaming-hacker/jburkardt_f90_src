#!/bin/bash
#
gfortran -c toms672_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling toms672_prb.f90"
  exit
fi
#
gfortran toms672_prb.o -L$HOME/lib/$ARCH -ltoms672
if [ $? -ne 0 ]; then
  echo "Errors linking and loading toms672_prb.o"
  exit
fi
rm toms672_prb.o
#
mv a.out $HOME/bin/$ARCH/toms672_prb
#
echo "Test program written to $HOME/bin/$ARCH/toms672_prb"
