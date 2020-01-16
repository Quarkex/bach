set_action "list" "project_name? instance_name? -i -b -d -t"                   \
"List availible projects, instances, images, backups or images"                \
"Usage:"                                                                       \
"  %program_name% %action_name% [-i|-b]"                                       \
""                                                                             \
"Or if you want to list instances of a project:"                               \
"  %program_name% %action_name% %project_name%"                                \
""                                                                             \
"Flags:"                                                                       \
"  -i  list avalible docker images"                                            \
""                                                                             \
"  -b  list avalible backups of a project or specific instance"                \
""                                                                             \
"  -d  implies -b, but only list backups with databases, and accept an "       \
"      optional extra parameter [<database_type>]"                             \
""                                                                             \
"  -t  list avalible project templates"                                        \
""

list(){(

    [ ${d:-0} -gt 0 ] && b=$(( ${b:-0} + 1 ))

    incompatible_flags=0
    for flag in "$i" "$b" "$t"; do
        [ ${flag:-0} -gt 0 ] && incompatible_flags=$(( $incompatible_flags + 1 ))
    done
    if [ ${incompatible_flags:-0} -gt 1 ]; then
        echo "ERROR: Flags are incompatible with each other.";
        return -1;
    fi

    project_folder="$project_name"
    [ ! "$project_name" == "" ] && project_folder="${project_folder}.d"

    target_folder="$instances_folder"

    folder_name="instances"

    if [ ${i:-0} -gt 0 ]; then
        target_folder="$images_folder"
        folder_name="images"
    fi

    if [ ${b:-0} -gt 0 ]; then
        target_folder="$backup_folder"
        [ ${d:-0} -gt 0 ] \
            && folder_name="database backups" \
            || folder_name="backups"
    fi


    if [ ${t:-0} -gt 0 ]; then
        project_folder="$project_name"
        target_folder="$sources_folder"
        folder_name="templates"
    fi

    if [ ! -d "$target_folder" ]; then
        echo "ERROR: The $folder_name folder does not exist.";
        return -1;
    fi

    if [[ "$project_folder" == "" ]]; then
        if [ ${d:-0} -gt 0 ]; then
            for folder in $(ls "$target_folder/"); do
                ls "$target_folder/$folder"/*/*.bak/ &>/dev/null
                [ $? -eq 0 ] && echo "${folder%.d}"
            done
            return 0
        else
            ls -1 -r $@ "$target_folder/" | sed 's/\.d$//g'
            return $?
        fi
    else
        if [ ! -d "$target_folder/$project_folder" ]; then
            echo "ERROR: Project $project_name does not have a folder for $folder_name.";
            return -1;
        else
            if [ ${d:-0} -gt 0 ]; then
                if [ "$instance_name" == "" ]; then
                    for folder in $(ls "$target_folder/$project_folder"); do
                        ls  "$target_folder/$project_folder/$folder"/*.bak/ &>/dev/null
                        [ $? -eq 0 ] && echo "${folder##*/}"
                    done
                else
                    if [ "$1" == "" ]; then
                        for folder in $(ls -d "$target_folder/$project_folder/$instance_name/"*.bak); do
                            folder="${folder%.bak}"
                            echo "${folder##*/}"
                        done
                    else
                        for file in $(ls "$target_folder/$project_folder/$instance_name/$1.bak"); do
                            echo "${file##*/}"
                        done
                    fi
                fi
                return 0
            else
                ls -1 -r $@ "$target_folder/$project_folder/$instance_name" | sed 's/\.d$//g'
                return $?
            fi
        fi
    fi

)}
