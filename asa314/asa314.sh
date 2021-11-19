#!/bin/bash
#
mkdir temp
cd temp
f90split ../asa314.f90
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
ar qc libasa314.a *.o
rm *.o
#
mv libasa314.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libasa314.a."
