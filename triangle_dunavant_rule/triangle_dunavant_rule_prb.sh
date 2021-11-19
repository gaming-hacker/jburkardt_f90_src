#!/bin/bash
#
gfortran -c triangle_dunavant_rule_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangle_dunavant_rule_prb.f90"
  exit
fi
#
gfortran triangle_dunavant_rule_prb.o -L$HOME/lib/$ARCH -ltriangle_dunavant_rule
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangle_dunavant_rule_prb.o"
  exit
fi
rm triangle_dunavant_rule_prb.o
#
mv a.out triangle_dunavant_rule_prb
./triangle_dunavant_rule_prb > triangle_dunavant_rule_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running triangle_dunavant_rule_prb"
  exit
fi
rm triangle_dunavant_rule_prb
#
echo "Test program output written to triangle_dunavant_rule_prb_output.txt."
