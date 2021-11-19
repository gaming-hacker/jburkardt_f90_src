#!/bin/bash
#
gfortran -c chebyshev1_rule.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling chebyshev1_rule.f90"
  exit
fi
#
gfortran chebyshev1_rule.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading chebyshev1_rule.o"
  exit
fi
rm chebyshev1_rule.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/chebyshev1_rule
#
echo "Executable installed as ~/bin/$ARCH/chebyshev1_rule"
