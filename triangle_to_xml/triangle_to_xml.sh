#!/bin/bash
#
gfortran -c triangle_to_xml.f90
if [ $? -ne 0 ]; then
  echo "Errors compiling triangle_to_xml.f90"
  exit
fi
#
gfortran triangle_to_xml.o
if [ $? -ne 0 ]; then
  echo "Errors linking and loading triangle_to_xml.o"
  exit
fi
#
rm triangle_to_xml.o
#
chmod ugo+x a.out
mv a.out ~/bin/$ARCH/triangle_to_xml
#
echo "Executable installed as ~/bin/$ARCH/triangle_to_xml"
