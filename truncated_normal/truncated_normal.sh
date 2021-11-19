#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../truncated_normal.f90
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
ar qc libtruncated_normal.a *.o
rm *.o
#
mv libtruncated_normal.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libtruncated_normal.a"
