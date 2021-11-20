#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../tri_surface_io.f90
#
for FILE in `ls -1 *.f90`;
do
  gfortran -c $FILE
  if [ $? -ne 0 ]; then
    echo "Errors compiling " $FILE
    exit
  fi
done
rm *.f90
#
ar qc libtri_surface_io.a *.o
rm *.o
#
mv libtri_surface_io.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libtri_surface_io.a"
