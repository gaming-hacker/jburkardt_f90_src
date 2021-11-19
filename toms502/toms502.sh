#!/bin/bash
#
mkdir temp
cd temp
~/binc/$ARCH/f77split ../toms502.f
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
ar qc libtoms502.a *.o
rm *.o
#
mv libtoms502.a ~/libf77/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/libf77/$ARCH/libtoms502.a."
