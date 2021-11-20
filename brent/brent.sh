#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../brent.f90
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
ar qc libbrent.a *.o
rm *.o
#
mv libbrent.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libbrent.a"
