#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../cube_integrals.f90
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
ar qc libcube_integrals.a *.o
rm *.o
#
mv libcube_integrals.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libcube_integrals.a"
