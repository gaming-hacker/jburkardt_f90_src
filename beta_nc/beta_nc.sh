#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../beta_nc.f90
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
ar qc libbeta_nc.a *.o
rm *.o
#
mv libbeta_nc.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libbeta_nc.a"
