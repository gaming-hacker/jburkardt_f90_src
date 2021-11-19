#!/bin/bash
#
mkdir temp
cd temp
~/bin/$ARCH/f90split ../cube_arbq_rule.f90
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
ar qc libcube_arbq_rule.a *.o
rm *.o
#
mv libcube_arbq_rule.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libcube_arbq_rule.a."
