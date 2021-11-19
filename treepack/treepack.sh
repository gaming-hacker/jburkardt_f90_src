#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../treepack.f90
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
ar qc libtreepack.a *.o
rm *.o
#
mv libtreepack.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libtreepack.a"
