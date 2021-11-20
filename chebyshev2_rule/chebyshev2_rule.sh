#!/bin/bash
#
gfortran -c chebyshev2_rule.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling chebyshev2_rule.f90"
  exit
fi
#
gfortran chebyshev2_rule.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading chebyshev2_rule.o"
  exit
fi
rm chebyshev2_rule.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/chebyshev2_rule
#
echo "Executable installed as ~/bin/$ARCH/chebyshev2_rule"
