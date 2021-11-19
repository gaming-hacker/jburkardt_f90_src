#!/bin/bash
#
mkdir temp
cd temp
f90split ../cg_rc.f90
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
ar qc libcg_rc.a *.o
rm *.o
#
mv libcg_rc.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libcg_rc.a."
