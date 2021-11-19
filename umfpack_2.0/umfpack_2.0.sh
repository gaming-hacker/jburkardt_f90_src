#!/bin/bash
#
mkdir temp
cd temp
~/binc/$ARCH/f77split ../umfpack_2.0.f
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
ar qc libumfpack_2.0.a *.o
rm *.o
#
mv libumfpack_2.0.a ~/libf77/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/libf77/$ARCH/libumfpack_2.0.a."
