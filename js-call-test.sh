#!/bin/bash
export LANG=no_NO.UTF-8
export LOCALE=UTF-8

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
myc=`echo "$my" | iconv -s -f UTF-8 -t ISO8859-1 --`

/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc "$1" -- "$myc"
