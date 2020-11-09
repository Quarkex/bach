set_action "down" "project_name instance_name"                                 \
"Send a docker-compose ”down” action to an instance of a project."             \
"Usage:"                                                                       \
"  %program_name% %action_name% %project_name% %instance_name% [arguments]"    \
""

down(){(

    composed_options=""
    for option in "${!options[@]}"; do
        if [ ! ${!option} == false ]; then
            [ ${#option} -eq 1 ] && flag="-$option" || flag="--$option"
            if [ ${!option} == true ]; then
                composed_options="$compose_flags $flag"
            else
                if [ ! ${!option} == false ]; then
                    composed_options="$composed_options $flag ${!option}"
                fi
            fi
        fi
    done

    target_folder="$instances_folder/$project_name.d"

    instance_folder="$target_folder/$instance_name"
    if [ ! -d "$instance_folder" ]; then
        echo "ERROR: Project $instance_name does not exist.";
        return -1;
    else
        cd "$instance_folder";
        docker-compose down $@ $composed_options;
        return $?
    fi
)}
