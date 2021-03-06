#!/bin/sh

# LePiX Regression testing script
# based on testall.sh for MicroC by Stephen Edwards

# Step through a list of files
#  Compile, run, and check the output of each expected-to-work test
#  Compile and check the error of each expected-to-fail test

# Path to the LLVM interpreter
LLI="lli"

# Path to the lepix compiler.  Usually "./lepix.native"
# Try "_build/lepix.native" if ocamlbuild was unable to create a symbolic link.
LEPIX="source/lepix.native -c"
#LEPIX="source/_build/lepix.native"

# Set time limit for all operations
ulimit -t 30

# Colors!
RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color

# To align status messages
size=0

globallog=testall.log
rm -f $globallog
error=0
globalerror=0

keep=0

Usage() {
    echo "Usage: testall.sh [options] [.lepix files]"
    echo "-k    Keep intermediate files"
    echo "-h    Print this help"
    exit 1
}

SignalError() {
    if [ $error -eq 0 ] ; then
    if [ $size -eq 2 ] ; then
        echo "\t${RED}(ಥ_ಥ)${NC}"
    else
        echo "\t\t${RED}(ಥ_ಥ)${NC}"
    fi
	error=1
    fi
    echo "  $1"
}

# Compare <outfile> <reffile> <difffile>
# Compares the outfile with reffile.  Differences, if any, written to difffile
Compare() {
    generatedfiles="$generatedfiles $3"
    echo diff -b $1 $2 ">" $3 1>&2
    diff -b "$1" "$2" > "$3" 2>&1 || {
	SignalError "$1 differs"
    echo "=========="
    echo "EXPECTED OUTPUT:"
    cat $2
    echo "=========="
    echo "ACTUAL OUTPUT:"
    cat $1
    echo "=========="

	echo "FAILED $1 differs from $2" 1>&2
    }
}

# Run <args>
# Report the command, run it, and report any errors
Run() {
    echo $* 1>&2
    eval $* || {
	SignalError "$1 failed on $*"
	return 1
    }
}

# RunFail <args>
# Report the command, run it, and expect an error
RunFail() {
    echo $* 1>&2
    eval $* && {
	SignalError "failed: $* did not report an error"
	return 1
    }
    return 0
}

Check() {
    error=0
    basename=`echo $1 | sed 's/.*\\///
                             s/.lepix//'`
    reffile=`echo $1 | sed 's/.lepix$//'`
    basedir="`echo $1 | sed 's/\/[^\/]*$//'`/."

    echo -n "$basename..."
    size=`echo $((${#basename} + 4))`
    size=`echo $(($size/8))`

    echo 1>&2
    echo "###### Testing $basename" 1>&2

    generatedfiles=""

    generatedfiles="$generatedfiles ${basename}.ll ${basename}.out" &&
    Run "$LEPIX" "<" $1 ">" "${basename}.ll" &&
    Run "$LLI" "${basename}.ll" ">" "${basename}.out" &&
    Compare ${basename}.out ${reffile}.out ${basename}.diff

    # Report the status and clean up the generated files

    if [ $error -eq 0 ] ; then
	if [ $keep -eq 0 ] ; then
	    rm -f $generatedfiles
	fi
	if [ $size -eq 2 ] ; then
        echo "\t${GREEN}(•◡•)${NC}"
    else
        echo "\t\t${GREEN}(•◡•)${NC}"
    fi
	echo "###### SUCCESS" 1>&2
    else
	echo "###### FAILED" 1>&2
	globalerror=$error
    fi
}

CheckFail() {
    # echo "in checkfail"
    error=0
    basename=`echo $1 | sed 's/.*\\///
                             s/.lepix//'`
    reffile=`echo $1 | sed 's/.lepix$//'`
    basedir="`echo $1 | sed 's/\/[^\/]*$//'`/."

    echo -n "$basename..."
    size=`echo $((${#basename} + 4))`
    size=`echo $(($size/8))`

    echo 1>&2
    echo "###### Testing $basename" 1>&2

    generatedfiles=""

    generatedfiles="$generatedfiles ${basename}.err ${basename}.diff" &&
    RunFail "$LEPIX" "<" $1 "2>" "${basename}.err" ">>" $globallog &&
    Compare ${basename}.err ${reffile}.err ${basename}.diff

    # Report the status and clean up the generated files

    if [ $error -eq 0 ] ; then
	if [ $keep -eq 0 ] ; then
	    rm -f $generatedfiles
	fi
    if [ $size -eq 2 ] ; then
        echo "\t${GREEN}(•◡•)${NC}"
    else
        echo "\t\t${GREEN}(•◡•)${NC}"
    fi
	echo "###### SUCCESS" 1>&2
    else
	echo "###### FAILED" 1>&2
	globalerror=$error
    fi
}

while getopts kdpsh c; do
    case $c in
	k) # Keep intermediate files
	    keep=1
	    ;;
	h) # Help
	    Usage
	    ;;
    esac
done

shift `expr $OPTIND - 1`

LLIFail() {
  echo "Could not find the LLVM interpreter \"$LLI\"."
  echo "Check your LLVM installation and/or modify the LLI variable in testall.sh"
  exit 1
}

which "$LLI" >> $globallog || LLIFail


if [ $# -ge 1 ]
then
    files=$@
else
    files="tests/test-*.lepix tests/fail-*.lepix"
fi

for file in $files
do
    case $file in
	*test-*)
	    Check $file 2>> $globallog
	    ;;
	*fail-*)
	    CheckFail $file 2>> $globallog
	    ;;
	*)
	    echo "unknown file type $file"
	    globalerror=1
	    ;;
    esac
done

if [ $globalerror -eq 0 ] ; then
    echo "\n${GREEN}(⌐■_■)${NC}"
else
    echo "\n${RED}( ಠ_ಠ)>⌐■-■${NC}"
fi
exit $globalerror
