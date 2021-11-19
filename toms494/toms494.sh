#!/bin/bash
#
mkdir temp
cd temp
~/binc/$ARCH/f77split ../toms494.f
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
ar qc libtoms494.a *.o
rm *.o
#
mv libtoms494.a ~/libf77/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/libf77/$ARCH/libtoms494.a."
