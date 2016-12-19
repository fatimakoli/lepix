#!/bin/sh

# Regression testing script for LePiX
# Step through a list of files
#  Compile, run, and check the output of each expected-to-work test
#  Compile and check the error of each expected-to-fail test

# Path to the LLVM interpreter
LLI="lli"
#!/bin/sh

../source/lepix.native <greyscale.lepix> greyscale.ll
lli greyscale.ll > greyscale.ppm
echo "greyscale finished"

../source/lepix.native <filter-green.lepix> green.ll
lli green.ll > green.ppm
echo "filter green finished"

../source/lepix.native <filter-blue.lepix> blue.ll
lli blue.ll > blue.ppm
echo "filter blue finished"

../source/lepix.native <filter-red.lepix> red.ll
lli red.ll > red.ppm
echo "filter red finished"

../source/lepix.native <remove-green.lepix> green.ll
lli green.ll > green2.ppm
echo "remove green finished"

../source/lepix.native <remove-blue.lepix> blue.ll
lli blue.ll > blue2.ppm
echo "remove blue finished"

../source/lepix.native <remove-red.lepix> red.ll
lli red.ll > red2.ppm
echo "remove red finished"

../source/lepix.native <neg.lepix> neg.ll
lli neg.ll > neg.ppm
echo "negative finished"

../source/lepix.native <flip.lepix> flip.ll
lli flip.ll > flip.ppm
echo "flip finished"

../source/lepix.native <blur.lepix> blur.ll
lli blur.ll > blur.ppm
echo "flip finished"

../source/lepix.native <extremecontrast.lepix> extremecontrast.ll
lli extremecontrast.ll > extremecontrast.ppm
echo "extreme contrast finished"

