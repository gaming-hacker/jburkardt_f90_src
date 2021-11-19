#!/bin/bash
#
mkdir temp
cd temp
~/binc/$ARCH/f77split ../point_merge.f
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
ar qc libpoint_merge.a *.o
rm *.o
#
mv libpoint_merge.a ~/libf77/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/libf77/$ARCH/libpoint_merge.a."
