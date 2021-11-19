#!/bin/bash
#
gfortran -c bezier_surface_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling bezier_surface_prb.f90"
  exit
fi
#
gfortran bezier_surface_prb.o -L$HOME/lib/$ARCH -lbezier_surface
if [ $? -ne 0 ]; then
  echo "Errors linking and loading bezier_surface_prb.o"
  exit
fi
rm bezier_surface_prb.o
#
mv a.out bezier_surface_prb
#
cp ../../data/bezier_surface/teapot_nodes.txt .
cp ../../data/bezier_surface/teapot_rectangles.txt .
#
./bezier_surface_prb > bezier_surface_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running bezier_surface_prb"
  exit
fi
rm bezier_surface_prb
rm teapot_nodes.txt
rm teapot_rectangles.txt
#
echo "Test program output written to bezier_surface_prb_output.txt."
