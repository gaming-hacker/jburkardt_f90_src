#!/bin/bash
#
gfortran -c cube_grid_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling cube_grid_prb.f90"
  exit
fi
#
gfortran -o cube_grid_prb cube_grid_prb.o -L$HOME/lib/$ARCH -lcube_grid
if [ $? -ne 0 ]; then
  echo "Errors linking and loading cube_grid_prb.o"
  exit
fi
rm cube_grid_prb.o
#
./cube_grid_prb > cube_grid_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running cube_grid_prb"
  exit
fi
rm cube_grid_prb
#
echo "Test program output written to cube_grid_prb_output.txt."
