#!/bin/bash
#
gfortran -c tet_mesh_refine.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling tet_mesh_refine.f90"
  exit
fi
#
gfortran tet_mesh_refine.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading tet_mesh_refine.o"
  exit
fi
#
rm tet_mesh_refine.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/tet_mesh_refine
#
echo "Executable installed as ~/bin/$ARCH/tet_mesh_refine"
