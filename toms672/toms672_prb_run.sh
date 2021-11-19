#!/bin/bash
#
$HOME/bin/$ARCH/toms672_prb < toms672_prb_input.txt > toms672_prb_output.txt
if [ $? -ne 0 ]; then
  echo "Errors running toms672_prb"
  exit
fi
#
echo "Test program output written to toms672_prb_output.txt."
