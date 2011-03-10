#!/bin/bash
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LANG="en_US.UTF-8"

CR=$'\n'
a=1
while read -r line ; do
	if [ $a == 1 ] ; then
		my="${line}"
	else
		my="${my}${CR}${line}"
	fi
	let a=a+1
done
my="${my}${CR}${line}"

/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc "$1" -- "$my" | iconv -s -f UTF-8 -t ISO8859-1 --