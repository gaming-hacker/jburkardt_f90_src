#!/bin/bash
#
mkdir temp
cd temp
~/binc/$ARCH/f77split ../sparsekit2.f
#
for FILE in `ls -1 *.f`;
do
  gfortran -c $FILE
  if [ $? -ne 0 ]; then
    echo "Errors compiling " $FILE
    exit
  fi
done
rm *.f
#
ar qc libsparsekit2.a *.o
rm *.o
#
mv libsparsekit2.a ~/libf77/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/libf77/$ARCH/libsparsekit2.a."
