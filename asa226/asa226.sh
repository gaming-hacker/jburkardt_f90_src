#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../asa226.f90
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
ar qc libasa226.a *.o
rm *.o
#
mv libasa226.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libasa226.a"
