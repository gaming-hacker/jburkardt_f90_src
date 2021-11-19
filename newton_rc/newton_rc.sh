#!/bin/bash
#
mkdir temp
cd temp
~/binc/$ARCH/f77split ../newton_rc.f
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
ar qc libnewton_rc.a *.o
rm *.o
#
mv libnewton_rc.a ~/libf77/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/libf77/$ARCH/libnewton_rc.a."
