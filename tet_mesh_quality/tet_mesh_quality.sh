#!/bin/bash
#
gfortran -c tet_mesh_quality.f90
if [ $? -ne 0 ]; then
  echo "Error compiling tet_mesh_quality.f90"
  exit
fi
#
gfortran tet_mesh_quality.o
if [ $? -ne 0 ]; then
  echo "Error loading tet_mesh_quality.o
  exit
fi
rm tet_mesh_quality.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/tet_mesh_quality
#
echo "Executable installed as ~/bin/$ARCH/tet_mesh_quality"
