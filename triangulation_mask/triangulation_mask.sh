#!/bin/bash
#
gfortran -c triangulation_mask.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangulation_mask.f90"
  exit
fi
#
mv triangulation_mask.o ~/lib/$ARCH
#
echo "Partial program installed as ~/lib/$ARCH/triangulation_mask.o"
