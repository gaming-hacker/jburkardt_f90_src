#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../calendar_nyt.f90
#
for FILE in `ls -1 *.f90`;
do
  gfortran -c $FILE
  if [ $? -ne 0 ]; then
    echo "Errors compiling " $FILE
    exit
  fi
done
rm *.f90
#
ar qc libcalendar_nyt.a *.o
rm *.o
#
mv libcalendar_nyt.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libcalendar_nyt.a"
