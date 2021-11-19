#!/bin/bash
#
gfortran -c tetrahedron_keast_rule_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling tetrahedron_keast_rule_prb.f90"
  exit
fi
#
gfortran tetrahedron_keast_rule_prb.o -L$HOME/lib/$ARCH -ltetrahedron_keast_rule
if [ $? -ne 0 ]; then
  echo "Errors linking and loading tetrahedron_keast_rule_prb.o"
  exit
fi
rm tetrahedron_keast_rule_prb.o
#
mv a.out tetrahedron_keast_rule_prb
./tetrahedron_keast_rule_prb > tetrahedron_keast_rule_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running tetrahedron_keast_rule_prb"
  exit
fi
rm tetrahedron_keast_rule_prb
#
echo "Test program output written to tetrahedron_keast_rule_prb_output.txt."
