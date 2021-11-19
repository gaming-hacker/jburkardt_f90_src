#!/bin/bash
#
gfortran -c cellular_automaton.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling cellular_automaton.f90"
  exit
fi
#
gfortran cellular_automaton.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading cellular_automaton.o"
  exit
fi
rm cellular_automaton.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/cellular_automaton
#
echo "Program installed as ~/bin/$ARCH/cellular_automaton"
