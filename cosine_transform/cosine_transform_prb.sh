#!/bin/bash
#
gfortran -c cosine_transform_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling cosine_transform_prb.f90"
  exit
fi
#
gfortran cosine_transform_prb.o -L$HOME/lib/$ARCH -lcosine_transform
if [ $? -ne 0 ]; then
  echo "Errors linking and loading cosine_transform_prb.o"
  exit
fi
rm cosine_transform_prb.o
#
mv a.out cosine_transform_prb
./cosine_transform_prb > cosine_transform_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running cosine_transform_prb"
  exit
fi
rm cosine_transform_prb
#
echo "Test program output written to cosine_transform_prb_output.txt."
