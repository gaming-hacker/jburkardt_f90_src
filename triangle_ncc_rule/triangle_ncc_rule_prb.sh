#!/bin/bash
#
gfortran -c triangle_ncc_rule_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangle_ncc_rule_prb.f90"
  exit
fi
#
gfortran triangle_ncc_rule_prb.o -L$HOME/lib/$ARCH -ltriangle_ncc_rule
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangle_ncc_rule_prb.o"
  exit
fi
rm triangle_ncc_rule_prb.o
#
mv a.out triangle_ncc_rule_prb
./triangle_ncc_rule_prb > triangle_ncc_rule_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running triangle_ncc_rule_prb"
  exit
fi
rm triangle_ncc_rule_prb
#
echo "Test program output written to triangle_ncc_rule_prb_output.txt."
