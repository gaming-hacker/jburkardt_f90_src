#!/bin/bash
#
mkdir temp
cd temp
rm *
f90split ../chebyshev_polynomial.f90
#
for FILE in `ls -1 *.f90`
do
  gfortran -c $FILE
  if [ $? -ne 0 ]; then
    echo "Errors compiling " $FILE
    exit
  fi
done
rm *.f90
#
ar qc libchebyshev_polynomial.a *.o
rm *.o
#
mv libchebyshev_polynomial.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libchebyshev_polynomial.a"
