#!/bin/bash
#
mkdir temp
cd temp
rm *
f90split ../test_interp_4d.f90
#
for FILE in `ls -1 *.f90`
do
  gfortran -c $FILE
  if [ $? -ne 0 ]; then
    echo "Errors compiling " $FILE
    exit
  fi
done
rm *.f90
#
ar qc libtest_interp_4d.a *.o
rm *.o
#
mv libtest_interp_4d.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libtest_interp_4d.a"
