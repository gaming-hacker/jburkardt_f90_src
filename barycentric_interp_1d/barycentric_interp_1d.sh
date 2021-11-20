#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../barycentric_interp_1d.f90
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
ar qc libbarycentric_interp_1d.a *.o
rm *.o
#
mv libbarycentric_interp_1d.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libbarycentric_interp_1d.a"
