#!/bin/sh

mkdir output
files="*.lepix"

for file in $files
do
    basename=`echo $file | sed 's/.*\\///
                             s/.lepix//'`
    ../source/lepix.native <$file> $basename.ll
	lli $basename.ll > output/$basename.ppm
	echo "$basename finished"
done

rm *.ll