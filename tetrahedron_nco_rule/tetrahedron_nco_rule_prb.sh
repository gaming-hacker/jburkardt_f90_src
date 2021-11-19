#!/bin/bash
#
gfortran -c tetrahedron_nco_rule_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling tetrahedron_nco_rule_prb.f90"
  exit
fi
#
gfortran tetrahedron_nco_rule_prb.o -L$HOME/lib/$ARCH -ltetrahedron_nco_rule
if [ $? -ne 0 ]; then
  echo "Errors linking and loading tetrahedron_nco_rule_prb.o"
  exit
fi
rm tetrahedron_nco_rule_prb.o
#
mv a.out tetrahedron_nco_rule_prb
./tetrahedron_nco_rule_prb > tetrahedron_nco_rule_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running tetrahedron_nco_rule_prb"
  exit
fi
rm tetrahedron_nco_rule_prb
#
echo "Test program output written to tetrahedron_nco_rule_prb_output.txt."
