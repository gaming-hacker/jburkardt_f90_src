#!/bin/bash
#
gfortran -c small_mask.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling small_mask.f90"
  exit
fi
#
gfortran ~/lib/$ARCH/triangulation_mask.o small_mask.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangulation_mask.o + small_mask.o"
  exit
fi
rm small_mask.o
#
chmod ugo+x a.out
mv a.out triangulation_mask
./triangulation_mask small_nodes.txt small_triangles.txt > small_mask_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running triangulation_mask."
  exit
fi
rm triangulation_mask
#
echo "Program output written to small_mask_output.txt"
