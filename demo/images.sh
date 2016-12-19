#!/bin/sh

../source/lepix.native <greyscale.lepix> greyscale.ll
lli greyscale.ll > output/greyscale.ppm
echo "greyscale finished"

../source/lepix.native <filter-green.lepix> green.ll
lli green.ll > output/green.ppm
echo "filter green finished"

../source/lepix.native <filter-blue.lepix> blue.ll
lli blue.ll > output/blue.ppm
echo "filter blue finished"

../source/lepix.native <filter-red.lepix> red.ll
lli red.ll > output/red.ppm
echo "filter red finished"

../source/lepix.native <remove-green.lepix> green.ll
lli green.ll > output/green2.ppm
echo "remove green finished"

../source/lepix.native <remove-blue.lepix> blue.ll
lli blue.ll > output/blue2.ppm
echo "remove blue finished"

../source/lepix.native <remove-red.lepix> red.ll
lli red.ll > output/red2.ppm
echo "remove red finished"

../source/lepix.native <neg.lepix> neg.ll
lli neg.ll > output/neg.ppm
echo "negative finished"

../source/lepix.native <flip.lepix> flip.ll
lli flip.ll > output/flip.ppm
echo "flip finished"

../source/lepix.native <blur.lepix> blur.ll
lli blur.ll > output/blur.ppm
echo "blur finished"

../source/lepix.native <extremecontrast.lepix> extremecontrast.ll
lli extremecontrast.ll > output/extremecontrast.ppm
echo "extreme contrast finished"

rm *.ll
