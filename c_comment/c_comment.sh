#!/bin/bash
#
gfortran -c c_comment.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling c_comment.f90"
  exit
fi
#
gfortran c_comment.o
if [ $? -ne 0 ]; then
  echo "Errors loading c_comment.o"
  exit
fi
rm c_comment.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/c_comment
#
echo "Executable installed as ~/bin/$ARCH/c_comment"
