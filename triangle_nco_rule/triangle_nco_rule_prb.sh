#!/bin/bash
#
gfortran -c triangle_nco_rule_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangle_nco_rule_prb.f90"
  exit
fi
#
gfortran triangle_nco_rule_prb.o -L$HOME/lib/$ARCH -ltriangle_nco_rule
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangle_nco_rule_prb.o"
  exit
fi
rm triangle_nco_rule_prb.o
#
mv a.out triangle_nco_rule_prb
./triangle_nco_rule_prb > triangle_nco_rule_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running triangle_nco_rule_prb"
  exit
fi
rm triangle_nco_rule_prb
#
echo "Test program output written to triangle_nco_rule_prb_output.txt."
