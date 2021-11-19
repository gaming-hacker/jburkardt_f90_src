#!/bin/bash
#
mkdir temp
cd temp
rm *
#
#  Need these first...
#
gfortran -c ../buckley.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling buckley.f90."
  exit
fi
#
gfortran -c ../internal_types.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling internal_types.f90."
  exit
fi
#
gfortran -c ../ds_routines.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling ds_routines.f90."
  exit
fi
#
gfortran -c ../error_handling.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling error_handling.f90."
  exit
fi
#
gfortran -c ../rule_1.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling rule_1.f90."
  exit
fi
#
gfortran -c ../rule_c2.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling rule_c2.f90."
  exit
fi
#
gfortran -c ../rule_c3.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling rule_c3.f90."
  exit
fi
#
gfortran -c ../rule_cn.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling rule_cn.f90."
  exit
fi
#
gfortran -c ../rule_t2.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling rule_t2.f90."
  exit
fi
#
gfortran -c ../rule_t3.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling rule_t3.f90."
  exit
fi
#
gfortran -c ../rule_tn.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling rule_tn.f90."
  exit
fi
#
gfortran -c ../rule_general.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling rule_general.f90."
  exit
fi
#
gfortran -c ../volume.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling volume.f90."
  exit
fi
#
gfortran -c ../divide.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling divide.f90."
  exit
fi
#
gfortran -c ../region_processor.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling region_processor.f90."
  exit
fi
#
gfortran -c ../global_all.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling global_all.f90."
  exit
fi
#
#  Now the rest.
#
gfortran -c ../check.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling check.f90."
  exit
fi
#
gfortran -c ../cui.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling cui.f90."
  exit
fi
#
echo "Create the archive."
ar qc libcubpack.a *.o *.mod
rm *.o
rm *.mod
#
echo "Store the archive."
mv libcubpack.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "The cubpack library has been created as ~/lib/$ARCH/libcubpack.a"

