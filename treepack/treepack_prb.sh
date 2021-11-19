#!/bin/bash
#
gfortran -c treepack_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling treepack_prb.f90"
  exit
fi
#
gfortran treepack_prb.o -L$HOME/lib/$ARCH -ltreepack
if [ $? -ne 0 ]; then
  echo "Errors linking and loading treepack_prb.o"
  exit
fi
rm treepack_prb.o
#
mv a.out treepack_prb
./treepack_prb > treepack_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running treepack_prb"
  exit
fi
rm treepack_prb
#
echo "Test program output written to treepack_prb_output.txt."
