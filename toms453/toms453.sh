#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../toms453.f90
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
ar qc libtoms453.a *.o
rm *.o
#
mv libtoms453.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libtoms453.a"
