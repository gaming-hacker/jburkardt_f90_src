#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../bvls.f90
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
ar qc libbvls.a *.o
rm *.o
#
mv libbvls.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libbvls.a"
