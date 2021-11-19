#!/bin/bash
#
gfortran -c triangle_symq_rule_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangle_symq_rule_prb.f90"
  exit
fi
#
gfortran -o triangle_symq_rule_prb triangle_symq_rule_prb.o -L$HOME/lib/$ARCH -ltriangle_symq_rule
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangle_symq_rule_prb.o"
  exit
fi
rm triangle_symq_rule_prb.o
#
./triangle_symq_rule_prb > triangle_symq_rule_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running triangle_symq_rule_prb"
  exit
fi
rm triangle_symq_rule_prb
#
echo "Test results written to triangle_symq_rule_prb_output.txt."
