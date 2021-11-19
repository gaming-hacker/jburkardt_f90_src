#!/bin/bash
#
mkdir temp
cd temp
~/binc/$ARCH/f77split ../simpack.f
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
ar qc libsimpack.a *.o
rm *.o
#
mv libsimpack.a ~/libf77/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/libf77/$ARCH/libsimpack.a."
