#!/bin/bash
#
mkdir temp
cd temp
rm *
~/binc/$ARCH/f77split ../expokit.f
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
ar qc libexpokit.a *.o
rm *.o
#
mv libexpokit.a ~/libf77/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/libf77/$ARCH/libexpokit.a."
