#!/bin/bash
#
mkdir temp
cd temp
#
f90split ../../blas0/blas0.f90
#
f90split ../../blas1_c/blas1_c.f90
f90split ../../blas1_d/blas1_d.f90
f90split ../../blas1_s/blas1_s.f90
f90split ../../blas1_z/blas1_z.f90
#
f90split ../../blas2_c/blas2_c.f90
f90split ../../blas2_d/blas2_d.f90
f90split ../../blas2_s/blas2_s.f90
f90split ../../blas2_z/blas2_z.f90
#
f90split ../../blas3_c/blas3_c.f90
f90split ../../blas3_d/blas3_d.f90
f90split ../../blas3_s/blas3_s.f90
f90split ../../blas3_z/blas3_z.f90
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
#  Create the library.
#
ar qc libblas.a *.o
rm *.o
#
mv libblas.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libblas.a."
