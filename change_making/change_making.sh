#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../change_making.f90
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
ar qc libchange_making.a *.o
rm *.o
#
mv libchange_making.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libchange_making.a"
