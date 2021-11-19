#!/bin/bash
#
gfortran -c tetrahedron_properties.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling tetrahedron_properties.f90"
  exit
fi
#
gfortran tetrahedron_properties.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading tetrahedron_properties.o"
  exit
fi
rm tetrahedron_properties.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/tetrahedron_properties
#
echo "Executable installed as ~/bin/$ARCH/tetrahedron_properties"
