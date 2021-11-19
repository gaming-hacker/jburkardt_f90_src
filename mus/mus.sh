#!/bin/bash
#
mkdir temp
cd temp
~/binc/$ARCH/f77split ../mus.f
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
ar qc libmus.a *.o
rm *.o
#
mv libmus.a ~/libf77/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/libf77/$ARCH/libmus.a."
