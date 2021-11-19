#!/bin/bash
#
gfortran -c triangle_lyness_rule_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangle_lyness_rule_prb.f90"
  exit
fi
#
gfortran triangle_lyness_rule_prb.o -L$HOME/lib/$ARCH -ltriangle_lyness_rule
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangle_lyness_rule_prb.o"
  exit
fi
rm triangle_lyness_rule_prb.o
#
mv a.out triangle_lyness_rule_prb
./triangle_lyness_rule_prb > triangle_lyness_rule_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running triangle_lyness_rule_prb"
  exit
fi
rm triangle_lyness_rule_prb
#
echo "Test program output written to triangle_lyness_rule_prb_output.txt."
