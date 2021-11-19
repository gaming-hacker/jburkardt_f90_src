#!/bin/bash
#
mkdir temp
cd temp
f90split ../toms886.f90
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
ar qc libtoms886.a *.o
rm *.o
#
mv libtoms886.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libtoms886.a."
