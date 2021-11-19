#!/bin/bash
#
mkdir temp
cd temp
~/binc/$ARCH/f77split ../toms456.f
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
ar qc libtoms456.a *.o
rm *.o
#
mv libtoms456.a ~/libf77/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/libf77/$ARCH/libtoms456.a."
