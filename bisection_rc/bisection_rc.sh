#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../bisection_rc.f90
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
ar qc libbisection_rc.a *.o
rm *.o
#
mv libbisection_rc.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libbisection_rc.a"
