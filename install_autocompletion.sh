#!/bin/bash
for program in ./lib/*/; do
    program="${program#./lib/}"
    program="${program%/}"
    origin="$PWD/lib/$program/completion.bash"
    target="/etc/bash_completion.d/$program-completion.bash"

    if [ -f "$origin" ];then
        if [ -h "$target" ];then
            rm "$target"
        fi
        ln -s "$origin" "$target";
    fi
done
