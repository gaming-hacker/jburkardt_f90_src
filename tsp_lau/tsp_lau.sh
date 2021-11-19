#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../tsp_lau.f90
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
ar qc libtsp_lau.a *.o
rm *.o
#
mv libtsp_lau.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libtsp_lau.a"
