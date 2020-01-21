set_action "update" "-i -t"                                                    \
"Update bach itself, the image sources folder, or the project templates folder"\
"Usage:"                                                                       \
"  %program_name% %action_name%"                                               \
""                                                                             \
"To update the image sources folder:"                                          \
"  %program_name% %action_name% -i"                                            \
""                                                                             \
"To update the project templates folder:"                                      \
"  %program_name% %action_name% -t"                                            \
""

update(){(

    if [ ${i:=0} -gt 0 ] && [ ! -d "$images_folder" ]; then
        echo "ERROR: docker images folder does not exist."
        return -1
    fi

    if [ ${t:=0} -gt 0 ] && [ ! -d "$sources_folder" ]; then
        echo "ERROR: project templates folder does not exist."
        return -1
    fi

    if [ $i -gt 0 ]; then
        (cd "$images_folder"; git pull --recurse-submodules);
        return $?;
    fi

    if [ $t -gt 0 ]; then
        (cd "$sources_folder"; git pull --recurse-submodules);
        return $?;
    fi

    (cd "${program_bin_dir%/lib}"; git pull --recurse-submodules);
    return $?;

)}
