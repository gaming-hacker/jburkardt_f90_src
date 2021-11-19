#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../bellman_ford.f90
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
ar qc libbellman_ford.a *.o
rm *.o
#
mv libbellman_ford.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libbellman_ford.a"
