#!/bin/bash
#
gfortran -c truncated_normal_rule.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling truncated_normal_rule.f90"
  exit
fi
#
gfortran truncated_normal_rule.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading truncated_normal_rule.o"
  exit
fi
rm truncated_normal_rule.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/truncated_normal_rule
#
echo "Executable installed as ~/bin/$ARCH/truncated_normal_rule"
