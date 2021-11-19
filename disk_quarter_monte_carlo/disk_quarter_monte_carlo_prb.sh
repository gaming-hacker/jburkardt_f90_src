#! /bin/bash
#
gfortran -c disk_quarter_monte_carlo_prb.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling disk_quarter_monte_carlo_prb.f90"
  exit
fi
#
gfortran disk_quarter_monte_carlo_prb.o -L$HOME/lib/$ARCH -ldisk_quarter_monte_carlo
if [ $? -ne 0 ]; then
  echo "Errors linking and loading disk_quarter_monte_carlo_prb.o"
  exit
fi
rm disk_quarter_monte_carlo_prb.o
#
mv a.out disk_quarter_monte_carlo_prb
./disk_quarter_monte_carlo_prb > disk_quarter_monte_carlo_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running disk_quarter_monte_carlo_prb"
  exit
fi
rm disk_quarter_monte_carlo_prb
#
echo "Test program output written to disk_quarter_monte_carlo_prb_output.txt."
