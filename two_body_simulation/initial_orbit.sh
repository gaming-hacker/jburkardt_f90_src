#!/bin/bash
#
gfortran -c initial_orbit.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling initial_orbit.f90"
  exit
fi
#
gfortran initial_orbit.o -L$HOME/lib/$ARCH -lrkf45
if [ $? -ne 0 ]; then
  echo "Errors linking and loading initial_orbit.o"
  exit
fi
rm initial_orbit.o
#
mv a.out initial_orbit
./initial_orbit > initial_orbit_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running initial_orbit"
  exit
fi
rm initial_orbit
#
echo "Test program output written to initial_orbit_output.txt."
