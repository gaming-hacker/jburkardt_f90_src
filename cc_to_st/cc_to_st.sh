#!/bin/bash
#
mkdir temp
cd temp
rm *
~/bin/$ARCH/f90split ../cc_to_st.f90
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
ar qc libcc_to_st.a *.o
rm *.o
#
mv libcc_to_st.a ~/lib/$ARCH
cd ..
rmdir temp
#
echo "Library installed as ~/lib/$ARCH/libcc_to_st.a"
