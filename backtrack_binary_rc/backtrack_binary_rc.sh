#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../backtrack_binary_rc.f90
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
ar qc libbacktrack_binary_rc.a *.o
rm *.o
#
mv libbacktrack_binary_rc.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libbacktrack_binary_rc.a"
