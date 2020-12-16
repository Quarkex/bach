set_action "locate" "project_name? instance_name? -i -b -t"                    \
"Return main path, project path or instance path"                              \
"Usage:"                                                                       \
"  %program_name% %action_name% [%project_name%] [%instance_name%]"            \
""                                                                             \
"Flags:"                                                                       \
"  -i  list folder for docker images"                                          \
""                                                                             \
"  -b  list folder for backups of a project or specific instance"              \
""                                                                             \
"  -t  list folder for project templates"                                      \
""

locate(){(

    incompatible_flags=0
    for flag in "$i" "$b" "$t"; do
        [ ${flag:-0} -gt 0 ] && incompatible_flags=$(( $incompatible_flags + 1 ))
    done
    if [ ${incompatible_flags:-0} -gt 1 ]; then
        echo "ERROR: Flags are incompatible with each other.";
        return -1;
    fi

    target_folder="$instances_folder"
    [ ! "$project_name" == "" ] && project_folder="$project_name.d"

    if [ ${i:-0} -gt 0 ]; then
        target_folder="$images_folder"
        project_folder=""
    fi

    if [ ${b:-0} -gt 0 ]; then
        target_folder="$backup_folder"
    fi

    if [ ${t:-0} -gt 0 ]; then
        project_folder="$project_name"
        target_folder="$sources_folder"
    fi

    [[ ! "$project_folder" == "" ]] && target_folder="$target_folder/$project_folder"
    [[ ! "$instance_name" == "" ]] && target_folder="$target_folder/$instance_name"

    echo "$target_folder"
    ls -d $@ "$target_folder" &>/dev/null
    return $?

)}
