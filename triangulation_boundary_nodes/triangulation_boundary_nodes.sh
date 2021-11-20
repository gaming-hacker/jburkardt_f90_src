#!/bin/bash
#
gfortran -c triangulation_boundary_nodes.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangulation_boundary_nodes.f90"
  exit
fi
#
gfortran triangulation_boundary_nodes.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangulation_boundary_nodes.o"
  exit
fi
#
rm triangulation_boundary_nodes.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/triangulation_boundary_nodes
#
echo "Program installed as ~/bin/$ARCH/triangulation_boundary_nodes"
