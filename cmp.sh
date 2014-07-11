#!/bin/bash

suffix="_filelist"
todolist="todolist"

function filesToText() {
    if [ ! -z $2 ]; then
	find $1 -type f | sed "s/^$1\///" > $1$suffix
    else
	find $1 -type f -name "*.adoc" | sed "s/^$1\///" > $1$suffix
    fi
    sort $1$suffix -o $1$suffix
}

function fileCompare() {
    cur_sha1=$(shasum "$current/$1" | sed "s/\s.*//")
    nxt_sha1=$(shasum "$next/$1" | sed "s/\s.*//")
    if [ $cur_sha1 != $nxt_sha1 ]; then
	echo "M $1" >> $todolist
    fi
}

next="next"
current="current"

# Get agrument from user input.
while getopts "d:f" arg
do
    case $arg in
	d)
	    next=$OPTARG
	    ;;
	f)
	    fullList="true"
	    ;;
    esac
done

# Check if the new doc dir exists.
if [ ! -d $next ]; then
    echo "Error, directory contain new doc does not exists."
    exit 0
fi

filesToText $current $fullList
filesToText $next $filesToText

# New
comm $next$suffix $current$suffix -2 -3 | sed "s/^/A /" > $todolist
# Delete
comm $next$suffix $current$suffix -1 -3 | sed "s/^/D /" >> $todolist

cfiles=$(comm $next$suffix $current$suffix -1 -2)
for file in $cfiles
do 
    fileCompare $file
done

sort $todolist -o $todolist

rm *$suffix
