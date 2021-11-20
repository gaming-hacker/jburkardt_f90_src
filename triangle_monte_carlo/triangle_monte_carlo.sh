#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../triangle_monte_carlo.f90
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
ar qc libtriangle_monte_carlo.a *.o
rm *.o
#
mv libtriangle_monte_carlo.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libtriangle_monte_carlo.a"
