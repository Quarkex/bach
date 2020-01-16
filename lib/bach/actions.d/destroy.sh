set_action "destroy" "project_name instance_name -f"                           \
"Removes an already generated instance of a project"                           \
"Usage:"                                                                       \
"  %program_name% %action_name% %project_name% %instance_name% [-f]"           \
""                                                                             \
"The -f (force) flag turn off confirmation."                                   \
""

destroy(){(
    target_folder="$instances_folder/$project_name.d"

    if [[ $f -gt 0 ]]; then
        confirmed_action=true
        shift;
    fi

    if [[ ! $confirmed_action == true ]]; then
        while true; do
            read -p "Are you sure you want to permanently remove instance “$instance_name” of project “$project_name”?" yn
            case $yn in
                [Yy]* ) confirmed_action=true; break;;
                [Nn]* ) confirmed_action=false; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi

    instance_folder="$target_folder/$instance_name"
    if [ $confirmed_action == true ]; then
        if [ ! -d "$instance_folder" ]; then
            echo "ERROR: Project $instance_name does not exist.";
            return -1;
        else
            rm -rf "$instance_folder";
            return $?
        fi
    else
        return 0
    fi
)}
