#!/bin/sh

if [ ! -z "$1" ]; then
    basedir=$1
else
    basedir="/hosting"
fi

cachedir_tag="NOARCHIVE.TAG"

for dirname in $( ls $basedir); do
    cachdir="${basedir}/${dirname}/www/cache"
    if [ -d $cachdir ]; then
        run_command="touch ${cachdir}/${cachedir_tag}"
        echo ${run_command}
        eval ${run_command}
    fi
done

